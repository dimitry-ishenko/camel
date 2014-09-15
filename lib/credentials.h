///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef CREDENTIALS_H
#define CREDENTIALS_H

///////////////////////////////////////////////////////////////////////////////////////////////////
#include <string>
#include <set>
#include <sys/types.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
struct passwd;

///////////////////////////////////////////////////////////////////////////////////////////////////
namespace app
{

///////////////////////////////////////////////////////////////////////////////////////////////////
typedef uid_t uid;
typedef gid_t gid;
typedef std::set<gid> groups;

constexpr uid invalid_uid= -1;
constexpr gid invalid_gid= -1;

///////////////////////////////////////////////////////////////////////////////////////////////////
class credentials
{
public:
    credentials() = default;
    credentials(const credentials&) = default;
    credentials(credentials&&) = default;

    credentials& operator=(const credentials&) = default;
    credentials& operator=(credentials&&) = default;

    explicit credentials(app::uid uid):
        _M_uid(uid)
    { }
    explicit credentials(const std::string& name):
        _M_name(name)
    { }

    std::string username() const;
    std::string fullname() const;
    std::string password() const;

    app::uid uid() const;
    app::uid gid() const;

    std::string home() const;
    std::string shell() const;
    app::groups groups() const;

    void morph_into() const;

private:
    std::string _M_name;
    app::uid _M_uid;
};

///////////////////////////////////////////////////////////////////////////////////////////////////
namespace this_user
{

///////////////////////////////////////////////////////////////////////////////////////////////////
app::uid real_uid() noexcept;
app::gid real_gid() noexcept;

app::uid effective_uid() noexcept;
app::gid effective_gid() noexcept;

app::uid saved_uid() noexcept;
app::gid saved_gid() noexcept;

///////////////////////////////////////////////////////////////////////////////////////////////////
std::string username();
std::string fullname();
std::string password();

inline app::uid uid() noexcept { return real_uid(); }
inline app::gid gid() noexcept { return real_gid(); }

std::string home();
std::string shell();
app::groups groups();

///////////////////////////////////////////////////////////////////////////////////////////////////
}

///////////////////////////////////////////////////////////////////////////////////////////////////
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // CREDENTIALS_H
