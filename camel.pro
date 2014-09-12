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
!isEmpty(DESTDIR) {
    ROOTDIR = $$DESTDIR
    DESTDIR =
}
isEmpty(PREFIX) {
    PREFIX = /usr/local
}
isEmpty(BINDIR) {
    BINDIR = $$PREFIX/bin
}
isEmpty(SYSCONFIGDIR) {
    SYSCONFIGDIR = $$PREFIX/etc
}
isEmpty(LIBDIR) {
    LIBDIR = $$PREFIX/lib
}
isEmpty(DATADIR) {
    DATADIR = $$PREFIX/share
}

target.path = $$ROOTDIR/$$BINDIR
INSTALLS += target

pam.files = pam/camel
pam.path = $$ROOTDIR/$$SYSCONFDIR/pam.d
INSTALLS += pam

conf.files = camel.conf
conf.path = $$ROOTDIR/$$SYSCONFDIR
INSTALLS += conf

service.files = camel.service
service.path = $$ROOTDIR/$$LIBDIR/systemd/system
INSTALLS += service

theme.files = theme/*
theme.path = $$ROOTDIR/$$DATADIR/$$TARGET/theme
INSTALLS += theme

########################################
SOURCES += \
    lib/log.cpp                     \
    lib/utility.cpp                 \
    lib/pam/pam.cpp                 \
    lib/environ.cpp                 \
    lib/arguments.cpp               \
    lib/process/process.cpp         \
    lib/x11/server.cpp              \
    src/config.cpp                  \
    src/credentials.cpp             \
    src/manager.cpp                 \
    src/main.cpp                    \

HEADERS += \
    lib/errno_error.h               \
    lib/log.h                       \
    lib/utility.h                   \
    lib/wrapper.h                   \
    lib/pam/pam.h                   \
    lib/pam/pam_error.h             \
    lib/pam/pam_type.h              \
    lib/basic_filebuf.h             \
    lib/flags.h                     \
    lib/environ.h                   \
    lib/arguments.h                 \
    lib/process/process.h           \
    lib/x11/server.h                \
    src/config.h                    \
    src/credentials.h               \
    src/manager.h                   \

OTHER_FILES += \
    pam/camel                       \
    camel.conf                      \
    camel.service                   \
    COPYING                         \
    README                          \
    AUTHORS                         \

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
    theme/redmond/username_active.png \
    theme/redmond/username.png      \
    theme/redmond/tile.png          \
    theme/redmond/system_menu.png   \
    theme/redmond/session_active.png\
    theme/redmond/session.png       \
    theme/redmond/power_active.png  \
    theme/redmond/power.png         \
    theme/redmond/password_active.png \
    theme/redmond/password.png      \
    theme/redmond/menu_item_active.png \
    theme/redmond/login_active.png  \
    theme/redmond/login.png         \
    theme/redmond/background.png    \
    theme/redmond/theme.qml         \
