#include "datasender.h"

DataSender::DataSender(QObject *parent) :
    QObject(parent)
{
}

void DataSender::postFeedbackData(const QString &jsonData)
{
    qDebug() << "Start send process...";//<<jsonData;

    QNetworkRequest request;
    request.setUrl(QUrl(JSONRPC_HOST));
    request.setHeader(QNetworkRequest::ContentTypeHeader,"application/json-rpc");

    QNetworkAccessManager * tmpManager = new QNetworkAccessManager();

    QNetworkReply * gUploadReply = tmpManager->post(request, jsonData.toUtf8());
    connect(tmpManager, SIGNAL(finished(QNetworkReply*)), tmpManager, SLOT(deleteLater()));
    connect(gUploadReply, SIGNAL(finished()), gUploadReply, SLOT(deleteLater()));
    connect(gUploadReply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(slotGotError(QNetworkReply::NetworkError)), Qt::DirectConnection);
    connect(tmpManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(slotPostFinish(QNetworkReply*)), Qt::DirectConnection);
}

void DataSender::slotGotError(QNetworkReply::NetworkError error)
{
    qDebug() << "Post failed!";
    emit postError(QString::number(error));
}

void DataSender::slotPostFinish(QNetworkReply *reply)
{
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    qDebug() << "Post finish!" << statusCode << reply->readAll();

    if (statusCode == 200)
        emit postFinish();
}
