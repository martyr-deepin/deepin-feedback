#ifndef DATACONVERTER_H
#define DATACONVERTER_H

#include <QObject>

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
