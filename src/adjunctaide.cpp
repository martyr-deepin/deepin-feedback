#include "adjunctaide.h"

AdjunctAide::AdjunctAide(QObject *parent) : QObject(parent)
{

}

AdjunctAide::~AdjunctAide()
{

}

void AdjunctAide::getScreenShot()
{

}

void AdjunctAide::collectBugReporterInfo(const QString &target)
{
//    QString adjunctDir =DRAFT_SAVE_PATH_NARMAL + target + "/" + ADJUNCT_DIR_NAME;
//    cleanUpBugReporterInfo(adjunctDir);

//    collectProcess = new QProcess(0);
//    connect(collectProcess, SIGNAL(finished(int)), this, SLOT(finishCollectBugReporterInfo()));
//    connect(collectProcess, SIGNAL(readyReadStandardError()), this, SLOT(errorCollectBugReporterInfo()));

//    collectProcess->setWorkingDirectory(adjunctDir);
//    QStringList arguments;

//    arguments << "deepin-bug-reporter";
//    collectProcess->start("gksudo", arguments);
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

void AdjunctAide::finishCollectBugReporterInfo()
{
    qDebug() << "Collect info finish!";
    collectProcess->deleteLater();
}

void AdjunctAide::errorCollectBugReporterInfo()
{

}

void AdjunctAide::cleanUpBugReporterInfo(const QString &targetPath)
{
    //get file name list
    if (QFile::exists(targetPath))
    {
        QDir tmpDir(targetPath);
        QStringList nameFilter("deepin-bug-reporter-results-all*");
        QFileInfoList infoList = tmpDir.entryInfoList(nameFilter, QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot ,QDir::Name);
        for (int i = 0; i < infoList.length(); i ++)
        {
            if (infoList.at(i).isDir()){
                //remove dir
//                qDebug() << "removing dir: " << infoList.at(i).filePath();
                removeDirWidthContent(infoList.at(i).filePath());
            }
            else
            {
                //remove file
//                qDebug() << "removing file: " << infoList.at(i).filePath();
                tmpDir.remove(infoList.at(i).filePath());
            }
        }
    }
}
