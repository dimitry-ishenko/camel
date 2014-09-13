///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef MANAGER_H
#define MANAGER_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "config.h"
#include "x11/server.h"
#include "pam/pam.h"

#include <QObject>
#include <QString>

using namespace app;

///////////////////////////////////////////////////////////////////////////////////////////////////
class QApplication;

///////////////////////////////////////////////////////////////////////////////////////////////////
class Manager: public QObject
{
    Q_OBJECT
public:
    explicit Manager(const QString& name, const QString& path, QObject* parent= nullptr);
    int run();

signals:
    void reset();
    void error(const QString& text);

private:
    Config config;

    QObject* username;
    QObject* password;

    QObject* sessions;
    QObject* session;

    QObject* hostname;

    void render(QApplication&);

    bool get_user(std::string&);
    bool get_pass(std::string&);

    std::string _M_error;
    const std::string& get_error() const { return _M_error; }
    bool set_error(const std::string& x)
    {
        _M_error= x;
        return true;
    }
    void reset_error() { _M_error.clear(); }

    void set_sess();
    QString get_sess();

    int startup(pam::context& context, x11::server& server, const QString& sess);
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // MANAGER_H
