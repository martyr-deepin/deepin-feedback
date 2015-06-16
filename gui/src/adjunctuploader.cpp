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
    connect(tmpThread, SIGNAL(uploadFinish(QString,QString)), this ,SLOT(slotUploadFinish(QString,QString)));
    connect(tmpThread, SIGNAL(uploadFailed(QString,QString)), this, SIGNAL(uploadFailed(QString,QString)));
    connect(tmpThread, SIGNAL(uploadFailed(QString,QString)), this, SLOT(slotUploadFailed(QString)));
    threadMap.insert(filePath,tmpThread);
    tmpThread->startUpload();
}

void AdjunctUploader::cancelUpload(const QString &filePath)
{
    if (threadMap.keys().indexOf(filePath) != -1)
    {
        threadMap.take(filePath)->stopUpload();
    }
    deleteFromUploadedList(filePath);
}

bool AdjunctUploader::isInUploadedList(const QString &filePath)
{
    if (!QFile::exists(UPLOAD_RECORD_FILE))
        return false;

    QFile recordFile(UPLOAD_RECORD_FILE);
    if (!recordFile.open(QIODevice::ReadOnly))
    {
        qWarning() << "Open upload record file to read error!";
        return false;
    }

    QByteArray tmpByteArray = recordFile.readAll();
    recordFile.close();

    QJsonObject tmpObj;
    QJsonDocument parseDoc = QJsonDocument::fromJson(tmpByteArray);
    if (parseDoc.isObject())
        tmpObj = parseDoc.object();
    else
        return false;

    int tmpIndex = tmpObj.keys().indexOf(filePath);
    return tmpIndex != -1;
}

QString AdjunctUploader::getBucketUrl(const QString &filePath)
{
    QJsonObject tmpObj = getJsonObjFromFile();
    return tmpObj.value(filePath).toString();
}

QString AdjunctUploader::getFileNameByPath(const QString &filePath)
{
    return filePath.mid(filePath.lastIndexOf("/") + 1);
}

QString AdjunctUploader::getMimeType(const QString &filePath)
{
    QMimeDatabase db;
    QMimeType mime = db.mimeTypeForFile(filePath);
    return mime.name();
}

void AdjunctUploader::slotUploadFinish(QString filePath, QString resourceUrl)
{
    threadMap.take(filePath);

    emit uploadFinish(filePath, resourceUrl);
    insertToUploadedList(filePath,resourceUrl);
}

void AdjunctUploader::slotUploadFailed(const QString &filePath)
{
    cancelUpload(filePath);
}

QObject *AdjunctUploader::uploaderObj(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return AdjunctUploader::getInstance();
}

void AdjunctUploader::insertToUploadedList(const QString &filePath, const QString &bucketUrl)
{
    QDir tmpDir;
    if (!tmpDir.exists(DRAFT_SAVE_PATH))
        tmpDir.mkpath(DRAFT_SAVE_PATH);

    QJsonDocument jsonDocument;
    QJsonObject jsonObj;

    if (!QFile::exists(UPLOAD_RECORD_FILE))
    {
        jsonObj.insert(filePath,QJsonValue(bucketUrl));
    }
    else
    {
        QFile recordFile(UPLOAD_RECORD_FILE);
        if (!recordFile.open(QIODevice::ReadOnly))
        {
            qWarning() << "Open upload record file to read error!";
            return;
        }

        QByteArray tmpByteArry = recordFile.readAll();
        recordFile.close();

        QJsonDocument parseDoucment = QJsonDocument::fromJson(tmpByteArry);
        if(parseDoucment.isObject())
        {
            jsonObj = parseDoucment.object();
            jsonObj.insert(filePath,QJsonValue(bucketUrl));
        }
    }

    jsonDocument.setObject(jsonObj);

    QFile uploadRecordFile(UPLOAD_RECORD_FILE);
    if (uploadRecordFile.open(QIODevice::WriteOnly | QIODevice::Truncate))
    {
        uploadRecordFile.write(jsonDocument.toJson(QJsonDocument::Compact));
        uploadRecordFile.close();
    }
}

void AdjunctUploader::deleteFromUploadedList(const QString &filePath)
{
    if (!QFile::exists(UPLOAD_RECORD_FILE))
        return;

    QFile recordFile(UPLOAD_RECORD_FILE);
    if (!recordFile.open(QIODevice::ReadOnly))
    {
        qWarning() << "Open upload record file to read error!";
        return;
    }

    QByteArray tmpByteArray = recordFile.readAll();
    recordFile.close();

    QJsonObject tmpObj;
    QJsonDocument parseDoc = QJsonDocument::fromJson(tmpByteArray);
    if (parseDoc.isObject())
        tmpObj = parseDoc.object();

    int tmpIndex = tmpObj.keys().indexOf(filePath);
    if (tmpIndex != -1)
        tmpObj.remove(filePath);

    parseDoc.setObject(tmpObj);

    QFile uploadRecordFile(UPLOAD_RECORD_FILE);
    if (uploadRecordFile.open(QIODevice::WriteOnly | QIODevice::Truncate))
    {
        uploadRecordFile.write(parseDoc.toJson(QJsonDocument::Compact));
        uploadRecordFile.close();
    }
}

QJsonObject AdjunctUploader::getJsonObjFromFile()
{
    QJsonObject jsonObj;
    if (!QFile::exists(UPLOAD_RECORD_FILE))
        return jsonObj;

    QFile recordFile(UPLOAD_RECORD_FILE);
    if (!recordFile.open(QIODevice::ReadOnly))
    {
        qWarning() << "Open upload record file to read error!";
        return jsonObj;
    }

    QByteArray tmpByteArray = recordFile.readAll();
    recordFile.close();
\
    QJsonDocument parseDoc = QJsonDocument::fromJson(tmpByteArray);
    if (parseDoc.isObject())
        jsonObj = parseDoc.object();

    return jsonObj;
}

AdjunctUploader::~AdjunctUploader()
{

}

