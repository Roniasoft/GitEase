#include "FileContentWatcher.h"

FileContentWatcher::FileContentWatcher(QObject *parent)
{

}

QString FileContentWatcher::filePath() const
{
    return "";
}

QString FileContentWatcher::content() const
{
    return "";
}

QString FileContentWatcher::error() const
{
    return "";
}

bool FileContentWatcher::exists() const
{
    return true;
}

void FileContentWatcher::setFilePath(const QString &filePath)
{

}

void FileContentWatcher::reload()
{

}
