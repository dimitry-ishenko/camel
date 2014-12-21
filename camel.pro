########################################
QT += core gui declarative

########################################
TARGET       = camel
TEMPLATE     = app

INCLUDEPATH  = ./lib ./src
LIBS         = -lc++ -lX11 -lpam

QMAKE_CXX    = clang++
QMAKE_CXXFLAGS = -std=c++11 -stdlib=libc++ -Wno-deprecated-register

########################################
count(prefix, 1) {
    prefix = /$(DESTDIR)/$$prefix
} else {
    prefix = /$(DESTDIR)/usr/local
}

count(bindir, 1) {
    bindir = /$(DESTDIR)/$$bindir
} else {
    bindir = $$prefix/bin
}

count(sysconfdir, 1) {
    sysconfdir = /$(DESTDIR)/$$sysconfdir
} else {
    sysconfdir = $$prefix/etc
}

count(libdir, 1) {
    libdir = /$(DESTDIR)/$$libdir
} else {
    libdir = $$prefix/lib
}

count(datadir, 1) {
    datadir = /$(DESTDIR)/$$datadir
} else {
    datadir = $$prefix/share
}

########################################
target.path = $$bindir
INSTALLS += target

pam.files = pam/camel
pam.path = $$sysconfdir/pam.d
INSTALLS += pam

conf.files = camel.conf
conf.path = $$sysconfdir
INSTALLS += conf

service.files = camel.service
service.path = $$libdir/systemd/system
INSTALLS += service

theme.files = theme/*
theme.path = $$datadir/$$TARGET/theme
INSTALLS += theme

########################################
SOURCES += \
    lib/credentials/credentials.cpp \
    lib/logger/logger.cpp           \
    lib/pam/pam.cpp                 \
    lib/process/environ.cpp         \
    lib/process/arguments.cpp       \
    lib/process/process.cpp         \
    lib/x11/server.cpp              \
    src/config.cpp                  \
    src/main.cpp                    \
    src/manager.cpp                 \
    src/settings.cpp                \

HEADERS += \
    lib/charpp.hpp                  \
    lib/container.hpp               \
    lib/credentials/credentials.hpp \
    lib/enum.hpp                    \
    lib/errno_error.hpp             \
    lib/logger/logger.hpp           \
    lib/pam/pam.hpp                 \
    lib/pam/pam_error.hpp           \
    lib/pam/pam_type.hpp            \
    lib/process/arguments.hpp       \
    lib/process/environ.hpp         \
    lib/process/filebuf.hpp         \
    lib/process/process.hpp         \
    lib/string.hpp                  \
    lib/x11/server.hpp              \
    src/config.h                    \
    src/manager.h                   \
    src/settings.h                  \

OTHER_FILES += \
    AUTHORS                         \
    COPYING                         \
    INSTALL                         \
    NEWS                            \
    README                          \
    camel.conf                      \
    camel.service                   \
    configure                       \
    pam/camel                       \

########################################
# themes
########################################
OTHER_FILES += \
    theme/minimal/theme.qml         \

########################################
OTHER_FILES += \
    theme/simple/background.jpg     \
    theme/simple/theme.qml          \

########################################
OTHER_FILES += \
    theme/elarun/COPYRIGHT          \
    theme/elarun/background.png     \
    theme/elarun/lineedit_active.png\
    theme/elarun/lineedit_normal.png\
    theme/elarun/lock.png           \
    theme/elarun/login_active.png   \
    theme/elarun/login_normal.png   \
    theme/elarun/pw_icon.png        \
    theme/elarun/rectangle.png      \
    theme/elarun/rectangle_overlay.png \
    theme/elarun/session_normal.png \
    theme/elarun/sessions.png       \
    theme/elarun/system_normal.png  \
    theme/elarun/theme.qml          \
    theme/elarun/user_icon.png      \

########################################
OTHER_FILES += \
    theme/ariya/COPYRIGHT           \
    theme/ariya/background.png      \
    theme/ariya/lineedit_active.png \
    theme/ariya/lineedit_normal.png \
    theme/ariya/lock.png            \
    theme/ariya/login_active.png    \
    theme/ariya/login_normal.png    \
    theme/ariya/pw_icon.png         \
    theme/ariya/rectangle.png       \
    theme/ariya/rectangle_overlay.png \
    theme/ariya/session_normal.png  \
    theme/ariya/sessions.png        \
    theme/ariya/system_normal.png   \
    theme/ariya/theme.qml           \
    theme/ariya/user_icon.png       \

########################################
OTHER_FILES += \
    theme/redmond/background.png    \
    theme/redmond/login.png         \
    theme/redmond/login_active.png  \
    theme/redmond/menu_item_active.png \
    theme/redmond/password.png      \
    theme/redmond/password_active.png \
    theme/redmond/session.png       \
    theme/redmond/session_active.png\
    theme/redmond/system_menu.png   \
    theme/redmond/theme.qml         \
    theme/redmond/tile.png          \
