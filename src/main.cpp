#include <QApplication>
#include <QQmlApplicationEngine>
#include "qmlloader.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QmlLoader* qmlLoader = new QmlLoader();
    qmlLoader->rootContext->setContextProperty("mainObject", qmlLoader);
    qmlLoader->load(QUrl(QStringLiteral("qrc:/views/main.qml")));
    QObject::connect(qmlLoader->engine, SIGNAL(quit()), QApplication::instance(), SLOT(quit()));

    if (argc == 1)
    {
        qmlLoader->reportBug();
    }
    else if(argc == 2)
    {
        QString order = argv[1];
        if(order == "-v" || order == "--version")
        {
            qmlLoader->showVersion();
        }
        else
        {
            qmlLoader->showHelpTip();
        }
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
    else
    {
        qmlLoader->showHelpTip();
    }

    return app.exec();
}
