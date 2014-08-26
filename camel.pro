##############################
QT += core gui declarative

##############################
TARGET       = camel
TEMPLATE     = app

INCLUDEPATH  =
LIBS         = -lc++ -lX11

QMAKE_CXX    = clang++
QMAKE_CXXFLAGS = -std=c++11 -stdlib=libc++

##############################
SOURCES += main.cpp     \
    logger.cpp          \
    x11.cpp             \
    config.cpp          \
    manager.cpp         \

HEADERS += \
    logger.h            \
    x11.h               \
    config.h            \
    manager.h           \

OTHER_FILES += \
    default/theme.qml   \
