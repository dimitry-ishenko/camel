///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef MANAGER_H
#define MANAGER_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "config.h"

#include <QObject>
#include <QString>

///////////////////////////////////////////////////////////////////////////////////////////////////
class QApplication;
namespace app { namespace pam { class context; } }

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
    void error(const QString&);

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

    void store(pam::context&);
    int startup(pam::context&, const QString& sess);
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // MANAGER_H
