///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include "process/process.h"
#include "pam/pam_error.h"
#include "log.h"

#include <QtDeclarative/QDeclarativeView>
#include <QDesktopWidget>
#include <QGraphicsObject>
#include <QtNetwork/QHostInfo>
#include <QDir>
#include <QFile>
#include <QStringList>

#include <algorithm>
#include <functional>
#include <stdexcept>

///////////////////////////////////////////////////////////////////////////////////////////////////
Manager::Manager(QString config_path, QObject* parent):
    QObject(parent)
{
    if(config_path.size()) config.path= config_path;

    config.parse();
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::run()
{
    try
    {
        std::string path= x11::server::default_path;
        if(config.server_path.size()) path= config.server_path;

        arguments args= x11::server::default_args;
        if(config.server_args.size()) args= config.server_args;

        server.reset(new x11::server(config.server_auth, x11::server::default_name, path, args));

        application.reset(new QApplication(server->display()));
        render();

        context.reset(new pam::context(config.service));

        context->set_user_func(std::bind(&Manager::get_user, this, std::placeholders::_1));
        context->set_pass_func(std::bind(&Manager::get_pass, this, std::placeholders::_1));

        context->set_item(pam::item::ruser, "root");
        context->set_item(pam::item::tty, server->name());

        while(true)
        {
            emit reset();
            application->exec();

            try
            {
                context->reset(pam::item::user);
                context->authenticate();

                QString value= get_session();
                if(value == "poweroff")
                    poweroff();
                else if(value == "reboot")
                    reboot();
                else if(value == "hibernate")
                    hibernate();
                else if(value == "suspend")
                    suspend();
                else
                {
                    context->open_session();
                    set_environ();

                    process sess(&Manager::sess_proc, this, value);
                    sess.join();

                    context->close_session();
                }

                break;
            }
            catch(pam::pam_error& e)
            {
                emit error(e.what());

                std::cerr << e.what() << std::endl;
                logger << log::error << e.what();
            }
        }

        context.reset();
        application.reset();
        server.reset();

        return 0;
    }
    catch(std::exception& e)
    {
        std::cerr << e.what() << std::endl;
        logger << log::error << e.what();
        return 1;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::render()
{
    QString current= QDir::currentPath();
    try
    {
        username= password= sessions= session= hostname= nullptr;

        if(!QDir::setCurrent(config.theme_path+ "/"+ config.theme_name))
            throw std::runtime_error("Theme dir "+ config.theme_name.toStdString()+ " not found");

        if(!QFile::exists(config.theme_file))
            throw std::runtime_error("Theme file "+ config.theme_file.toStdString()+ " not found");

        QDeclarativeView* view= new QDeclarativeView(QUrl::fromLocalFile(config.theme_file), application->desktop());
        view->setGeometry(application->desktop()->screenGeometry());
        view->show();

        QGraphicsObject* root= view->rootObject();
        connect(this, SIGNAL(reset()), root, SIGNAL(reset()));
        connect(this, SIGNAL(error(QString)), root, SIGNAL(error(QString)));
        connect(root, SIGNAL(quit()), application.get(), SLOT(quit()));

        username= root->findChild<QObject*>("username");
        if(!username) throw std::runtime_error("Missing username element");

        password= root->findChild<QObject*>("password");
        if(!password) throw std::runtime_error("Missing password element");

        sessions= root->findChild<QObject*>("sessions");
        set_sessions();

        session= root->findChild<QObject*>("session");

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
void Manager::set_sessions()
{
    if(sessions)
    {
        QDir dir(config.sessions_path);
        if(dir.isReadable())
        {
            QStringList files= dir.entryList(QDir::Files);

            if(config.sessions.size())
                files= files.toSet().intersect(config.sessions.toSet()).toList();

            sessions->setProperty("text", files);
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
QString Manager::get_session()
{
    QString value;
    if(session) value= session->property("text").toString();

    return value.size()? value: "Xsession";
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#include <cstring>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::set_environ()
{
    std::string name= context->item(pam::item::user);

    passwd* pwd= getpwnam(name.data());
    if(pwd)
    {
        std::string name= pwd->pw_name;
        std::string shell= pwd->pw_shell;
        if(shell.empty())
        {
            setusershell();
            shell= getusershell();
            endusershell();
        }
        std::string home= pwd->pw_dir;

        context->set_environ("USER", name);
        context->set_environ("HOME", home);
        context->set_environ("PWD", home);
        context->set_environ("SHELL", shell);
        context->set_environ("DISPLAY", server->name());
        context->set_environ("XAUTHORITY", home+ "/.Xauthority");
    }
    else throw std::runtime_error("No entry for "+ name+ " in the password database");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::sess_proc(const QString& sess)
{
    environment e= context->environment();

    // child: switch user
    // child: set client auth

    this_process::replace_e(e, (config.sessions_path+ "/"+ sess).toStdString());
    return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::poweroff()
{

}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::reboot()
{

}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::hibernate()
{

}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::suspend()
{

}
