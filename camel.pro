########################################
QT += core gui declarative

########################################
TARGET       = camel
TEMPLATE     = app

INCLUDEPATH  = ./lib ./src
LIBS         = -lc++ -lX11 -lpam

QMAKE_CXX    = clang++
QMAKE_CXXFLAGS = -std=c++11 -stdlib=libc++

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
    lib/logger/logger.cpp           \
    lib/pam/pam.cpp                 \
    lib/process/environ.cpp         \
    lib/process/arguments.cpp       \
    lib/process/process.cpp         \
    lib/x11/server.cpp              \
    lib/credentials/credentials.cpp \
    src/config.cpp                  \
    src/settings.cpp                \
    src/manager.cpp                 \
    src/main.cpp                    \

HEADERS += \
    lib/errno_error.h               \
    lib/logger/logger.h             \
    lib/utility.h                   \
    lib/container.h                 \
    lib/pam/pam.h                   \
    lib/pam/pam_error.h             \
    lib/pam/pam_type.h              \
    lib/basic_filebuf.h             \
    lib/enum.h                      \
    lib/process/environ.h           \
    lib/process/arguments.h         \
    lib/process/process.h           \
    lib/x11/server.h                \
    lib/credentials/credentials.h   \
    src/config.h                    \
    src/settings.h                  \
    src/manager.h                   \

OTHER_FILES += \
    pam/camel                       \
    camel.conf                      \
    camel.service                   \
    AUTHORS                         \
    COPYING                         \
    INSTALL                         \
    NEWS                            \
    README                          \

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
    theme/elarun/user_icon.png      \
    theme/elarun/system_normal.png  \
    theme/elarun/session_normal.png \
    theme/elarun/rectangle_overlay.png \
    theme/elarun/rectangle.png      \
    theme/elarun/pw_icon.png        \
    theme/elarun/login_normal.png   \
    theme/elarun/login_active.png   \
    theme/elarun/lock.png           \
    theme/elarun/lineedit_normal.png\
    theme/elarun/lineedit_active.png\
    theme/elarun/COPYRIGHT          \
    theme/elarun/background.png     \
    theme/elarun/sessions.png       \
    theme/elarun/theme.qml          \

########################################
OTHER_FILES += \
    theme/ariya/user_icon.png       \
    theme/ariya/system_normal.png   \
    theme/ariya/sessions.png        \
    theme/ariya/session_normal.png  \
    theme/ariya/rectangle_overlay.png \
    theme/ariya/rectangle.png       \
    theme/ariya/pw_icon.png         \
    theme/ariya/login_normal.png    \
    theme/ariya/login_active.png    \
    theme/ariya/lock.png            \
    theme/ariya/lineedit_normal.png \
    theme/ariya/lineedit_active.png \
    theme/ariya/COPYRIGHT           \
    theme/ariya/background.png      \
    theme/ariya/theme.qml           \

########################################
OTHER_FILES += \
    theme/redmond/tile.png          \
    theme/redmond/system_menu.png   \
    theme/redmond/session_active.png\
    theme/redmond/session.png       \
    theme/redmond/password_active.png \
    theme/redmond/password.png      \
    theme/redmond/menu_item_active.png \
    theme/redmond/login_active.png  \
    theme/redmond/login.png         \
    theme/redmond/background.png    \
    theme/redmond/theme.qml         \
