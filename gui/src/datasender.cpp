#include "datasender.h"

DataSender::DataSender(QObject *parent) :
    QObject(parent)
{
    notifyInterface = new QDBusInterface("org.freedesktop.Notifications", "/org/freedesktop/Notifications",
                                         "org.freedesktop.Notifications",QDBusConnection::sessionBus(),this);
    connect(notifyInterface,SIGNAL(ActionInvoked(uint,QString)),this,SLOT(slotRetry(uint,QString)));
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

void DataSender::showSuccessNotification(const QString &title, const QString &msg)
{
    showNotification(title,msg,QStringList());
}

void DataSender::showErrorNotification(const QString &title, const QString &msg, const QString &action)
{
    QStringList actions;
    actions << "deepin_feedback_retry";
    actions << action;
    showNotification(title,msg,actions);
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

void DataSender::slotRetry(uint code, QString id)
{
    if (code == 0 && id == "deepin_feedback_retry")
    {
        emit retryPost();
    }
}

void DataSender::showNotification(const QString &title, const QString &msg, const QStringList &actions)
{
    notifyInterface->call(QDBus::AutoDetect,"Notify",
                      "Deepin Feedback",
                      uint(0),
                      "deepin-feedback",
                      title,
                      msg,
                      actions,
                      QVariantMap(),
                      -1);
}
