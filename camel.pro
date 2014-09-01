##############################
QT += core gui declarative

##############################
TARGET       = camel
TEMPLATE     = app

INCLUDEPATH  =
LIBS         = -lc++ -lX11 -lpam

QMAKE_CXX    = clang++
QMAKE_CXXFLAGS = -std=c++11 -stdlib=libc++

##############################
SOURCES += main.cpp     \
    log.cpp             \
    x11.cpp             \
    config.cpp          \
    manager.cpp         \
    pam/pam.cpp         \
    process/process.cpp \

HEADERS += \
    log.h               \
    x11.h               \
    config.h            \
    manager.h           \
    pam/pam.h           \
    pam/pam_error.h     \
    pam/pam_type.h      \
    errno_error.h       \
    process/process.h   \

OTHER_FILES += \
    default/theme.qml   \
