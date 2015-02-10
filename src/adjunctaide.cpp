#include "adjunctaide.h"

AdjunctAide::AdjunctAide(QObject *parent) : QObject(parent)
{

}

AdjunctAide::~AdjunctAide()
{

}

void AdjunctAide::getScreenShot(const QString &target)
{
    QString targetFileName = "/tmp/" + target + TMP_SCREENSHOT_FILENAME;
    screenShotProcess = new QProcess(this);
    connect(screenShotProcess, SIGNAL(finished(int)), this, SLOT(finishGetScreenShot()));
    connect(screenShotProcess, SIGNAL(finished(int)), screenShotProcess, SLOT(deleteLater()));

    QStringList arguments;

    arguments << "-s" << targetFileName;
    screenShotProcess->start("/tmp/deepin-screenshot.sh", arguments);
}

bool AdjunctAide::removeDirWidthContent(const QString &dirName)
{
    QStringList dirNames;
    QDir tmpDir;
    QFileInfoList infoList;
    QFileInfoList::iterator currentFile;

    dirNames.clear();
    if(tmpDir.exists())
        dirNames<<dirName;
    else
        return true;


    for(int i=0;i<dirNames.size();++i)
    {
        tmpDir.setPath(dirNames[i]);
        infoList = tmpDir.entryInfoList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot ,QDir::Name);
        if(infoList.size()>0)
        {
            currentFile = infoList.begin();
            while(currentFile != infoList.end())
            {
                //dir, appent to dirNames
                if(currentFile->isDir())
                {
                    dirNames.append(currentFile->filePath());
                }
                else if(currentFile->isFile())
                {
                    if(!tmpDir.remove(currentFile->fileName()))
                    {
                        return false;
                    }
                }
                currentFile++;
            }//end of while
        }
    }
    //delete dir
    for(int i = dirNames.size()-1; i >= 0; --i)
    {
        if(!tmpDir.rmdir(dirNames[i]))
        {
            return false;
        }
    }
    return true;
}

void AdjunctAide::finishGetScreenShot()
{
    QString outPut = QString(screenShotProcess->readAllStandardOutput());

    emit getScreenshotFinish(getFileNameFromFeedback(outPut));
    qDebug() << "Get screenshot process finish!";
}

QString AdjunctAide::getFileNameFromFeedback(const QString &result)
{
    int startIndex = result.indexOf(FILENAME_FLAG);
    if (startIndex == -1)
        return "";
    int endIndex = result.indexOf("\n",startIndex);
    startIndex += FILENAME_FLAG.length();
    int subStrLength = endIndex - startIndex;

    return result.mid(startIndex,subStrLength).trimmed();
}

bool AdjunctAide::getScreenShotStateFromFeedback(const QString &result)
{
    int startIndex = result.indexOf(SCREENSHOT_STATE_HEAD_FLAG);
    if (startIndex == -1)
        return false;
    int endIndex = result.indexOf("\n",startIndex);
    startIndex += SCREENSHOT_STATE_HEAD_FLAG.length();
    int subStrLength = endIndex - startIndex;

    return result.mid(startIndex,subStrLength).trimmed() == SCREENSHOT_STATE_SUCCESS_FLAG ? true : false;
}
