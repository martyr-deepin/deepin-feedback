#ifndef ADJUNCTAIDE_H
#define ADJUNCTAIDE_H

#include <QObject>
#include <QProcess>
#include <QFile>
#include <QDir>
#include <QDateTime>
#include <QDebug>
#include "dataconverter.h"

class AdjunctAide : public QObject
{
    Q_OBJECT
public:
    explicit AdjunctAide(QObject *parent = 0);
    ~AdjunctAide();

    void getScreenShot(const QString &target);

    static bool removeDirWidthContent(const QString &dirName);

signals:
    void getScreenshotFinish(QString fileName);

private slots:
    void finishGetScreenShot();

private:
    QProcess * screenShotProcess;
    QString tmpFileName = "";
    const QString TMP_SCREENSHOT_FILENAME = "-deepin-feedback-screenshot.png";
};

#endif // ADJUNCTAIDE_H
