///////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2014 Dimitry Ishenko
// Distributed under the GNU GPL v2. For full terms please visit:
// http://www.gnu.org/licenses/gpl.html
//
// Contact: dimitry (dot) ishenko (at) (gee) mail (dot) com

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.hpp"

#include <iostream>
#include <string>

///////////////////////////////////////////////////////////////////////////////////////////////////
const std::string usage = "Usage: camel [-h|--help]\n"
                          "       camel [:n] [<path-to-config-file>]";

///////////////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char* argv[])
{
    if(argc > 3)
    {
        std::cerr << usage << std::endl;
        return 1;
    }

    QString name, path;
    for(int n = 1; n < argc; ++n)
    {
        QString arg(argv[n]);
        if(arg == "-h" || arg == "--help")
        {
            std::cout << usage << std::endl;
            return 0;
        }
        else if(arg[0] == ':')
        {
            name = arg;
        }
        else path = arg;
    }

    return Manager(name, path).run();
}
