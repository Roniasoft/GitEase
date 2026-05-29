#include "QmlDiffPlugin.h"
#include "IPluginContext.h"

void QmlDiffPlugin::initialize(IPluginContext* ctx)
{
    ctx->registerDiff(this);
}

QUrl QmlDiffPlugin::colorizerQmlUrl() const
{
    return QUrl(QStringLiteral("qrc:/gitease.qml-diff/qml/QmlColorizer.qml"));
}
