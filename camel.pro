##############################
QT += core gui declarative

##############################
TARGET       = camel
TEMPLATE     = app

INCLUDEPATH  = ./lib ./src
LIBS         = -lc++ -lX11 -lpam

QMAKE_CXX    = clang++
QMAKE_CXXFLAGS = -std=c++11 -stdlib=libc++

##############################
SOURCES += src/main.cpp     \
    lib/log.cpp             \
    lib/x11.cpp             \
    lib/pam/pam.cpp         \
    lib/process/process.cpp \
    src/config.cpp          \
    src/credentials.cpp     \
    src/manager.cpp         \

HEADERS += \
    lib/errno_error.h       \
    lib/log.h               \
    lib/x11.h               \
    lib/pam/pam.h           \
    lib/pam/pam_error.h     \
    lib/pam/pam_type.h      \
    lib/process/process.h   \
    src/config.h            \
    src/credentials.h       \
    src/manager.h           \

OTHER_FILES += \
    theme/default/theme.qml \
