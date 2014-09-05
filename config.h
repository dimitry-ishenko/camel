///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef CONFIG_H
#define CONFIG_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include <QStringList>
#include <QString>

#include <string>
#include <vector>

///////////////////////////////////////////////////////////////////////////////////////////////////
struct Config
{
    QString path= "/etc/camel.conf";

    // X server settings
    std::string server_path;
    std::string server_auth= "/run/camel.auth";
    std::vector<std::string> server_args;

    // PAM settings
    std::string service= "camel";

    // session settings
    QString sessions_path= "/etc/X11/Sessions";
    QStringList sessions;

    std::string reboot= "/sbin/reboot";
    std::string poweroff= "/sbin/poweroff";

    // theme settings
    QString theme_path= "/usr/share/camel/theme";
    QString theme_name= "default";
    QString theme_file= "theme.qml";

    void parse();
};

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // CONFIG_H
