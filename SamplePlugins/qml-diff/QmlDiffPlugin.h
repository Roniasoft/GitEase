#pragma once

#include "IDiffPlugin.h"
#include <QObject>
#include <QtPlugin>

class QmlDiffPlugin : public QObject, public IDiffPlugin
{
    Q_OBJECT
    Q_INTERFACES(IPlugin IDiffPlugin)
    Q_PLUGIN_METADATA(IID "com.gitease.IDiffPlugin/1.0" FILE "plugin.json")

public:
    QString      id()      const override { return QStringLiteral("gitease.qml-diff"); }
    QString      name()    const override { return QStringLiteral("QML Diff Highlighter"); }
    QString      version() const override { return QStringLiteral("1.0.0"); }

    void initialize(IPluginContext* ctx) override;
    void shutdown()                      override {}

    QStringList handledExtensions() const override { return { QStringLiteral("qml") }; }
    QUrl        colorizerQmlUrl()   const override;
};
