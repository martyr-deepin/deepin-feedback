#include "qmlloader.h"

QmlLoader::QmlLoader(QObject *parent)
    :QObject(parent)
{
    engine = new QQmlEngine(this);
    component = new QQmlComponent(engine, this);
    rootContext = new QQmlContext(engine, this);
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

void QmlLoader::show()
{
    QVariant second = QVariant(0);
    QMetaObject::invokeMethod(
                this->rootObject,
                "showDss",
                Q_ARG(QVariant, second)
                );
}

void QmlLoader::showHelpTip()
{

}

void QmlLoader::showVersion()
{

}

void QmlLoader::reportBug()
{

}

void QmlLoader::reportBug(const QString &target)
{

}

QStringList QmlLoader::getSupportAppList()
{

}
