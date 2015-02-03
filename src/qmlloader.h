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

enum FeedbackType{
    DFeedback_Bug,
    DFeedback_Proposal
};

struct Draft{
    FeedbackType feedbackType;
    QString title;
    QString content;
    QString email;
    bool helpDeepin;
    QStringList adjunctPathList;

    Draft(FeedbackType _feedbackType = DFeedback_Bug,
          QString _title="",
          QString _content = "",
          QString _email = "",
          bool _helpDeepin = true,
          QStringList _adjunctPathList = QStringList(""))
        :feedbackType(_feedbackType),title(_title),content(_content),email(_email),helpDeepin(_helpDeepin),adjunctPathList(_adjunctPathList){}
};

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
    void showHelpTip();
    void showVersion();
    void reportBug();   //Unselected target
    void reportBug(const QString &target); //specity the target

    //call by UI
    Q_SLOT QString getHomeDir();
    Q_SLOT QStringList getSupportAppList();
    Q_SLOT bool saveDraft(const QString &targetApp,
                   const FeedbackType &type,
                   const QString &title,
                   const QString &email,
                   const bool &helpDeepin,
                   const QString &content);
    Q_SLOT void clearAllDraft();
    Q_SLOT void clearDraft(const QString &targetApp);
    Q_SLOT QString addAdjunct(const QString &filePath, const QString &target);
    Q_SLOT void removeAdjunct(const QString &filePath);

private:
    void init();

    Draft getDraft(const QString &targetApp);
    void parseJsonData(const QByteArray &byteArray, Draft * draft);
    bool removeDirWidthContent(const QString &dirName);
    QString getFileNameFromPath(const QString &filePath);

private:
    const QString DRAFT_SAVE_PATH_NARMAL =
            QStandardPaths::standardLocations(QStandardPaths::HomeLocation).at(0) + "/.cache/deepin-feedback/draft/";
    const QString CONTENT_FILE_NAME = "Content.txt";
    const QString SIMPLE_ENTRIES_FILE_NAME = "SimpleEntries.json";
    const QString ADJUNCT_DIR_NAME = "Adjunct/"; //inclue image, log file etc.
};

#endif // QMLLOADER_H
