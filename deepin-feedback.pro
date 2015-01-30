TEMPLATE = app

QT += qml quick widgets gui

SOURCES += src/main.cpp \
    src/qmlloader.cpp

RESOURCES += src/views.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

HEADERS += \
    src/qmlloader.h
