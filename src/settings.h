///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef SETTINGS_H
#define SETTINGS_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include <QObject>
#include <QStringList>
#include <QString>

///////////////////////////////////////////////////////////////////////////////////////////////////
class Settings: public QObject
{
    Q_OBJECT
public:
    explicit Settings(QObject* parent= nullptr): QObject(parent) { }

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

signals:
    void sessionsChanged(const QStringList&);
    void indexChanged(int);
    void sessionChanged(const QString&);

    void usernameChanged(const QString&);
    void passwordChanged(const QString&);

public slots:
    void resetSession() { setIndex(0); }

    void nextSession();
    void prevSession();

private:
    QStringList _M_sessions;
    int _M_index;

    QString _M_username;
    QString _M_password;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // SETTINGS_H
