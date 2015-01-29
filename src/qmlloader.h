#ifndef QMLLOADER_H
#define QMLLOADER_H

#include <QObject>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QDebug>

class QmlLoader : public QObject
{
    Q_OBJECT
public:
    explicit QmlLoader(QObject *parent = 0);
    ~QmlLoader();

    QQmlEngine* engine;
    QQmlComponent* component;
    QQmlContext * rootContext;
    QObject * rootObject;

    void load(QUrl url);

    void show();
    void showHelpTip();
    void showVersion();
    void reportBug();
    void reportBug(const QString &target);
    QStringList getSupportAppList();

public slots:
//    void installPackage(QString packageName);

//    QString getGplBodyTextPath(QString language);

//    void setCustomCursor(QString path);
//    void clearCustomCursor();
//    void setCursorFlashTime(int time);
//    QString getDefaultMask(QString ipAddress);
//    QString getHomeDir();

//    QString toHumanShortcutLabel(QString sequence);

//    //Bugfix: qt5 double screen switch case screen distory
//    //if you do not patch Qt, only restart DockApplet is OK
//    void restart(QString moduleName);

signals:

public slots:
};

#endif // QMLLOADER_H
