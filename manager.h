///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef MANAGER_H
#define MANAGER_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "config.h"
#include "x11.h"
#include "pam/pam.h"

#include <QDeclarativeView>
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

private:
    Config config;
    X11::Server server;

    QSharedPointer<QApplication> application;
    QSharedPointer<pam::context> context;
    QSharedPointer<QDeclarativeView> view;

    QObject* username;
    QObject* password;

    QObject* exec;
    QObject* error;

    void render();
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // MANAGER_H
