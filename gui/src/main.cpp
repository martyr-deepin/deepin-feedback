#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "qmlloader.h"
#include "dataconverter.h"
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDebug>

void showVersion()
{
    qDebug() << "1.0";
}

void showHelpTip()
{
    qWarning() << "Usage:";
    qWarning() << "\tdeepin-feedback  \t\t\tDo not specify a target_app";
    qWarning() << "\tdeepin-feedback -v   \t\t\tPrint version";
    qWarning() << "\tdeepin-feedback -h   \t\t\tShow this message";
    qWarning() << "\tdeepin-feedback -t <target_app>\t\tReport target_app's bug\n";
}


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    if(QDBusConnection::sessionBus().registerService(DBUS_NAME)){

        qmlRegisterType<DataConverter>("DataConverter", 1, 0, "DataConverter");

        QmlLoader* qmlLoader = new QmlLoader();
        qmlLoader->rootContext->setContextProperty("mainObject", qmlLoader);
        qmlLoader->load(QUrl(QStringLiteral("qrc:/views/main.qml")));
        QObject::connect(qmlLoader->engine, SIGNAL(quit()), QApplication::instance(), SLOT(quit()));


        if(argc == 2)
        {
            QString order = argv[1];
            if(order == "-v" || order == "--version")
            {
                showVersion();
            }
            else
            {
                showHelpTip();
            }
            return 0;
        }
        else if (argc == 1)
        {
            //TODO  clear project
            qmlLoader->reportBug();
        }
        else if (argc == 3 && QString(argv[1]) == "-t")
        {
            QString target = argv[2];
            //TODO change report project
            qmlLoader->reportBug(target);
        }
        else
        {
            showHelpTip();
            return 0;
        }

        return app.exec();
    }
    else
    {
        qWarning() << "DFeedback is running...";
        if(argc == 3 && QString(argv[1]) == "-t"){
            QDBusInterface *iface;
            iface = new QDBusInterface(DBUS_NAME, DBUS_PATH, DBUS_NAME, QDBusConnection::sessionBus());
            QString target = argv[2];
            iface->call("switchProject", target);
        }

        return 0;
    }
}
