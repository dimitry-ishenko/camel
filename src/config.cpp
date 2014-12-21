///////////////////////////////////////////////////////////////////////////////////////////////////
#include "config.hpp"

#include <QFile>

#include <algorithm>
#include <stdexcept>

///////////////////////////////////////////////////////////////////////////////////////////////////
void Config::parse()
{
    QFile file(path);
    if(!file.open(QIODevice::ReadOnly | QIODevice::Text)) throw std::runtime_error("Could not open config file");

    while(!file.atEnd())
    {
        QString line= file.readLine().trimmed();
        if(line.isEmpty() || line[0] == '#') continue;

        int pos= line.indexOf('=');
        if(pos < 0) throw std::runtime_error("Syntax error in config file");

        QString name= line.left(pos).trimmed();
        QString value= line.mid(pos+1).trimmed();

        if(name.isEmpty()) throw std::runtime_error("Name cannot be empty");
        if(value.isEmpty()) throw std::runtime_error("Value cannot be empty");

        if(name == "xorg_name")
            xorg_name= value.toStdString();

        else if(name == "xorg_args")
        {
            QStringList args= value.split(' ', QString::SkipEmptyParts);

            xorg_args.clear();
            std::transform(args.begin(), args.end(), xorg_args.end(), [](const QString& x) { return x.toStdString(); });
        }
        else if(name == "xorg_auth")
            xorg_auth= value.toStdString();

        else if(name == "pam_service")
            pam_service= value.toStdString();

        else if(name == "sessions_path")
            sessions_path= value;

        else if(name == "sessions")
            sessions= value.split(QRegExp(" *, *"), QString::SkipEmptyParts);

        else if(name == "reboot")
            reboot= value.toStdString();

        else if(name == "poweroff")
            poweroff= value.toStdString();

        else if(name == "theme_path")
            theme_path= value;

        else if(name == "theme_name")
            theme_name= value;

        else if(name == "theme_file")
            theme_file= value;
    }
}
