#ifndef DATASENDER_H
#define DATASENDER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QHttpPart>
#include <QDBusInterface>
#include <QDBusReply>
#include <QVariantMap>

class DataSender : public QObject
{
    Q_OBJECT
public:
    explicit DataSender(QObject *parent = 0);
    Q_INVOKABLE void postFeedbackData(const QString &jsonData);
    Q_INVOKABLE void showSuccessNotification(const QString &title, const QString &msg);
    Q_INVOKABLE void showErrorNotification(const QString &title, const QString &msg, const QString &action);

signals:
    void postError(QString message);
    void postFinish();
    void retryPost();

private slots:
    void slotGotError(QNetworkReply::NetworkError error);
    void slotPostFinish(QNetworkReply * reply);
    void slotRetry(uint code,QString id);

private:
    void showNotification(const QString &title, const QString &msg, const QStringList &actions);

private:
    QDBusInterface * notifyInterface;
    const QString PUT_FEEDBACK_METHOD = "Deepin.Feedback.putFeedback";
    const QString JSONRPC_HOST = "http://10.0.0.231/jsonrpc.psgi";//"https://bugzilla.deepin.io/jsonrpc.psgi";
};

#endif // DATASENDER_H
