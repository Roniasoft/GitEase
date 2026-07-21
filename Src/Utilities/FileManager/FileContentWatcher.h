#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QFileSystemWatcher>
#include <QtQml/qqmlregistration.h>

class FileContentWatcher : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged FINAL)
    Q_PROPERTY(QString content READ content NOTIFY contentChanged FINAL)
    Q_PROPERTY(bool exists READ exists NOTIFY existsChanged FINAL)

public:
    explicit FileContentWatcher(QObject *parent = nullptr);

    QString filePath() const;
    QString content() const;
    bool exists() const;

    void setFilePath(const QString &filePath);

    Q_INVOKABLE QStringList findFiles(const QString &directoryPath, const QStringList &possibleFileNames, bool recursive = true) const;
    Q_INVOKABLE bool openExternally() const;

signals:
    void filePathChanged();
    void contentChanged();
    void existsChanged();

private:
    void reload();
    void updateWatchPath();

    QFileSystemWatcher m_watcher;
    QString m_filePath;
    QString m_content;
    bool m_exists = false;
};
