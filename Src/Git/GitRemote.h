#pragma once

#include "IGitController.h"
#include "Repository.h"
#include <QObject>

#include "GitRepository.h"

class GitResult;
class GitRemote : public IGitController
{
    Q_OBJECT
    QML_ELEMENT

private:

    GitResult internalpush(const QString& remoteName,
                           const QString& branchName,
                           std::unique_ptr<IGitAuth> auth,
                           bool force);

public:
    explicit GitRemote(QObject *parent = nullptr);

    Q_INVOKABLE GitResult push(const QString& remote,
                               const QString& branch,
                               bool force = false);

    Q_INVOKABLE GitResult push(const QString& remote,
                               const QString& branch,
                               const QString& token,
                               bool force = false);

    /**
     * \brief Get list of remotes for the repository
     * \return QVariantList with remote information
     */
    Q_INVOKABLE GitResult getRemotes();

    /**
     * \brief Add a new remote
     * \param name Remote name
     * \param url Remote URL
     * \return QVariantMap with operation result
     */
    Q_INVOKABLE GitResult addRemote(const QString &name,
                                      const QString &url);

    /**
     * \brief Remove a remote
     * \param name Remote name
     * \return QVariantMap with operation result
     */
    Q_INVOKABLE GitResult removeRemote(const QString &name);

    /**
    * \brief Retrieves the name of the tracked upstream branch.
    * \param localBranchName The name of the local branch to check.
    * \return The upstream branch name (e.g., "origin/main") or an empty QString if no upstream is set.
    */
    Q_INVOKABLE GitResult getUpstreamName(const QString &localBranchName);
};

