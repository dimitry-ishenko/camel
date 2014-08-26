///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include "logger.h"

#include <QApplication>
#include <QDesktopWidget>
#include <QtDeclarative/QDeclarativeView>
#include <QGraphicsObject>
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
int Manager::exec()
{
    try
    {
        config.parse();

        if(config.server_path.size()) server.set_path(config.server_path);
        if(config.server_auth.size()) server.set_auth(config.server_auth);
        if(config.server_args.size()) server.set_args(config.server_args);

        if(!server.start()) throw std::runtime_error("X server failed to start");

        render();

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
    if(!QDir::setCurrent(config.theme_path+ "/"+ config.theme_name))
        throw std::runtime_error("Theme dir "+ config.theme_name.toStdString()+ " not found");

    if(!QFile::exists(config.theme_file))
        throw std::runtime_error("Theme file "+ config.theme_file.toStdString()+ " not found");

    QApplication app(server.display());
    QDeclarativeView widget(QUrl::fromLocalFile(config.theme_file));

    QObject* root= widget.rootObject();
    root->connect(root, SIGNAL(cred(QString,QString)), this, SLOT(get_cred(QString,QString)));
    root->connect(root, SIGNAL(cred(QString,QString)), &app, SLOT(quit()));

    widget.setGeometry(QApplication::desktop()->screenGeometry());
    widget.show();

    app.exec();
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Manager::get_cred(const QString& _username, const QString& _password)
{
    username= _username;
    password= _password;
}
