#ifndef QMLLOADER_H
#define QMLLOADER_H

#include <QObject>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QStandardPaths>
#include <QJsonParseError>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDir>
#include <QFile>
#include <QDebug>
#include "dataconverter.h"
#include "adjunctaide.h"


struct Draft{
    DataConverter::FeedbackType feedbackType;
    QString title;
    QString content;
    QString email;
    bool helpDeepin;
    QStringList adjunctPathList;

    Draft(DataConverter::FeedbackType _feedbackType = DataConverter::DFeedback_Bug,
          QString _title="",
          QString _content = "",
          QString _email = "",
          bool _helpDeepin = true,
          QStringList _adjunctPathList = QStringList())
        :feedbackType(_feedbackType),title(_title),content(_content),email(_email),helpDeepin(_helpDeepin),adjunctPathList(_adjunctPathList){}
};

Q_DECLARE_METATYPE(DataConverter::FeedbackType)

class QmlLoader : public QObject
{
    Q_OBJECT
public:
    explicit QmlLoader(QObject *parent = 0);
    ~QmlLoader();

    QQmlEngine* engine;
    QQmlComponent* component;
    QQmlContext * rootContext;
    QObject * rootObject;

    void load(QUrl url);

    //call by main
    void reportBug();   //Unselected target
    void reportBug(const QString &target); //specity the target
    QStringList getSupportAppList();

public Q_SLOTS:
    //call by UI
    QString getHomeDir();
    bool saveDraft(const QString &targetApp,
                   const DataConverter::FeedbackType type,
                   const QString &title,
                   const QString &email,
                   const bool &helpDeepin,
                   const QString &content);
    void clearAllDraft();
    void clearDraft(const QString &targetApp);
    QString addAdjunct(const QString &filePath, const QString &target);
    void removeAdjunct(const QString &filePath);
    bool draftTargetExist(const QString &target);
    void updateUiDraftData(const QString &target);
    void getScreenShot(const QString &target);
    bool canAddAdjunct(const QString &target);

Q_SIGNALS:
    void getScreenshotFinish(QString fileName);
    void submitCompleted(bool succeeded);

private:
    void init();

    Draft getDraft(const QString &targetApp);
    void parseJsonData(const QByteArray &byteArray, Draft * draft);
    QString getFileNameFromPath(const QString &filePath);
    qint64 getAdjunctsSize(const QString &target);
private:
    AdjunctAide * adjunctAide;
};

#endif // QMLLOADER_H
