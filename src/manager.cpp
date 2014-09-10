///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include "credentials.h"
#include "pam/pam_error.h"
#include "environ.h"
#include "log.h"

#include <QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QDesktopWidget>
#include <QGraphicsObject>
#include <QtNetwork/QHostInfo>
#include <QDir>
#include <QFile>
#include <QStringList>

#include <iostream>
#include <functional>

///////////////////////////////////////////////////////////////////////////////////////////////////
Manager::Manager(const QString& name, const QString& path, QObject* parent):
    QObject(parent)
{
    if(name.size()) config.xorg_name= name.toStdString();
    if(path.size()) config.path= path;
    config.parse();

    if(config.xorg_name.empty()) config.xorg_name= x11::server::default_name;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::run()
{
    try
    {
        x11::server server(config.xorg_name, config.xorg_auth, config.xorg_args);

        pam::context context(config.pam_service);
        context.set_user_func(std::bind(&Manager::get_user, this, std::placeholders::_1));
        context.set_pass_func(std::bind(&Manager::get_pass, this, std::placeholders::_1));

        context.set(pam::item::ruser, "root");
        context.set(pam::item::tty, server.name());

        {
            QApplication application(server.display());
            render(application);

            while(true)
            {
                emit reset();
                application.exec();

                try
                {
                    QString sess= get_sess();
                    if(sess == "reboot")
                        this_process::execute(config.reboot);
                    else if(sess == "poweroff")
                        this_process::execute(config.poweroff);
                    else
                    {
                        context.reset(pam::item::user);
                        context.authenticate();

                        break;
                    }
                }
                catch(pam::pamh_error& e)
                {
                    emit error(e.what());
                    logger << e.what() << std::endl;
                    std::cerr << e.what() << std::endl;
                }
                catch(execute_error& e)
                {
                    emit error(e.what());
                    logger << e.what() << std::endl;
                    std::cerr << e.what() << std::endl;
                }
            }
        }

        context.open_session();

        app::process process(process::group, &Manager::startup, this, std::ref(context), std::ref(server), get_sess());
        process.join();

        context.close_session();
        return 0;
    }
    catch(std::exception& e)
    {
        logger << log::error << e.what() << std::endl;
        std::cerr << e.what() << std::endl;
        return 1;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::render(QApplication& application)
{
    QString current= QDir::currentPath();
    try
    {
        username= password= sessions= session= hostname= nullptr;

        if(!QDir::setCurrent(config.theme_path+ "/"+ config.theme_name))
            throw std::runtime_error("Theme dir "+ config.theme_name.toStdString()+ " not found");

        if(!QFile::exists(config.theme_file))
            throw std::runtime_error("Theme file "+ config.theme_file.toStdString()+ " not found");

        QDeclarativeView* view= new QDeclarativeView(QUrl::fromLocalFile(config.theme_file), application.desktop());
        view->setGeometry(application.desktop()->screenGeometry());
        view->show();

        QGraphicsObject* root= view->rootObject();
        connect(this, SIGNAL(reset()), root, SIGNAL(reset()));
        connect(this, SIGNAL(error(QString)), root, SIGNAL(error(QString)));
        connect(root, SIGNAL(quit()), &application, SLOT(quit()));

        username= root->findChild<QObject*>("username");
        if(!username) throw std::runtime_error("Missing username element");

        password= root->findChild<QObject*>("password");
        if(!password) throw std::runtime_error("Missing password element");

        session= root->findChild<QObject*>("session");
        sessions= root->findChild<QObject*>("sessions");
        set_sess();

        hostname= root->findChild<QObject*>("hostname");
        if(hostname) hostname->setProperty("text", QHostInfo::localHostName());

        QDir::setCurrent(current);
    }
    catch(...)
    {
        QDir::setCurrent(current);
        throw;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool Manager::get_user(std::string& value)
{
    if(username)
    {
        value= username->property("text").toString().toStdString();
        return true;
    }
    else return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool Manager::get_pass(std::string& value)
{
    if(password)
    {
        value= password->property("text").toString().toStdString();
        return true;
    }
    else return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::set_sess()
{
    QDir dir(config.sessions_path);
    if(dir.isReadable())
    {
        QStringList files= dir.entryList(QDir::Files);
        if(config.sessions.size()) files= files.toSet().intersect(config.sessions.toSet()).toList();

        if(sessions) sessions->setProperty("text", files);

        if(session && files.size()) session->setProperty("text", files[0]);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
QString Manager::get_sess()
{
    QString value;
    if(session) value= session->property("text").toString();

    return value.size()? value: "Xsession";
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::startup(pam::context& context, x11::server& server, const QString& sess)
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
