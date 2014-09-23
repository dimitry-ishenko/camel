///////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2013-2014 Dimitry Ishenko
// Distributed under the GNU GPL v2. For full terms please visit:
// http://www.gnu.org/licenses/gpl.html
//
// Contact: dimitry (dot) ishenko (at) (gee) mail (dot) com

///////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef FLAGS_H
#define FLAGS_H

///////////////////////////////////////////////////////////////////////////////////////////////////
template<typename Enum>
class flags
{
public:
    constexpr flags() noexcept: _M_value(0) { }
    constexpr flags(const flags& x) noexcept: _M_value(x._M_value) { }
    constexpr flags(Enum x) noexcept: _M_value(static_cast<int>(x)) { }

    ////////////////////
    constexpr bool contains(flags x) const noexcept { return (_M_value & x._M_value) == x._M_value && (x._M_value || !_M_value); }
    constexpr bool contains(Enum x)  const noexcept { return contains(flags(x)); }

    constexpr bool empty() const noexcept { return _M_value; }
    void clear() noexcept { _M_value=0; }

    constexpr operator int() const noexcept { return _M_value; }

    ////////////////////
    constexpr flags operator&(flags x) const noexcept { return flags(_M_value & x._M_value); }
    constexpr flags operator|(flags x) const noexcept { return flags(_M_value | x._M_value); }
    constexpr flags operator^(flags x) const noexcept { return flags(_M_value ^ x._M_value); }

    constexpr flags operator~()        const noexcept { return flags(~_M_value); }

    constexpr bool operator==(flags x) const noexcept { return _M_value == x._M_value; }
    constexpr bool operator!=(flags x) const noexcept { return _M_value != x._M_value; }

    ////////////////////
    flags& operator =(flags x) noexcept { _M_value = x._M_value; return (*this); }
    flags& operator =(Enum y)  noexcept { return (*this) = flags(y); }
    flags& operator&=(flags x) noexcept { _M_value&= x._M_value; return (*this); }
    flags& operator&=(Enum y)  noexcept { return (*this)&= flags(y); }
    flags& operator|=(flags x) noexcept { _M_value|= x._M_value; return (*this); }
    flags& operator|=(Enum y)  noexcept { return (*this)|= flags(y); }
    flags& operator^=(flags x) noexcept { _M_value^= x._M_value; return (*this); }
    flags& operator^=(Enum y)  noexcept { return (*this)^= flags(y); }

    constexpr explicit flags(int x) noexcept: _M_value(x) { }

private:
    int _M_value;
};

#define DECLARE_FLAGS_TYPE(Enum) typedef flags<Enum> Enum##_flags;
#define DECLARE_FLAGS_OPERATOR(Enum) \
    constexpr Enum##_flags operator&(Enum##_flags x, Enum y) noexcept { return x & Enum##_flags(y); } \
    constexpr Enum##_flags operator&(Enum x, Enum##_flags y) noexcept { return y & x; } \
    constexpr Enum##_flags operator&(Enum x, Enum y)         noexcept { return Enum##_flags(x) & y; } \
    constexpr Enum##_flags operator|(Enum##_flags x, Enum y) noexcept { return x | Enum##_flags(y); } \
    constexpr Enum##_flags operator|(Enum x, Enum##_flags y) noexcept { return y | x; } \
    constexpr Enum##_flags operator|(Enum x, Enum y)         noexcept { return Enum##_flags(x) | y; } \
    constexpr Enum##_flags operator^(Enum##_flags x, Enum y) noexcept { return x ^ Enum##_flags(y); } \
    constexpr Enum##_flags operator^(Enum x, Enum##_flags y) noexcept { return y ^ x; } \
    constexpr Enum##_flags operator^(Enum x, Enum y)         noexcept { return Enum##_flags(x) ^ y; } \
    constexpr Enum##_flags operator~(Enum x) noexcept { return ~Enum##_flags(x); } \
    constexpr bool operator==(Enum##_flags x, Enum y) noexcept { return x == Enum##_flags(y); } \
    constexpr bool operator==(Enum x, Enum##_flags y) noexcept { return y == x; } \
    constexpr bool operator==(Enum x, Enum y)         noexcept { return Enum##_flags(x) == y; } \
    constexpr bool operator!=(Enum##_flags x, Enum y) noexcept { return x != Enum##_flags(y); } \
    constexpr bool operator!=(Enum x, Enum##_flags y) noexcept { return y != x; } \
    constexpr bool operator!=(Enum x, Enum y)         noexcept { return Enum##_flags(x) != y; } \

#define DECLARE_FLAGS(Enum) DECLARE_FLAGS_TYPE(Enum) DECLARE_FLAGS_OPERATOR(Enum)

///////////////////////////////////////////////////////////////////////////////////////////////////
#endif // FLAGS_H
