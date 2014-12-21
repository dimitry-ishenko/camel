///////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2014 Dimitry Ishenko
// Distributed under the GNU GPL v2. For full terms please visit:
// http://www.gnu.org/licenses/gpl.html
//
// Contact: dimitry (dot) ishenko (at) (gee) mail (dot) com

///////////////////////////////////////////////////////////////////////////////////////////////////
#include "alsa_device.hpp"
#include "alsa_error.hpp"

///////////////////////////////////////////////////////////////////////////////////////////////////
namespace alsa
{

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
const std::error_category& alsa_category()
{
    static class alsa_category instance;
    return instance;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
std::string name(alsa::format format) noexcept
{
    return snd_pcm_format_name(static_cast<snd_pcm_format_t>(format));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
std::string description(alsa::format format) noexcept
{
    return snd_pcm_format_description(static_cast<snd_pcm_format_t>(format));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
alsa::format to_format(const std::string& name) noexcept
{
    return static_cast<alsa::format>(snd_pcm_format_value(name.data()));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
std::string name(alsa::access access) noexcept
{
    return snd_pcm_access_name(static_cast<snd_pcm_access_t>(access));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
device::device(const std::string& name, alsa::stream stream, alsa::mode mode)
{
    int code = snd_pcm_open(&_M_pcm, name.data(), static_cast<snd_pcm_stream_t>(stream), static_cast<int>(mode));
    if(code) throw alsa_error(code, "snd_pcm_open");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void device::close() noexcept
{
    if(_M_pcm)
    {
        snd_pcm_close(_M_pcm);
        _M_pcm = nullptr;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void device::set(alsa::format format, alsa::access access, unsigned channels, unsigned rate, bool resample, unsigned latency)
{
    int code = snd_pcm_set_params(_M_pcm,
                                  static_cast<snd_pcm_format_t>(format),
                                  static_cast<snd_pcm_access_t>(access),
                                  channels,
                                  rate,
                                  resample,
                                  latency);
    if(code) throw alsa_error(code, "snd_pcm_set_params");
}

///////////////////////////////////////////////////////////////////////////////////////////////////
alsa::frames device::period()
{
    alsa::frames buffer, period;

    int code = snd_pcm_get_params(_M_pcm, &buffer, &period);
    if(code) throw alsa_error(code, "snd_pcm_get_params");

    return period;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
unsigned device::frame_size()
{
    auto code = snd_pcm_frames_to_bytes(_M_pcm, 1);
    if(code < 0) throw alsa_error(code, "snd_pcm_frames_to_bytes");

    return code;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
alsa::frames device::read(void* buffer, alsa::frames frames)
{
    int code = snd_pcm_readi(_M_pcm, buffer, frames);
    if(code < 0) throw alsa_error(code, "snd_pcm_readi");

    return code;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
alsa::frames device::write(void* buffer, alsa::frames frames)
{
    int code = snd_pcm_writei(_M_pcm, buffer, frames);
    if(code < 0) throw alsa_error(code, "snd_pcm_writei");

    return code;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
bool device::recover(int code, bool silent) noexcept
{
    return !snd_pcm_recover(_M_pcm, code, silent);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
}
