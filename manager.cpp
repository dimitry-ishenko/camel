///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include "logger.h"
#include "pam/pam_error.h"

#include <QtDeclarative/QDeclarativeView>
#include <QDesktopWidget>
#include <QGraphicsObject>
#include <QtNetwork/QHostInfo>
#include <QDir>
#include <QFile>

#include <functional>
#include <stdexcept>

///////////////////////////////////////////////////////////////////////////////////////////////////
Manager::Manager(QString config_path, QObject* parent):
    QObject(parent)
{
    if(config_path.size()) config.path= config_path;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::run()
{
    try
    {
        config.parse();

        if(config.server_path.size()) server.set_path(config.server_path);
        if(config.server_auth.size()) server.set_auth(config.server_auth);
        if(config.server_args.size()) server.set_args(config.server_args);

        if(!server.start()) throw std::runtime_error("X server failed to start");

        context= QSharedPointer<pam::context>(new pam::context("camel"));

        context->set_user_func(std::bind(&Manager::get_user, this, std::placeholders::_1));
        context->set_pass_func(std::bind(&Manager::get_pass, this, std::placeholders::_1));

        context->set_item(pam::item::ruser, "root");
        context->set_item(pam::item::tty, server.name().toStdString());

        application= QSharedPointer<QApplication>(new QApplication(server.display()));
        render();

        while(true)
        {
            emit reset();
            application->exec();

            try
            {
                context->reset_item(pam::item::user);
                context->authenticate();
                break;
            }
            catch(pam::pam_error& e)
            {
                emit error(e.what());

                sys::logger << sys::error << e.what();
            }
        }
    }
    catch(std::exception& e)
    {
        sys::logger << sys::error << e.what();
        return 1;
    }
    return 0;
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

        QDeclarativeView* view= new QDeclarativeView(QUrl::fromLocalFile(config.theme_file), application->desktop());
        view->setGeometry(application->desktop()->screenGeometry());
        view->show();

        QGraphicsObject* root= view->rootObject();
        connect(this, SIGNAL(reset()), root, SIGNAL(reset()));
        connect(this, SIGNAL(error(QString)), root, SIGNAL(error(QString)));
        connect(root, SIGNAL(quit()), this, SLOT(quit()));

        username= root->findChild<QObject*>("username");
        if(!username) throw std::runtime_error("Missing username element");

        password= root->findChild<QObject*>("password");
        if(!password) throw std::runtime_error("Missing password element");

        sessions= root->findChild<QObject*>("sessions");
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
void Manager::quit()
{
    if(application) application->quit();
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
