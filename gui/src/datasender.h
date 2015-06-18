#ifndef DATASENDER_H
#define DATASENDER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QHttpPart>

class DataSender : public QObject
{
    Q_OBJECT
public:
    explicit DataSender(QObject *parent = 0);
    Q_INVOKABLE void postFeedbackData(const QString &jsonData);

signals:
    void postError(QString message);
    void postFinish();

private slots:
    void slotGotError(QNetworkReply::NetworkError error);
    void slotPostFinish(QNetworkReply * reply);

private:
    const QString PUT_FEEDBACK_METHOD = "Deepin.Feedback.putFeedback";
    const QString JSONRPC_HOST = "http://10.0.0.231/jsonrpc.psgi";//"https://bugzilla.deepin.io/jsonrpc.psgi";

};

#endif // DATASENDER_H
