#include "FileContentWatcher.h"

#include <QDesktopServices>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QUrl>

FileContentWatcher::FileContentWatcher(QObject *parent)
    : QObject(parent)
{
    connect(&m_watcher, &QFileSystemWatcher::fileChanged, this, [this](const QString &) {
        updateWatchPath();
        reload();
    });
}

QString FileContentWatcher::filePath() const
{
    return m_filePath;
}

QString FileContentWatcher::content() const
{
    return m_content;
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

    emit filePathChanged();

    updateWatchPath();
    reload();
}

void FileContentWatcher::updateWatchPath()
{
    if (!m_watcher.files().isEmpty())
        m_watcher.removePaths(m_watcher.files());

    if (m_filePath.isEmpty())
        return;

    const QFileInfo fileInfo(m_filePath);

    if (fileInfo.exists() && fileInfo.isFile())
        m_watcher.addPath(fileInfo.absoluteFilePath());
}

void FileContentWatcher::reload()
{
    QString newContent;
    bool newExists = false;

    if (!m_filePath.isEmpty()) {
        const QFileInfo fileInfo(m_filePath);

        if (fileInfo.exists() && fileInfo.isFile()) {
            QFile file(m_filePath);

            if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
                newContent = QString::fromUtf8(file.readAll());
                newExists = true;
            }
        }
    }

    if (m_content != newContent) {
        m_content = std::move(newContent);
        emit contentChanged();
    }

    if (m_exists != newExists) {
        m_exists = newExists;
        emit existsChanged();
    }
}

QStringList FileContentWatcher::findFiles(const QString &directoryPath,
                                          const QStringList &possibleFileNames,
                                          bool recursive) const
{
    QStringList files;
    const QDir rootDir(directoryPath);

    if (!rootDir.exists())
        return files;

    const QFileInfoList rootFiles = rootDir.entryInfoList(QDir::Files | QDir::Readable, QDir::Name);

    for (const QString &possibleName : possibleFileNames) {
        for (const QFileInfo &fileInfo : rootFiles) {
            if (fileInfo.fileName().compare(possibleName, Qt::CaseInsensitive) == 0)
                files.append(fileInfo.absoluteFilePath());
        }
    }

    if (!files.isEmpty() || !recursive)
        return files;

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
    const QFileInfo fileInfo(m_filePath);

    if (!fileInfo.exists() || !fileInfo.isFile())
        return false;

    return QDesktopServices::openUrl(QUrl::fromLocalFile(fileInfo.absoluteFilePath()));
}
