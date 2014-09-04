///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include "x11.h"
#include "process/process.h"
#include "pam/pam.h"
#include "pam/pam_error.h"
#include "credentials.h"
#include "log.h"

#include <QApplication>
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
#include <cstdlib>

///////////////////////////////////////////////////////////////////////////////////////////////////
Manager::Manager(const QString& config_path, QObject* parent):
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
        x11::server server(config.server_auth, std::string(), config.server_path, config.server_args);

        pam::context context(config.service);

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
                    context.reset(pam::item::user);
                    context.authenticate();

                    break;
                }
                catch(pam::pamh_error& e)
                {
                    emit error(e.what());
                    std::cerr << e.what() << std::endl;
                }
            }
        }

        context.open_session();

        credentials cred= credentials::get(context.get(pam::item::user));
        store(cred, context);

        app::process process(true, &Manager::startup, this, std::ref(context), std::ref(cred), get_sess());
        process.join();

        context.close_session();
        return 0;
    }
    catch(std::exception& e)
    {
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
void Manager::store(credentials& cred, pam::context& context)
{
    context.set("USER", cred.username);
    context.set("LOGNAME", cred.username);
    context.set("HOME", cred.home);
    if(char* x= getenv("PATH")) context.set("PATH", x);
    context.set("PWD", cred.home);
    context.set("SHELL", cred.shell);
    if(char* x= getenv("TERM")) context.set("TERM", x);
    context.set("DISPLAY", context.get(pam::item::tty));
    context.set("XAUTHORITY", cred.home+ "/.Xauthority");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::startup(pam::context& context, credentials& cred, const QString& sess)
{
    cred.morph_into();

    // child: set client auth

    this_process::replace_e(context.environment(), (config.sessions_path+ "/"+ sess).toStdString());
    return 0;
}
