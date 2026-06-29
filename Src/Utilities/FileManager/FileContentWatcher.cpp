#include "FileContentWatcher.h"

FileContentWatcher::FileContentWatcher(QObject *parent)
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

    updateWatchPath();
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

QStringList FileContentWatcher::findFiles(const QStringList &nameFilters, bool recursive) const
{
    if (!recursive) {
        return m_absoluteDir.entryList(nameFilters, QDir::Files);
    }

    QStringList files;

    QDirIterator it(m_absoluteDir.path(),
                    nameFilters,
                    QDir::Files,
                    QDirIterator::Subdirectories);

    while (it.hasNext())
        files << it.next();

    return files;
}
