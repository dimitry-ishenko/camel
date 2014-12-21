///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef MANAGER_HPP
#define MANAGER_HPP

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "config.hpp"
#include "pam/pam.hpp"
#include "settings.hpp"
#include "x11/server.hpp"

#include <QObject>
#include <QString>
#include <QVariant>

#include <exception>

using namespace app;

///////////////////////////////////////////////////////////////////////////////////////////////////
class Manager: public QObject
{
    Q_OBJECT
public:
    explicit Manager(const QString& name, const QString& path, QObject* parent = nullptr);
    int run();

    static constexpr int code_enter = 0;
    static constexpr int code_cancel = 1;

signals:
    void info(const QVariant& message);
    void error(const QVariant& message);

    void enter_user_pass(const QVariant& message = QVariant());
    void enter_pass(const QVariant& message = QVariant());

private slots:
    void enter();
    void cancel();
    void reboot();
    void poweroff();

private:
    Config config;
    Settings settings;

    x11::server server;
    pam::context context;

    void render();

    bool do_respond = false;
    bool response(const std::string& message);

    bool password(const std::string& message, std::string& value);
    bool authenticate();

    bool change_password();
    int startup(const QString& session);

    std::exception_ptr exception = nullptr;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // MANAGER_HPP
