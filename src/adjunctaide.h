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

    Q_SLOT void getScreenShot();
    Q_SLOT void collectBugReporterInfo(const QString &target);

    static bool removeDirWidthContent(const QString &dirName);

signals:

public slots:
private slots:
    void finishCollectBugReporterInfo();
    void errorCollectBugReporterInfo();

private:
    void cleanUpBugReporterInfo(const QString &targetPath);

private:
    QProcess * collectProcess;
};

#endif // ADJUNCTAIDE_H
