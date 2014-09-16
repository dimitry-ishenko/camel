///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include "credentials.h"
#include "pam/pam_error.h"
#include "environ.h"
#include "log.h"
#include "errno_error.h"

#include <QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/QDeclarativeContext>
#include <QDesktopWidget>
#include <QGraphicsObject>
#include <QtNetwork/QHostInfo>
#include <QTimer>
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
    context.set_pass_func(std::bind(&Manager::password, this, std::placeholders::_1, std::placeholders::_2));
    context.set_error_func(std::bind(&Manager::response, this, std::placeholders::_1));

    context.set(pam::item::ruser, "root");
    context.set(pam::item::tty, server.name());
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::enter()
{
    QApplication::exit(code_enter);
}
void Manager::cancel()
{
    QApplication::exit(code_cancel);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::run()
try
{
    {
        QApplication app(server.display());
        render();
        app.flush();

        while(true)
        {
            emit enter_user_pass();
            if(QApplication::exec() == code_enter && authenticate()) break;
        }
    }

    context.open_session();

    QString session= settings.session();
    if(!session.size()) session= "Xsession";

    app::process process(process::group, &Manager::startup, this, session);
    process.join();

    context.close_session();
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

        connect(this, SIGNAL(info(QVariant)), root, SLOT(info(QVariant)));
        connect(this, SIGNAL(error(QVariant)), root, SLOT(error(QVariant)));

        connect(this, SIGNAL(enter_user_pass(QVariant)), root, SLOT(enter_user_pass(QVariant)));
        connect(this, SIGNAL(enter_pass(QVariant)), root, SLOT(enter_pass(QVariant)));

        connect(root, SIGNAL(enter()), this, SLOT(enter()));
        connect(root, SIGNAL(cancel()), this, SLOT(cancel()));
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
bool Manager::password(const std::string& message, std::string& value)
{
    bool x= message.find("new") != std::string::npos
         || message.find("New") != std::string::npos
         || message.find("NEW") != std::string::npos;
    value= x? settings.password_n().toStdString(): settings.password().toStdString();
    return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool Manager::response(const std::string& message)
{
    if(do_respond)
    {
        emit error(QString::fromStdString(message));
        do_respond= false;
    }
    return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool Manager::authenticate()
try
{
    context.set(pam::item::user, settings.username().toStdString());
    do_respond= true;
    context.authenticate();

    return true;
}
catch(pam::account_error& e)
{
    if(e.code() == pam::errc::new_authtok_reqd)
    {
        QString password= settings.password();

        while(true)
        {
            QTimer::singleShot(3000, this, SLOT(enter()));
            QApplication::exec();

            emit enter_pass("Enter new password");
            if(QApplication::exec() == code_cancel) break;

            QString password_n= settings.password();

            emit enter_pass("Retype new password");
            if(QApplication::exec() == code_cancel) break;

            if(settings.password() == password_n)
            {
                settings.setPassword(password);
                settings.setPassword_n(password_n);

                if(change_password()) break;
            }
            else emit error("Passwords don't match");
        }
    }
    else response(e.what());

    return false;
}
catch(pam::pamh_error& e)
{
    response(e.what());
    return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::startup(const QString& session)
{
    credentials c(context.get(pam::item::user));
    app::environ e;

    std::string auth= c.home()+ "/.Xauthority";

    std::string x;
    bool found;

    e.set("USER", c.username());
    e.set("LOGNAME", c.username());
    e.set("HOME", c.home());

    x= this_environ::get("PATH", &found);
    if(found) e.set("PATH", x);

    e.set("PWD", c.home());
    e.set("SHELL", c.shell());

    x= this_environ::get("TERM", &found);
    if(found) e.set("TERM", x);

    e.set("DISPLAY", context.get(pam::item::tty));
    e.set("XAUTHORITY", auth);

    c.morph_into();
    server.set_cookie(auth);

    this_process::replace_e(e, (config.sessions_path+ "/"+ session).toStdString());
    return 1;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool Manager::change_password()
{
    app::uid orig_uid= this_user::uid();
    this_user::morph_into( credentials(context.get(pam::item::user)).uid(), false );

    bool code= true;
    try
    {
        do_respond= true;
        context.change_pass();

        emit info("Password changed");
    }
    catch(pam::pass_error& e)
    {
        response(e.what());
        code= false;
    }

    this_user::morph_into(orig_uid, false);
    return code;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::reboot()
try
{
    emit info("Rebooting");
    if(this_process::execute(config.reboot).code() == 0)
        QApplication::exit(code_cancel);
    else emit error("Reboot command failed");
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
        QApplication::exit(code_cancel);
    else emit error("Poweroff command failed");
}
catch(execute_error& e)
{
    emit error(e.what());
    logger << e.what() << std::endl;
}
