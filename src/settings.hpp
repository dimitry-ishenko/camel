///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef SETTINGS_HPP
#define SETTINGS_HPP

///////////////////////////////////////////////////////////////////////////////////////////////////
#include <QDateTime>
#include <QObject>
#include <QString>
#include <QStringList>

///////////////////////////////////////////////////////////////////////////////////////////////////
class Settings: public QObject
{
    Q_OBJECT
public:
    explicit Settings(QObject* parent= nullptr): QObject(parent) { }

    ////////////////////
    Q_PROPERTY(QStringList sessions READ sessions NOTIFY sessionsChanged)
    const QStringList& sessions() const { return _M_sessions; }
    void setSessions(const QStringList& x)
    {
        _M_sessions= x;
        emit sessionsChanged(x);

        resetSession();
    }

    Q_PROPERTY(int index READ index WRITE setIndex NOTIFY indexChanged)
    int index() const { return _M_index; }
    void setIndex(int x);

    Q_PROPERTY(QString session READ session NOTIFY sessionChanged)
    const QString& session() const;

    ////////////////////
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    const QString& username() const { return _M_username; }
    void setUsername(const QString& x)
    {
        _M_username= x;
        emit usernameChanged(x);
    }

    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    const QString& password() const { return _M_password; }
    void setPassword(const QString& x)
    {
        _M_password= x;
        emit passwordChanged(x);
    }

    ////////////////////
    Q_PROPERTY(QString password_n READ password_n WRITE setPassword_n NOTIFY password_nChanged)
    const QString& password_n() const { return _M_password_n; }
    void setPassword_n(const QString& x)
    {
        _M_password_n= x;
        emit password_nChanged(x);
    }

    ////////////////////
    Q_PROPERTY(QString hostname READ hostname NOTIFY hostnameChanged)
    const QString& hostname() const { return _M_hostname; }
    void setHostname(const QString& x)
    {
        _M_hostname= x;
        emit hostnameChanged(x);
    }

    Q_PROPERTY(QDateTime datetime READ datetime)
    QDateTime datetime() const { return QDateTime::currentDateTime(); }

    Q_PROPERTY(QDate date READ date)
    QDate date() const { return QDate::currentDate(); }

    Q_PROPERTY(QTime time READ time)
    QTime time() const { return QTime::currentTime(); }

signals:
    void sessionsChanged(const QStringList&);
    void indexChanged(int);
    void sessionChanged(const QString&);

    void usernameChanged(const QString&);
    void passwordChanged(const QString&);
    void hostnameChanged(const QString&);

    void password_nChanged(const QString&);

public slots:
    void resetSession() { setIndex(0); }

    void nextSession();
    void prevSession();

private:
    QStringList _M_sessions;
    int _M_index;

    QString _M_username;
    QString _M_password, _M_password_n;
    QString _M_hostname;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // SETTINGS_HPP
