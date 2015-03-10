#ifndef ADJUNCTAIDE_H
#define ADJUNCTAIDE_H

#include <QObject>
#include <QProcess>
#include <QFile>
#include <QDir>
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
    QString getFileNameFromFeedback(const QString &result);
    bool getScreenShotStateFromFeedback(const QString &result);

private:
    QProcess * screenShotProcess;
    const QString FILENAME_FLAG = "file:";
    const QString SCREENSHOT_STATE_HEAD_FLAG = "State:";
    const QString SCREENSHOT_STATE_SUCCESS_FLAG = "finish";
    const QString TMP_SCREENSHOT_FILENAME = "-deepin-feedback-screenshot.png";
};

#endif // ADJUNCTAIDE_H
