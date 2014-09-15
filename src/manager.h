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
    void reset_pass();

    void info(const QVariant& text);
    void error(const QVariant& text);

private slots:
    void login();
    void change_pass();
    void reboot();
    void poweroff();

private:
    Config config;
    Settings settings;

    x11::server server;
    pam::context context;

    void render();

    bool username(const std::string& message, std::string& value);
    bool password(const std::string& message, std::string& value);

    bool _M_login;

    int startup(const QString& sess);
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // MANAGER_H
