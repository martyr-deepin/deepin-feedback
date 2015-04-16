#ifndef ADJUNCTUPLOADER_H
#define ADJUNCTUPLOADER_H

#include <QObject>
#include <QMap>
#include <QtQml>
#include <QQmlEngine>
#include <QJSEngine>
#include <QDebug>
#include "adjunctuploadthread.h"

class AdjunctUploader : public QObject
{
    Q_OBJECT
public:
    static AdjunctUploader * getInstance();
    ~AdjunctUploader();

    Q_INVOKABLE void uploadAdjunct(const QString &filePath);
    Q_INVOKABLE void cancelUpload(const QString &filePath);
    static QObject * uploaderObj(QQmlEngine *engine, QJSEngine *scriptEngine);

signals:
    void uploadProgress(QString filePath, int progress);//progress: 0 ~ 100
    void uploadFailed(QString filePath, QString message);
    void uploadFinish(QString filePath, QString resourceUrl);

private slots:
    void slotUploadFinish(QString filePath, QString resourceUrl);

private:
    explicit AdjunctUploader(QObject *parent = 0);

private:
    static AdjunctUploader * adjunctUploader;
    QMap<QString, AdjunctUploadThread *> threadMap;
};

#endif // ADJUNCTUPLOADER_H
