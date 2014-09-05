///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef MANAGER_H
#define MANAGER_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "config.h"
#include "process/process.h"
#include "credentials.h"

#include <QObject>
#include <QString>

///////////////////////////////////////////////////////////////////////////////////////////////////
class QApplication;

using namespace app;

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

    int startup(credentials&, environment&, const QString& sess);
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // MANAGER_H
