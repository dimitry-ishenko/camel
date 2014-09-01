///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include "pam/pam_error.h"
#include "log.h"

#include <QtDeclarative/QDeclarativeView>
#include <QDesktopWidget>
#include <QGraphicsObject>
#include <QtNetwork/QHostInfo>
#include <QDir>
#include <QFile>
#include <QStringList>

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
Manager::~Manager()
{
    delete context;
    delete application;
    delete server;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::run()
{
    try
    {
        server= new X11::Server();

        if(config.server_path.size()) server->set_path(config.server_path);
        if(config.server_auth.size()) server->set_auth(config.server_auth);
        if(config.server_args.size()) server->set_args(config.server_args);

        if(!server->start()) throw std::runtime_error("X server failed to start");

        application= new QApplication(server->display());
        render();

        context= new pam::context("camel");

        context->set_user_func(std::bind(&Manager::get_user, this, std::placeholders::_1));
        context->set_pass_func(std::bind(&Manager::get_pass, this, std::placeholders::_1));

        context->set_item(pam::item::ruser, "root");
        context->set_item(pam::item::tty, server->name().toStdString());

        while(true)
        {
            emit reset();
            application->exec();

            try
            {
                context->reset_item(pam::item::user);
                context->authenticate();

                QString value= get_session();
                if(value == "poweroff")
                {
                }
                else if(value == "reboot")
                {
                }
                else if(value == "hibernate")
                {
                }
                else if(value == "suspend")
                {
                }
                else
                {
                    context->open_session();

                    save_env();
                    spawn();

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

        delete context;
        context= nullptr;

        delete application;
        application= nullptr;

        server->stop();
        delete server;
        server= nullptr;

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
        connect(root, SIGNAL(quit()), application, SLOT(quit()));

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
        QDir dir("/etc/X11/Sessions");
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
void Manager::save_env()
{
    std::string name= context->get_item(pam::item::user);

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

        context->set_env("USER", name);
        context->set_env("HOME", home);
        context->set_env("PWD", home);
        context->set_env("SHELL", shell);
        context->set_env("DISPLAY", server->name().toStdString());
        context->set_env("XAUTHORITY", home+ "/.Xauthority");
    }
    else throw std::runtime_error("No entry for "+ name+ " in the password database");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#include <cerrno>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::spawn()
{
    pid_t pid= fork();
    if(pid == -1) throw std::system_error(errno, std::generic_category());

    if(pid)
    {
        int status;
        while(pid != wait(&status))
        {
            // server still running?
        }

        if(WIFEXITED(status) && !WEXITSTATUS(status))
        {
            // server: sessreg?
        }
    }
    else spawn_child();
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#include <cstdlib>

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::spawn_child()
{
    // child: extract user data
    // child: sessreg?
    // child: switch user
    // child: set client auth
    // child: exec session
    quick_exit(EXIT_SUCCESS);
}
