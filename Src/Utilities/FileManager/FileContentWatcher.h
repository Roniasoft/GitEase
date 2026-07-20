#pragma once

#include <QObject>
#include <QtQml/qqmlregistration.h>#include <QUrl>
#include <QDir>
#include <QDirIterator>
#include <QFileSystemWatcher>

class FileContentWatcher : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged FINAL)
    Q_PROPERTY(QString content READ content NOTIFY contentChanged FINAL)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged FINAL)
    Q_PROPERTY(bool exists READ exists NOTIFY existsChanged FINAL)

public:
    explicit FileContentWatcher(QObject *parent = nullptr);

    QString filePath() const;
    QString content() const;
    QString error() const;
    bool exists() const;
    void setFilePath(const QString &filePath);

    Q_INVOKABLE void reload();
    Q_INVOKABLE QStringList findFiles(const QString &repoDir, const QStringList &nameFilters, bool recursive = true) const;

signals:
    void filePathChanged();
    void contentChanged();
    void errorChanged();
    void existsChanged();

private:

    QFileSystemWatcher m_watcher;
    QString m_filePath;
    QDir m_absoluteDir;
    QString m_content;
    QString m_error;
    bool m_exists = false;
};
