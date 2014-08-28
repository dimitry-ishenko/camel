///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef MANAGER_H
#define MANAGER_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "config.h"
#include "x11.h"
#include "pam/pam.h"

#include <QtDeclarative/QDeclarativeView>
#include <QApplication>
#include <QObject>
#include <QString>
#include <QSharedPointer>

///////////////////////////////////////////////////////////////////////////////////////////////////
class Manager: public QObject
{
    Q_OBJECT
public:
    explicit Manager(QString config_path= QString(), QObject* parent= nullptr);
    int run();

signals:
    void reset();
    void error(const QString&);

private slots:
    void quit();

private:
    Config config;
    X11::Server server;

    QSharedPointer<QApplication> application;
    QSharedPointer<pam::context> context;
    QSharedPointer<QDeclarativeView> view;

    QObject* username;
    QObject* password;

    QObject* sessions;
    QObject* session;

    QObject* hostname;

    void render();

    bool get_user(std::string&);
    bool get_pass(std::string&);
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // MANAGER_H
