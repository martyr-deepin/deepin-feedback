#include "adjunctuploader.h"

AdjunctUploader::AdjunctUploader(QObject *parent) : QObject(parent)
{    
    //import时使用AdjunctUploader 1.0
    qmlRegisterSingletonType<AdjunctUploader>("AdjunctUploader", 1, 0, "AdjunctUploader", uploaderObj);

}

AdjunctUploader * AdjunctUploader::adjunctUploader = NULL;
AdjunctUploader * AdjunctUploader::getInstance()
{
    if (adjunctUploader == NULL)
        adjunctUploader = new AdjunctUploader();
    return adjunctUploader;
}

void AdjunctUploader::uploadAdjunct(const QString &filePath)
{
    AdjunctUploadThread * tmpThread = new AdjunctUploadThread(filePath);
    connect(tmpThread, SIGNAL(uploadProgress(QString,int)), this , SIGNAL(uploadProgress(QString,int)));
    connect(tmpThread, SIGNAL(uploadFailed(QString,QString)), this, SIGNAL(uploadFailed(QString,QString)));
    connect(tmpThread, SIGNAL(uploadFinish(QString,QString)), this ,SLOT(slotUploadFinish(QString,QString)));
    threadMap.insert(filePath,tmpThread);
    tmpThread->startUpload();
}

void AdjunctUploader::cancelUpload(const QString &filePath)
{
    threadMap.take(filePath)->stopUpload();
}

void AdjunctUploader::slotUploadFinish(QString filePath, QString resourceUrl)
{
    threadMap.take(filePath);

    emit uploadFinish(filePath, resourceUrl);
}

QObject *AdjunctUploader::uploaderObj(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return AdjunctUploader::getInstance();
}

AdjunctUploader::~AdjunctUploader()
{

}

