##############################
QT += core gui

##############################
TARGET       = camel
TEMPLATE     = app
VERSION      = 0.0.1

INCLUDEPATH  =
LIBS         = -lc++

QMAKE_CXX    = clang++
QMAKE_CXXFLAGS = -std=c++11 -stdlib=libc++

##############################
SOURCES += main.cpp     \
