#ifndef DATACONVERTER_H
#define DATACONVERTER_H

#include <QObject>
#include <QDir>

const QString DRAFT_SAVE_PATH_NARMAL = QDir::homePath() + "/.cache/deepin-feedback/draft/";
const QString CONTENT_FILE_NAME = "Content.txt";
const QString SIMPLE_ENTRIES_FILE_NAME = "SimpleEntries.json";
const QString ADJUNCT_DIR_NAME = "Adjunct/"; //inclue image, log file etc.
const QString EMAILS_LIST_FILE_NAME = QDir::homePath() + "/.cache/deepin-feedback/emails.json";
const qint64 ADJUNCTS_MAX_SIZE = 10 * 1024 * 1024;   //byte

class DataConverter : public QObject
{
    Q_OBJECT
    Q_ENUMS(FeedbackType)
public:
    explicit DataConverter(QObject *parent = 0);
    ~DataConverter();

    enum FeedbackType{
        DFeedback_Bug,
        DFeedback_Proposal
    };

};

#endif // DATACONVERTER_H
