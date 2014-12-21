///////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2014 Dimitry Ishenko
// Distributed under the GNU GPL v2. For full terms please visit:
// http://www.gnu.org/licenses/gpl.html
//
// Contact: dimitry (dot) ishenko (at) (gee) mail (dot) com

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "settings.hpp"

///////////////////////////////////////////////////////////////////////////////////////////////////
void Settings::setIndex(int x)
{
    if(x >= 0 && x < _M_sessions.size())
    {
        _M_index = x;
        emit indexChanged(x);
        emit sessionChanged(session());
    }
    else if(x == 0 && _M_sessions.size() == 0)
    {
        _M_index = x;
        emit indexChanged(x);
        emit sessionChanged(QString());
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
const QString& Settings::session() const
{
    static QString none;
    return _M_sessions.size() ? _M_sessions[_M_index] : none;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Settings::nextSession()
{
    int x = _M_index + 1;
    if(x >= _M_sessions.size()) x = 0;

    setIndex(x);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Settings::prevSession()
{
    int x = _M_index - 1;
    if(x < 0) x = 0;

    setIndex(x);
}
