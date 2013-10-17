///////////////////////////////////////////////////////////////////////////////////////////////////
#include "entree.h"
#include "except.h"
#include <string.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
namespace file
{

///////////////////////////////////////////////////////////////////////////////////////////////////
const filter filter_all= [] (const entree&) -> bool
    { return true; };

const compare compare_version= [] (const entree& e1, const entree& e2) -> int
    { return strverscmp(e1.name.data(), e2.name.data()); };

const compare compare_alpha= [] (const entree& e1, const entree& e2) -> int
    { return strcoll(e1.name.data(), e2.name.data()); };

///////////////////////////////////////////////////////////////////////////////////////////////////
entrees entree::get(const std::string& path, const filter f, const compare c)
{
    static filter _M_filter= f;
    static compare _M_compare= c;

    dirent** names= nullptr;

    int n= scandir(path.data(), &names,
        [] (const dirent* e) -> int { return _M_filter({ e->d_name, (enum type)e->d_type, e->d_ino }); },
        [] (const dirent** e1, const dirent** e2) -> int
        {
            return _M_compare( { (*e1)->d_name, (enum type)(*e1)->d_type, (*e1)->d_ino },
                               { (*e2)->d_name, (enum type)(*e2)->d_type, (*e2)->d_ino } );
        }
    );
    if(n>=0)
    {
        entrees entries;

        for(dirent** name= names; n; ++name, --n)
        {
            entries.push_back({ (*name)->d_name, (enum type)(*name)->d_type, (*name)->d_ino });
            free(*name);
        }

        free(names);
        return entries;
    }
    else
    {
        int e= errno;
        free(names);

        errno=e;
        throw system_except();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
}
