import QtQuick

import GitEase

import "qrc:/GitEase/Qml/Core/Scripts/AsyncGit.js" as AsyncGit

/*! ***********************************************************************************************
 * RepositoryController
 * Manages repository operations including opening, cloning, and selecting repositories.
 * Handles repository lifecycle and maintains recent repositories list.
 * ************************************************************************************************/
GitRepository {
    id : root

    /* Property Declarations
     * ****************************************************************************************/
    required property            AppModel                         appModel
    property                     NotificationController           notificationController: null

    property int maxRecentLength:   10
    property var activeClones:      ({})


    enum GitProtocol {
        Unknown = 0,
        SSH = 1,
        HTTP = 2,
        HTTPS = 3
    }

    /* Signals
     * ****************************************************************************************/
    signal repositorySelected(Repository repo)
    signal cloneCompleted(var result)

    /* Repository color scheme
     * ****************************************************************************************/
    readonly property var repoColorPalette: [
        "#FF5252", // red
        "#FF9800", // orange
        "#FFC400", // amber
        "#00C853", // green
        "#00B0FF", // light blue
        "#2979FF", // blue
        "#7C4DFF", // indigo
        "#D500F9", // purple
        "#FF4081", // pink
        "#1DE9B6", // teal
        "#76FF03", // lime
        "#F50057"  // magenta
    ]

    function repoColor(key) {
        var s = key ? String(key) : ""
        var h = 0
        for (var i = 0; i < s.length; ++i)
            h = ((h << 5) - h + s.charCodeAt(i)) | 0
        return root.repoColorPalette[Math.abs(h) % root.repoColorPalette.length]
    }

    function isValidRepoColor(c) {
        if (!c)
            return false
        var s = String(c).toLowerCase()
        return s !== "" && s !== "transparent" && s !== "#00000000"
    }

    /* Functions
     * ****************************************************************************************/

    /**
     * Initialize a new Git repository
     */
    function gitInit(path: string):bool {
        var result = init(path)

        if(result.success){
            createRepositoryComponent(path)
        }

        return result.success
    }

    /**
     * Open an existing repository at the specified path
     */
    function openRepository(path :string) : bool {
        var result = open(path)

        if(result.success){
            createRepositoryComponent(path)
        }

        return result.success
    }

    /**
     * Clone a repository from URL to the specified local path
     */
    function cloneRepository(path, url) : bool {
        let repoName = extractRepoName(url)
        let protocol = detectGitProtocol(url)

        if(path && path.slice(-1) !== "/")
            path = path + "/"

        let clonedPath = path + repoName
        if (protocol === RepositoryController.GitProtocol.Unknown) {
            if(notificationController)
                notificationController.error(`Unsupported Git URL: ${url}`)
            return { success: false }
        }

        if (root.activeClones[clonedPath]) {
            if(notificationController)
                notificationController.warning(`Clone already in progress: ${clonedPath}`)
            return { success: false }
        }

        root.activeClones[clonedPath] = true

        let args = protocol === RepositoryController.GitProtocol.SSH ? [url, clonedPath] : [url, clonedPath, ""]

        AsyncGit.call(root, "clone", args,
            function(result) { root.handleCloneResult(clonedPath, result) },
            function(error) { root.handleCloneResult(clonedPath, { success: false, errorMessage: error }) }
        )

        return { success: true }
    }

    function handleCloneResult(clonedPath, result) {
        root.activeClones[clonedPath] = false

        if (result && result.success) {
            let repoName = (result.data || clonedPath).toString().split(/[\/:]/).pop()
            createRepositoryComponent(result.data || clonedPath, repoName)
        }

        root.cloneCompleted(result)
    }

    function closeRepo(path) {
        const idx = root.appModel.repositories.findIndex(repo => repo && repo.path === path)
        if (idx < 0)
            return

        root.appModel.repositories.splice(idx, 1)
        root.appModel.repositories = root.appModel.repositories.slice()

        selectRepository(root.appModel.repositories[0].id)
    }

    /**
     * Create and initialize a Repository component for the given path
     */
    function createRepositoryComponent(path, name = "") {
        // Check if already exists
        var repo = appModel.repositories.find(r => r.path === path)
        if (!repo){
            // Create new repository
            var repoComponent = Qt.createComponent("qrc:/GitEase/Qml/Core/Models/Repository.qml")
            if (repoComponent.status === Component.Ready) {

                repo = appModel.recentRepositories.find(r => r.path === path)

                if (name === "")
                    name = path.split('/').pop() || path.split('\\').pop() || "Repository"

                repo = repoComponent.createObject(root, {
                    id: "repo_" + Date.now(),
                    path: path,
                    name: name,
                    color: (repo && root.isValidRepoColor(repo.color)) ? repo.color
                                                                       : root.repoColor(path)
                })
                
                // Add to repositories array
                repo.cppObjectPtr = root.currentRepo
                
                appModel.repositories.push(repo)
                appModel.repositories = appModel.repositories.slice(0)
            }
        }

        selectRepository(repo.id)
    }

    /**
     * Select a repository by ID and update current repository state
     */
    function selectRepository(repoId :string) {
        var repo = appModel.repositories.find(r => r.id === repoId)
        if (repo) {
            if (repo.cppObjectPtr) {
                root.currentRepo = repo.cppObjectPtr
            } else {
                var result = open(repo.path)
                
                if (!result.success) {
                    if(notificationController){
                        notificationController.error(result.errorMessage || "Failed to repository changes", "Repository Error", 5000)
                    }
                    return
                }
                
                repo.cppObjectPtr = root.currentRepo
            }
            
            appModel.currentRepository = repo
            root.repositorySelected(repo)

            updateRecentRepositories(repo)
            appModel.recentRepositories = appModel.recentRepositories.slice()
            appModel.save()

            if(notificationController && root.appModel.repositories.length > 1){
                notificationController.success("Changes Repository successfully", "Repository", 3000)
            }
        }else{
            if(notificationController){
                notificationController.error("Failed to repository changes", "Repository Error", 5000)
            }
        }
    }

    function updateRecentRepositories(repo) {
        if (!appModel.recentRepositories)
            appModel.recentRepositories = []

        if (!repo || !repo.path)
            return appModel.recentRepositories

        function normalizePath(p) {
            return (p || "").replace(/\\/g, "/").toLowerCase()
        }

        const targetPath = normalizePath(repo.path)

        // remove duplicates
        appModel.recentRepositories = appModel.recentRepositories.filter(r =>
            r && normalizePath(r.path) !== targetPath
        )

        // add to end (newest last)
        appModel.recentRepositories.unshift(repo)
        // add repo path in history
        let exists = root.appModel.repositoriesHistory.indexOf(repo.path)
        if(exists == -1) {
            appModel.repositoriesHistory.unshift(repo.path)
            appModel.repositoriesHistory = appModel.repositoriesHistory.slice()
        }

        // trim to max length
        if (root.maxRecentLength && appModel.recentRepositories.length > root.maxRecentLength) {
            appModel.recentRepositories = appModel.recentRepositories.slice(appModel.recentRepositories.length - root.maxRecentLength)
        }
    }


    /**
     * Extracts the repository name from a Git repository URL.
     *
     * Supported formats:
     *  - HTTPS: https://github.com/owner/repository.git
     *  - SSH:   git@github.com:owner/repository.git
     *
     * Behavior:
     *  - Returns only the repository name (last path segment)
     *
     */
    function extractRepoName(repoUrl : string) : string {
        // remove trailing .git
        let url = repoUrl.replace(/\.git$/, "");

        // handle both / and : (for SSH)
        return url.split(/[\/:]/).pop();
    }
}
