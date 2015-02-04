#include "qmlloader.h"

QmlLoader::QmlLoader(QObject *parent)
    :QObject(parent)
{
    engine = new QQmlEngine(this);
    component = new QQmlComponent(engine, this);
    rootContext = new QQmlContext(engine, this);

    init();
}

QmlLoader::~QmlLoader()
{
    delete this->rootContext;
    delete this->component;
    delete this->engine;
}


void QmlLoader::load(QUrl url)
{
    this->component->loadUrl(url);
    this->rootObject = this->component->beginCreate(this->rootContext);
    if ( this->component->isReady() )
    {
        this->component->completeCreate();
    }
    else
    {
        qWarning() << this->component->errorString();
    }
}

void QmlLoader::showHelpTip()
{

}

void QmlLoader::showVersion()
{

}

void QmlLoader::reportBug()
{
    QMetaObject::invokeMethod(
                this->rootObject,
                "showMainWindow"
                );
}

void QmlLoader::reportBug(const QString &target)
{
    updateUiDraftData(target);

    QMetaObject::invokeMethod(
                this->rootObject,
                "showMainWindow"
                );
}


void QmlLoader::init()
{
    //makesure path exist
    QDir configDir;
    if (!configDir.exists(DRAFT_SAVE_PATH_NARMAL))
    {
        configDir.mkpath(DRAFT_SAVE_PATH_NARMAL);
    }
}

QString QmlLoader::getHomeDir()
{
    return QDir::homePath();
}

QStringList QmlLoader::getSupportAppList()
{

}

bool QmlLoader::saveDraft(const QString &targetApp,
                          const DataConverter::FeedbackType type,
                          const QString &title,
                          const QString &email,
                          const bool &helpDeepin,
                          const QString &content)
{
    QString targetPath = DRAFT_SAVE_PATH_NARMAL + targetApp;
    QDir tmpDir;
    if (!tmpDir.exists(targetPath))
        tmpDir.mkpath(targetPath);

    if (!tmpDir.exists(targetPath + "/" + ADJUNCT_DIR_NAME))
        tmpDir.mkdir(targetPath + "/" + ADJUNCT_DIR_NAME);

    //write simple entries file
    QJsonObject jsonObj;
    jsonObj.insert("FeedbackType", int(type));
    jsonObj.insert("Title", title);
    jsonObj.insert("Email", email);
    jsonObj.insert("HelpDeepin",helpDeepin);

    QJsonDocument jsonDocument;
    jsonDocument.setObject(jsonObj);

    QFile simpleEntriesFile(targetPath + "/" + SIMPLE_ENTRIES_FILE_NAME);
    if (simpleEntriesFile.open(QIODevice::WriteOnly | QIODevice::Truncate))
    {
        simpleEntriesFile.write(jsonDocument.toJson(QJsonDocument::Compact));
        simpleEntriesFile.close();
    }
    else
    {
        qDebug() << "Open simple entries file error!";
        return false;
    }

    //write content file
    QFile contentFile(targetPath + "/" + CONTENT_FILE_NAME);
    if (contentFile.open(QIODevice::WriteOnly | QIODevice::Truncate))
    {
        contentFile.write(content.toLatin1());
        contentFile.close();
    }
    else
    {
        qDebug() << "Open content file error!";
        return false;
    }

    return true;
}

void QmlLoader::clearAllDraft()
{
    removeDirWidthContent(DRAFT_SAVE_PATH_NARMAL);
    QDir tmpDir;
    tmpDir.mkpath(DRAFT_SAVE_PATH_NARMAL);
}

void QmlLoader::clearDraft(const QString &targetApp)
{
    removeDirWidthContent(DRAFT_SAVE_PATH_NARMAL + targetApp);
}

QString QmlLoader::addAdjunct(const QString &filePath, const QString &target)
{
    QString targetFileName = DRAFT_SAVE_PATH_NARMAL + target + "/" + ADJUNCT_DIR_NAME + getFileNameFromPath(filePath);
    if (QFile::exists(target))
        return "";

    QFileInfo tmpFileInfo(targetFileName);
    if (tmpFileInfo.size() + getAdjunctsSize(target) >= ADJUNCTS_MAX_SIZE)
    {
        qDebug() << "File too large!";
        return "";
    }

    //copy file from target path to draft location
    if (QFile::copy(filePath, targetFileName))
        return targetFileName;
    else
        return "";
}

void QmlLoader::removeAdjunct(const QString &filePath)
{
    QFile::remove(filePath);
}

bool QmlLoader::draftTargetExist(const QString &target)
{
    return QFile::exists(DRAFT_SAVE_PATH_NARMAL + target);
}

void QmlLoader::updateUiDraftData(const QString &target)
{
    //get draft
    Draft draft = getDraft(target);

    //init value
    QVariant contentValue = QVariant(draft.content);
    QMetaObject::invokeMethod(
                this->rootObject,
                "setReportContent",
                Q_ARG(QVariant, contentValue)
                );

    QVariant listValue = QVariant(draft.adjunctPathList);
    QMetaObject::invokeMethod(
                this->rootObject,
                "setAdjunctsPathList",
                Q_ARG(QVariant, listValue)
                );

    QVariant feedbackTypeValue = QVariant(draft.feedbackType);
    QVariant reportTitleValue = QVariant(draft.title);
    QVariant emailValue = QVariant(draft.email);
    QVariant helpDeepinValue = QVariant(draft.helpDeepin);
    QMetaObject::invokeMethod(
                this->rootObject,
                "setSimpleEntries",
                Q_ARG(QVariant,feedbackTypeValue),
                Q_ARG(QVariant,reportTitleValue),
                Q_ARG(QVariant,emailValue),
                Q_ARG(QVariant,helpDeepinValue)
                );
}

Draft QmlLoader::getDraft(const QString &targetApp)
{
    Draft tmpDraft;
    QDir configDir;
    if (!configDir.exists(DRAFT_SAVE_PATH_NARMAL + targetApp))
    {
        //not exist,return empty value
        return tmpDraft;
    }
    else
    {
        //get content
        if (QFile::exists(DRAFT_SAVE_PATH_NARMAL + targetApp + "/" + CONTENT_FILE_NAME))
        {
            QFile contentFile(DRAFT_SAVE_PATH_NARMAL + targetApp + "/" + CONTENT_FILE_NAME);
            if (contentFile.open(QIODevice::ReadOnly))
            {
                tmpDraft.content = QString(contentFile.readAll());
                contentFile.close();
            }
        }

        //get simple entries from json file
        if (QFile::exists(DRAFT_SAVE_PATH_NARMAL + targetApp + "/" + SIMPLE_ENTRIES_FILE_NAME))
        {
            QFile entriesFile(DRAFT_SAVE_PATH_NARMAL + targetApp + "/" + SIMPLE_ENTRIES_FILE_NAME);
            if (entriesFile.open(QIODevice::ReadOnly))
            {
                QByteArray tmpByteArry = entriesFile.readAll();
                parseJsonData(tmpByteArry,&tmpDraft);
                entriesFile.close();
            }
        }

        //get adjuncts path's list
        if (QFile::exists(DRAFT_SAVE_PATH_NARMAL + targetApp + "/" + ADJUNCT_DIR_NAME))
        {
            QDir tmpDir(DRAFT_SAVE_PATH_NARMAL + targetApp + "/" + ADJUNCT_DIR_NAME);
            QFileInfoList infoList = tmpDir.entryInfoList(QDir::Files | QDir::NoDotAndDotDot ,QDir::Name);
            for (int i = 0; i < infoList.length(); i ++)
            {
                if (infoList.at(i).isFile())
                    tmpDraft.adjunctPathList.append(infoList.at(i).filePath());
            }
        }
    }
}

void QmlLoader::parseJsonData(const QByteArray &byteArray, Draft *draft)
{
    QJsonParseError jsonError;
    QJsonDocument parseDoucment = QJsonDocument::fromJson(byteArray, &jsonError);
    if(jsonError.error == QJsonParseError::NoError)
    {
        if(parseDoucment.isObject())
        {
            QJsonObject obj = parseDoucment.object();
            if(obj.contains("FeedbackType"))
            {
                QJsonValue feedbackTypeValue = obj.take("FeedbackType");
                if(feedbackTypeValue.isDouble())
                    draft->feedbackType = DataConverter::FeedbackType(feedbackTypeValue.toVariant().toInt());
            }
            if(obj.contains("Title"))
            {
                QJsonValue titleValue = obj.take("Title");
                if(titleValue.isString())
                    draft->title = titleValue.toString();
            }
            if(obj.contains("Email"))
            {
                QJsonValue emailValue = obj.take("Email");
                if(emailValue.isString())
                    draft->email = emailValue.toString();
            }
            if (obj.contains("HelpDeepin"))
            {
                QJsonValue helpDeepinValue = obj.take("HelpDeepin");
                if (helpDeepinValue.isBool())
                    draft->helpDeepin = helpDeepinValue.toBool();
            }
        }
    }
}

bool QmlLoader::removeDirWidthContent(const QString &dirName)
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

QString QmlLoader::getFileNameFromPath(const QString &filePath)
{
    int tmpIndex = filePath.lastIndexOf("/");
    if (tmpIndex == -1)
        return "";
    else
        return filePath.mid(tmpIndex + 1, filePath.length() - tmpIndex - 1);
}

qint64 QmlLoader::getAdjunctsSize(const QString &target)
{
    qint64 tmpSize = 0;
    if (QFile::exists(DRAFT_SAVE_PATH_NARMAL + target + "/" + ADJUNCT_DIR_NAME))
    {
        QDir tmpDir(DRAFT_SAVE_PATH_NARMAL + target + "/" + ADJUNCT_DIR_NAME);
        QFileInfoList infoList = tmpDir.entryInfoList(QDir::Files | QDir::NoDotAndDotDot ,QDir::Name);
        for (int i = 0; i < infoList.length(); i ++)
        {
            if (infoList.at(i).isFile()){
                tmpSize += infoList.at(i).size();
            }
        }

        return tmpSize;
    }
    else
        return 0;
}
