#ifndef ADJUNCTUPLOADTHREAD_H
#define ADJUNCTUPLOADTHREAD_H

#include <QObject>
#include <QThread>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QHttpPart>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QFile>
#include <QDebug>

struct ResponeData{
    QString id;
    QString resourceUrl;
    QString postUrl;
    QJsonObject postHeader;
    QJsonObject postBody;
};

class AdjunctUploadThread : public QThread
{
    Q_OBJECT
public:
    explicit AdjunctUploadThread(const QString &filePath);
    ~AdjunctUploadThread();

    void startUpload();
    void stopUpload();
    void run();


signals:
    void uploadProgress(QString filePath, int progress);//progress: 0 ~ 100
    void uploadFailed(QString filePath, QString message);
    void uploadFinish(QString filePath, QString resourceUrl);

public slots:
    void getServerAccessResult(QNetworkReply * reply);
    void parseJsonData(const QByteArray &jsonData, ResponeData * resData);
    void slotUploadFinish(QNetworkReply * reply);
    void slotUploadProgress(qint64 value1, qint64 value2);
    void slotGotError(QNetworkReply::NetworkError code);

private:
    QNetworkAccessManager * networkAccessManager;
    QNetworkReply * gUploadReply;
    ResponeData gResponeData;
    QFile * gUploadFile;
    QString gFilePath;
    QString gResourceUrl;

    const QString REST_TYPE = "report";
    const QString BUCKET_HOST = "https://api.linuxdeepin.com/";
    const QString BUCKET_API = "https://api.linuxdeepin.com/bucket/";
};

#endif // ADJUNCTUPLOADTHREAD_H
