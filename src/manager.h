///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef MANAGER_H
#define MANAGER_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "config.h"
#include "settings.h"
#include "x11/server.h"
#include "pam/pam.h"

#include <QApplication>
#include <QObject>
#include <QString>

#include <memory>

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
    void error(const QString& text);

private:
    Config config;
    Settings settings;

    std::unique_ptr<x11::server> server;
    std::unique_ptr<pam::context> context;
    std::unique_ptr<QApplication> application;

    void render();

    std::string _M_error;
    const std::string& get_error() const { return _M_error; }
    bool set_error(const std::string& x)
    {
        _M_error= x;
        return true;
    }
    void reset_error() { _M_error.clear(); }

    bool try_auth();

    int startup(const QString& sess);
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // MANAGER_H
