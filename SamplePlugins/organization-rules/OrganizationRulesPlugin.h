#pragma once

#include <QObject>
#include "IDockPlugin.h"
#include "IRulePlugin.h"
#include "IRepositoryAwarePlugin.h"
#include "PluginContext.h"

class RuleManager;

class OrganizationRulesPlugin : public QObject, public IDockPlugin, public IRepositoryAwarePlugin, public IRulePlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "com.gitease.IDockPlugin/1.0" FILE "plugin.json")
    Q_INTERFACES(IPlugin IDockPlugin IRulePlugin IRepositoryAwarePlugin)
public:
    QString id()      const override { return QStringLiteral("com.gitease.organization-rules"); }
    QString name()    const override { return QStringLiteral("Organization Rules"); }
    QString version() const override { return QStringLiteral("1.0.0"); }

    void initialize(IPluginContext* ctx) override;
    void shutdown() override {}

    QUrl dockQmlUrl() const override
    {
        return QUrl(QStringLiteral("qrc:/com.gitease.organization-rules/qml/RulesDock.qml"));
    }

    QString dockTitle() const override { return QStringLiteral("Organization Rules"); }
    QString dockIcon()  const override { return QStringLiteral("tree"); }

    void repositoryChanged(const QString& repoPath) override;
    GitResult check(ActionContext* context) override;


    RuleManager* ruleManager() const
    {
        return m_ruleManager;
    }

private:
    RuleManager* m_ruleManager = nullptr;

};
