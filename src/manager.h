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
    explicit Manager(const QString& config_path= QString(), QObject* parent= nullptr);
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

    void set_sess();
    QString get_sess();

    int startup(pam::context& context, x11::server& server, const QString& sess);
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // MANAGER_H
