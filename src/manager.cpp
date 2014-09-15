///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include "credentials.h"
#include "pam/pam_error.h"
#include "environ.h"
#include "log.h"

#include <QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeContext>
#include <QDesktopWidget>
#include <QGraphicsObject>
#include <QtNetwork/QHostInfo>
#include <QDir>
#include <QFile>
#include <QStringList>

#include <functional>

///////////////////////////////////////////////////////////////////////////////////////////////////
Manager::Manager(const QString& name, const QString& path, QObject* parent):
    QObject(parent)
{
    ////////////////////
    if(name.size()) config.xorg_name= name.toStdString();
    if(config.xorg_name.empty()) config.xorg_name= x11::server::default_name;

    if(path.size()) config.path= path;

    config.parse();

    ////////////////////
    settings.setHostname(QHostInfo::localHostName());

    QDir dir(config.sessions_path);
    if(dir.isReadable())
    {
        QStringList sessions= dir.entryList(QDir::Files);
        if(config.sessions.size())
            sessions= sessions.toSet().intersect(config.sessions.toSet()).toList();

        settings.setSessions(sessions);
    }

    ////////////////////
    server= x11::server(config.xorg_name, config.xorg_auth, config.xorg_args);

    context= pam::context(config.pam_service);
    context.set_user_func(std::bind(&Manager::username, this, std::placeholders::_1, std::placeholders::_2));
    context.set_pass_func(std::bind(&Manager::password, this, std::placeholders::_1, std::placeholders::_2));

    context.set_error_func([this](const std::string& x) { emit error(QString::fromStdString(x)); return true; });

    context.set(pam::item::ruser, "root");
    context.set(pam::item::tty, server.name());
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::run()
try
{
    {
        QApplication application(server.display());
        render();

        emit reset();
        application.exec();
    }

    if(_M_login)
    {
        context.open_session();

        QString session= settings.session();
        if(!session.size()) session= "Xsession";

        app::process process(process::group, &Manager::startup, this, session);
        process.join();

        context.close_session();
    }
    return 0;
}
catch(std::exception& e)
{
    logger << log::error << e.what() << std::endl;
    return 1;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::render()
{
    QString current= QDir::currentPath();
    try
    {
        if(!QDir::setCurrent(config.theme_path+ "/"+ config.theme_name))
            throw std::runtime_error("Theme dir "+ config.theme_name.toStdString()+ " not found");

        if(!QFile::exists(config.theme_file))
            throw std::runtime_error("Theme file "+ config.theme_file.toStdString()+ " not found");

        QDeclarativeView* view= new QDeclarativeView(QApplication::desktop());
        view->rootContext()->setContextProperty("settings", &settings);
        view->setSource(QUrl::fromLocalFile(config.theme_file));
        view->setGeometry(QApplication::desktop()->screenGeometry());

        QGraphicsObject* root= view->rootObject();
        root->setProperty("width", view->width());
        root->setProperty("height", view->height());

        connect(this, SIGNAL(reset()), root, SLOT(reset()));
        connect(this, SIGNAL(reset_pass()), root, SLOT(reset_pass()));

        connect(this, SIGNAL(info(QVariant)), root, SLOT(info(QVariant)));
        connect(this, SIGNAL(error(QVariant)), root, SLOT(error(QVariant)));

        connect(root, SIGNAL(login()), this, SLOT(login()));
        connect(root, SIGNAL(change_pass()), this, SLOT(change_pass()));

        connect(root, SIGNAL(reboot()), this, SLOT(reboot()));
        connect(root, SIGNAL(poweroff()), this, SLOT(poweroff()));

        view->show();

        QDir::setCurrent(current);
    }
    catch(...)
    {
        QDir::setCurrent(current);
        throw;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool Manager::username(const std::string&, std::string& value)
{
    value= settings.username().toStdString();
    return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool Manager::password(const std::string& message, std::string& value)
{
    bool found= message.find("new") != std::string::npos
             || message.find("New") != std::string::npos
             || message.find("NEW") != std::string::npos;
    value= found? settings.newpass().toStdString(): settings.password().toStdString();
    return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::login()
try
{
    try
    {
        context.reset(pam::item::user);
        context.authenticate();

        _M_login= true;
        QApplication::quit();
    }
    catch(pam::account_error& e)
    {
        if(e.code() == pam::errc::new_authtok_reqd)
        {
            emit error("Your password has expired");
            logger << e.what() << std::endl;

            emit reset_pass();
        }
        else throw;
    }
}
catch(pam::pamh_error& e)
{
    emit error(e.what());
    logger << e.what() << std::endl;

    emit reset();
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::startup(const QString& sess)
{
    credentials c(context.get(pam::item::user));
    app::environ e;

    std::string auth= c.home+ "/.Xauthority";

    bool found;
    std::string value;

    e.set("USER", c.username);
    e.set("LOGNAME", c.username);
    e.set("HOME", c.home);

    value= this_environ::get("PATH", &found);
    if(found) e.set("PATH", value);

    e.set("PWD", c.home);
    e.set("SHELL", c.shell);

    value= this_environ::get("TERM", &found);
    if(found) e.set("TERM", value);

    e.set("DISPLAY", context.get(pam::item::tty));
    e.set("XAUTHORITY", auth);

    c.morph_into();
    server.set_cookie(auth);

    this_process::replace_e(e, (config.sessions_path+ "/"+ sess).toStdString());
    return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::change_pass()
try
{
    if(settings.newpass2() == settings.newpass())
    {
        context.change_pass();

        emit info("Password changed");
        emit reset();
    }
    else
    {
        emit error("Passwords don't match");
        emit reset_pass();
    }
}
catch(pam::pass_error& e)
{
    emit error("Failed to change the password");
    logger << e.what() << std::endl;

    emit reset_pass();
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::reboot()
try
{
    emit info("Rebooting");
    if(this_process::execute(config.reboot).code() == 0)
    {
        _M_login= false;
        QApplication::quit();
    }
}
catch(execute_error& e)
{
    emit error(e.what());
    logger << e.what() << std::endl;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::poweroff()
try
{
    emit info("Powering off");
    if(this_process::execute(config.poweroff).code() == 0)
    {
        _M_login= false;
        QApplication::quit();
    }
}
catch(execute_error& e)
{
    emit error(e.what());
    logger << e.what() << std::endl;
}
