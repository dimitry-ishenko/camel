///////////////////////////////////////////////////////////////////////////////////////////////////
#include "manager.h"
#include <string>
#include <iostream>

///////////////////////////////////////////////////////////////////////////////////////////////////
const std::string usage= "Usage: camel [ -h | --help | <path-to-config-file> ]";

///////////////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char* argv[])
{
    if(argc > 2)
    {
        std::cerr << usage << std::endl;
        return 1;
    }

    QString arg;
    if(argc==2)
    {
        arg= argv[1];
        if(arg == "-h" || arg == "--help")
        {
            std::cout << usage << std::endl;
            return 0;
        }
    }

    return Manager(arg).exec();
}
