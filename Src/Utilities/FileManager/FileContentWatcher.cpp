#include "FileContentWatcher.h"

FileContentWatcher::FileContentWatcher(QObject *parent)
 : QObject(parent)
{

}

QString FileContentWatcher::filePath() const
{
    return m_filePath;
}

QString FileContentWatcher::content() const
{
    return m_content;
}

QString FileContentWatcher::error() const
{
    return m_error;
}

bool FileContentWatcher::exists() const
{
    return m_exists;
}

void FileContentWatcher::setFilePath(const QString &filePath)
{
    if (m_filePath == filePath)
        return;

    m_filePath = filePath;
    m_absoluteDir.setPath(QFileInfo(filePath).absolutePath());

    emit filePathChanged();
    reload();
}

void FileContentWatcher::reload()
{
    m_exists = false;
    m_error.clear();
    m_content.clear();

    if (m_filePath.isEmpty()) {
        emit existsChanged();
        emit errorChanged();
        emit contentChanged();
        return;
    }

    QFileInfo fileInfo(m_filePath);

    if (!fileInfo.exists() || !fileInfo.isFile()) {
        m_error = "File does not exist.";
        emit errorChanged();
        emit contentChanged();
        return;
    }

    QFile file(m_filePath);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_error = file.errorString();
        emit errorChanged();
        emit contentChanged();
        return;
    }

    m_content = QString::fromUtf8(file.readAll());
    m_exists = true;

    emit existsChanged();
    emit contentChanged();
}

QStringList FileContentWatcher::findFiles(const QString &directoryPath, const QStringList &possibleFileNames, bool recursive) const
{
    QStringList files;
    const QDir rootDir(directoryPath);

    if (!rootDir.exists())
        return files;

    // First: check only the repository root.
    const QFileInfoList rootFiles = rootDir.entryInfoList(QDir::Files | QDir::Readable, QDir::Name);

    for (const QString &possibleName : possibleFileNames) {
        for (const QFileInfo &fileInfo : rootFiles) {
            if (fileInfo.fileName().compare(
                    possibleName,
                    Qt::CaseInsensitive) == 0) {
                files.append(fileInfo.absoluteFilePath());
            }
        }
    }

    // A root README was found, or function is being called with no recursive option, so don't search nested folders.
    if (!files.isEmpty() || !recursive)
        return files;

    // Only as a fallback, search subdirectories.
    QDirIterator it(rootDir.absolutePath(), QDir::Files | QDir::Readable, QDirIterator::Subdirectories);

    while (it.hasNext()) {
        const QString filePath = it.next();
        const QString fileName = QFileInfo(filePath).fileName();

        for (const QString &possibleName : possibleFileNames) {
            if (fileName.compare(possibleName, Qt::CaseInsensitive) == 0) {
                files.append(filePath);
                break;
            }
        }
    }

    return files;
}

bool FileContentWatcher::openExternally() const
{
    if (m_filePath.isEmpty())
        return false;

    const QFileInfo fileInfo(m_filePath);

    if (!fileInfo.exists() || !fileInfo.isFile())
        return false;

    return QDesktopServices::openUrl(
        QUrl::fromLocalFile(fileInfo.absoluteFilePath())
        );
}
