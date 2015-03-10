#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "qmlloader.h"
#include "dataconverter.h"
#include <QDBusConnection>
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

    if (argc == 1)
    {
        if (!QDBusConnection::sessionBus().registerService("com.deepin.user.feedback"))
        {
            qDebug() << "Warning: process is running...";
            return 0;
        }
    }
    else if(argc == 2)
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
    else if (argc == 3 && QString(argv[1]) == "-t")
    {
        QString target = argv[2];
        if (!QDBusConnection::sessionBus().registerService("com.deepin.user.feedback." + target))
        {
            qDebug() << "Warning: process is running...";
            return 0;
        }
    }
    else
    {
        showHelpTip();
        return 0;
    }

    qmlRegisterType<DataConverter>("DataConverter", 1, 0, "DataConverter");

    QmlLoader* qmlLoader = new QmlLoader();
    qmlLoader->rootContext->setContextProperty("mainObject", qmlLoader);
    qmlLoader->load(QUrl(QStringLiteral("qrc:/views/main.qml")));
    QObject::connect(qmlLoader->engine, SIGNAL(quit()), QApplication::instance(), SLOT(quit()));

    if (argc == 1)
    {
        qmlLoader->reportBug();
    }
    else if (argc == 3 && QString(argv[1]) == "-t")
    {
        //report bug target
        QString target = argv[2];
        QStringList supportList = qmlLoader->getSupportAppList();
        if (supportList.indexOf(target) != -1)
        {
            qmlLoader->reportBug(target);
        }
        else
        {
            qmlLoader->reportBug("other");
        }
    }

    return app.exec();
}
