#include <QtQml>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QDBusConnection>
#include <QDBusInterface>

#include "logmanager.h"
#include "Logger.h"
#include "qmlloader.h"
#include "dataconverter.h"
#include "adjunctuploader.h"
#include "datasender.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setOrganizationName("deepin");
    app.setApplicationName("deepin-feedback");

    //Add command line option
    QCommandLineParser parser;
//    parser.setApplicationDescription("Feedback helper");
    parser.addHelpOption();
    parser.addOptions({
                          {{"t", "target"},
                           QObject::tr("Report a bug for <target>."),
                           QObject::tr("target")}
                      });

    parser.process(app);

    LogManager::instance()->debug_log_console_on();
    LOG_INFO() << LogManager::instance()->getlogFilePath();

    QString reportTarget = parser.value("target");

    if(QDBusConnection::sessionBus().registerService(DBUS_NAME)){

        AdjunctUploader::getInstance();
        qmlRegisterType<DataConverter>("DataConverter", 1, 0, "DataConverter");
        qmlRegisterType<DataSender>("DataSender",1,0,"DataSender");

        QmlLoader* qmlLoader = new QmlLoader();
        qmlLoader->rootContext->setContextProperty("mainObject", qmlLoader);
        qmlLoader->load(QUrl(QStringLiteral("qrc:/views/main.qml")));
        QObject::connect(qmlLoader->engine, SIGNAL(quit()), QApplication::instance(), SLOT(quit()));


        if (reportTarget.isEmpty()) {
            //TODO  clear project
            qmlLoader->reportBug();
        }
        else {
            qmlLoader->reportBug(reportTarget);
        }

        return app.exec();
    }
    else if (!reportTarget.isEmpty()) {
        QDBusInterface iface(DBUS_NAME, DBUS_PATH, DBUS_NAME, QDBusConnection::sessionBus());
        iface.call("switchProject", reportTarget);
    }
    else {
        qWarning() << "deepin-feedback is running...";
    }

    return 0;
}
