#include "adjunctaide.h"

AdjunctAide::AdjunctAide(QObject *parent) : QObject(parent)
{

}

AdjunctAide::~AdjunctAide()
{

}

void AdjunctAide::getScreenShot(const QString &target)
{
    tmpFileName = "/tmp/" + target + QDateTime::currentDateTime().toString("yyyy.MM.dd.hh:mm:ss") + TMP_SCREENSHOT_FILENAME;
    screenShotProcess = new QProcess(this);
    connect(screenShotProcess, SIGNAL(finished(int)), this, SLOT(finishGetScreenShot()));

    QStringList arguments;

    arguments << "-s" << tmpFileName;
    screenShotProcess->start("deepin-screenshot", arguments);
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
    if (screenShotProcess->exitCode() == 0)
        emit getScreenshotFinish(tmpFileName);
    else
        emit getScreenshotFinish("");

    qDebug() << "Get screenshot process finish!" << screenShotProcess->exitCode();
    screenShotProcess->deleteLater();
    tmpFileName = "";
}
