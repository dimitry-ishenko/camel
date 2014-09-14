///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef MANAGER_H
#define MANAGER_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "config.h"
#include "settings.h"
#include "x11/server.h"
#include "pam/pam.h"

#include <QObject>
#include <QString>

using namespace app;

///////////////////////////////////////////////////////////////////////////////////////////////////
class Manager: public QObject
{
    Q_OBJECT
public:
    explicit Manager(const QString& name, const QString& path, QObject* parent= nullptr);
    int run();

signals:
    void reset();
    void info(const QString& text);
    void error(const QString& text);

private slots:
    void login();
    void reboot();
    void poweroff();

private:
    Config config;
    Settings settings;

    x11::server server;
    pam::context context;

    void render();

    std::string _M_error;
    bool _M_login;

    int startup(const QString& sess);
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // MANAGER_H
