///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include "logger.h"

#include <QDesktopWidget>
#include <QGraphicsObject>
#include <QtNetwork/QHostInfo>
#include <QDir>
#include <QFile>

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
        context->set_item(pam::item::ruser, "root");
        context->set_item(pam::item::tty, server.name().toStdString());

        application= QSharedPointer<QApplication>(new QApplication(server.display()));

        while(true)
        {
            render();
            application->exec();
        }

        return 0;
    }
    catch(std::exception& e)
    {
        std::cerr << e.what() << std::endl;
        sys::logger << sys::error << e.what();
        return 1;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::render()
{
    username= password= exec= error= nullptr;
    view.clear();

    QString current= QDir::currentPath();
    try
    {
        if(!QDir::setCurrent(config.theme_path+ "/"+ config.theme_name))
            throw std::runtime_error("Theme dir "+ config.theme_name.toStdString()+ " not found");

        if(!QFile::exists(config.theme_file))
            throw std::runtime_error("Theme file "+ config.theme_file.toStdString()+ " not found");

        view= QSharedPointer<QDeclarativeView>(new QDeclarativeView(QUrl::fromLocalFile(config.theme_file)));
        view->setGeometry(application->desktop()->screenGeometry());
        view->show();

        QGraphicsObject* root= view->rootObject();
        connect(root, SIGNAL(login()), application.data(), SLOT(quit()));

        username= root->findChild<QObject*>("username");
        if(!username) throw std::runtime_error("Missing username element");

        password= root->findChild<QObject*>("password");
        if(!password) throw std::runtime_error("Missing password element");

        exec= root->findChild<QObject*>("exec");
        error= root->findChild<QObject*>("error");
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
