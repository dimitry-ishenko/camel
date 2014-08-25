##############################
QT += core gui

##############################
TARGET       = camel
TEMPLATE     = app
VERSION      = 0.0.1

INCLUDEPATH  =
LIBS         = -lc++ -lX11

QMAKE_CXX    = clang++
QMAKE_CXXFLAGS = -std=c++11 -stdlib=libc++

##############################
SOURCES += main.cpp \
    logger.cpp      \
    x11.cpp         \

HEADERS += \
    logger.h        \
    x11.h           \
