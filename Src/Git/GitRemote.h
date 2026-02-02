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

    /**
     * @brief Internal implementation for pushing commits to a remote.
     *
     * Performs a git push operation using the provided authentication
     * strategy. This method is shared by both SSH and HTTPS push
     * entry points.
     *
     * @param remoteName Name of the remote (e.g. "origin")
     * @param branchName Name of the branch to push
     * @param auth       Authentication strategy (ownership transferred)
     * @param force      Whether to force push
     *
     * @return GitResult containing the push result
     */
    GitResult pushInternal(const QString& remoteName,
                           const QString& branchName,
                           std::unique_ptr<IGitAuth> auth,
                           bool force);

public:
    explicit GitRemote(QObject *parent = nullptr);

    /**
     * @brief Push commits to a remote using SSH authentication.
     *
     * Uses the system SSH agent or default SSH keys to authenticate
     * the push operation.
     *
     * @param remote Name of the remote (default: "origin")
     * @param branch Name of the branch to push
     * @param force  Whether to force push (default: false)
     *
     * @return GitResult with operation result
     */
    Q_INVOKABLE GitResult push(const QString& remote,
                               const QString& branch,
                               bool force = false);

    /**
     * @brief Push commits to a remote using HTTPS authentication.
     *
     * Uses a personal access token to authenticate the push
     * operation over HTTPS.
     *
     * @param remote Name of the remote (default: "origin")
     * @param branch Name of the branch to push
     * @param token  Personal access token
     * @param force  Whether to force push (default: false)
     *
     * @return GitResult with operation result
     */
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

