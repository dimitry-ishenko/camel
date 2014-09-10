///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef CONFIG_H
#define CONFIG_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "arguments.h"

#include <QStringList>
#include <QString>
#include <string>

///////////////////////////////////////////////////////////////////////////////////////////////////
struct Config
{
    QString path= "/etc/camel.conf";

    // X server settings
    std::string xorg_name;
    app::arguments xorg_args= { "-br", "-novtswitch", "-nolisten", "tcp", "-quiet" };
    std::string xorg_auth= "/run/camel.auth";

    // PAM settings
    std::string pam_service= "camel";

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
