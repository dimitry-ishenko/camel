///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include "credentials.h"
#include "pam/pam_error.h"
#include "environ.h"
#include "log.h"

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
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::run()
{
    int code=0;
    try
    {
        server.reset(new x11::server(config.xorg_name, config.xorg_auth, config.xorg_args));

        context.reset(new pam::context(config.pam_service));
        context->set_user_func (std::bind(&Manager::get_user,  this, std::placeholders::_1));
        context->set_pass_func (std::bind(&Manager::get_pass,  this, std::placeholders::_1));
        context->set_error_func(std::bind(&Manager::set_error, this, std::placeholders::_1));

        context->set(pam::item::ruser, "root");
        context->set(pam::item::tty, server->name());

        application.reset(new QApplication(server->display()));
        render();

        QString sess;
        while(true)
        {
            emit reset();
            application->exec();

            sess= settings.session();
            if(!sess.size()) sess= "Xsession";

            try
            {
                if(sess == "reboot")
                    this_process::execute(config.reboot);

                else if(sess == "poweroff")
                    this_process::execute(config.poweroff);

                else if(try_auth())
                    break;
            }
            catch(execute_error& e)
            {
                emit error(e.what());
                logger << e.what() << std::endl;
            }
        }

        application.reset();

        context->open_session();

        app::process process(process::group, &Manager::startup, this, sess);
        process.join();

        context->close_session();
    }
    catch(std::exception& e)
    {
        logger << log::error << e.what() << std::endl;
        code=1;
    }

    application.reset();
    context.reset();
    server.reset();

    return code;
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

        QDeclarativeView* view= new QDeclarativeView(application->desktop());
        view->rootContext()->setContextProperty("settings", &settings);
        view->setSource(QUrl::fromLocalFile(config.theme_file));
        view->setGeometry(QApplication::desktop()->screenGeometry());

        QGraphicsObject* root= view->rootObject();
        root->setProperty("width", view->width());
        root->setProperty("height", view->height());

        connect(this, SIGNAL(reset()), root, SIGNAL(reset()));
        connect(this, SIGNAL(error(QString)), root, SIGNAL(error(QString)));
        connect(root, SIGNAL(quit()), application.get(), SLOT(quit()));

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
bool Manager::get_user(std::string& value)
{
    value= settings.username().toStdString();
    return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool Manager::get_pass(std::string& value)
{
    value= settings.password().toStdString();
    return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool Manager::try_auth()
{
    try
    {
        try
        {
            context->reset(pam::item::user);
            reset_error();
            context->authenticate();

            return true;
        }
        catch(pam::account_error& e)
        {
            throw;
        }
    }
    catch(pam::pamh_error& e)
    {
        std::string x= get_error();
        if(x.empty()) x= e.what();

        emit error(x.data());
        logger << x << std::endl;
    }
    return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
int Manager::startup(const QString& sess)
{
    credentials c(context->get(pam::item::user));
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

    e.set("DISPLAY", context->get(pam::item::tty));
    e.set("XAUTHORITY", auth);

    c.morph_into();
    server->set_cookie(auth);

    this_process::replace_e(e, (config.sessions_path+ "/"+ sess).toStdString());
    return 0;
}
