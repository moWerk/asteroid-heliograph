/*
 * Copyright (C) 2026 - Timo Könnecke <github.com/moWerk>
 *               2025 - Ed Beroset <beroset@ieee.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "FileHelper.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QDir>
#include <QStandardPaths>

// SailfishOS: the per-app data directory, ~/.local/share/<org>/<app>/.
// main.cpp copies the bundled template there on first start.
static QString dataFilePath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
            + QStringLiteral("/custom.txt");
}

QStringList FileHelper::messagesForCategory(const QString &categoryKey) const
{
    const QString dataFile = dataFilePath();
    QFile file(dataFile);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "FileHelper: cannot open" << dataFile << file.errorString();
        return QStringList();
    }

    QTextStream in(&file);
    in.setCodec("UTF-8");
    QStringList results;
    const QString prefix = categoryKey.toLower() + ":";

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty() || line.startsWith('#'))
            continue;
        if (line.toLower().startsWith(prefix)) {
            QString msg = line.mid(prefix.length()).trimmed();
            if (!msg.isEmpty())
                results.append(msg);
        }
    }

    file.close();
    return results;
}

// One line, no surrounding blanks: the file format is one message per line.
static QString cleaned(const QString &text)
{
    QString t = text;
    t.replace(QLatin1Char('\n'), QLatin1Char(' ')).replace(QLatin1Char('\r'), QLatin1Char(' '));
    return t.simplified();
}

QString FileHelper::addMessage(const QString &text)
{
    const QString msg = cleaned(text);
    if (msg.isEmpty())
        return QString();
    QFile file(dataFilePath());
    // a file edited by hand may lack the final newline
    bool needNewline = false;
    if (file.open(QIODevice::ReadOnly)) {
        needNewline = file.size() > 0 && file.seek(file.size() - 1) && file.read(1) != "\n";
        file.close();
    }
    if (!file.open(QIODevice::Append | QIODevice::Text)) {
        qWarning() << "FileHelper: cannot write" << file.fileName() << file.errorString();
        return QString();
    }
    QTextStream out(&file);
    out.setCodec("UTF-8");
    if (needNewline)
        out << "\n";
    out << "custom: " << msg << "\n";
    return msg;
}

QString FileHelper::removeMessage(const QString &text)
{
    const QString msg = cleaned(text);
    QFile file(dataFilePath());
    if (msg.isEmpty() || !file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();
    QTextStream in(&file);
    in.setCodec("UTF-8");
    QStringList lines;
    bool removed = false;
    while (!in.atEnd()) {
        const QString line = in.readLine();
        const QString t = line.trimmed();
        // only the first matching custom line; comments and other
        // categories stay as they are
        if (!removed && t.toLower().startsWith(QLatin1String("custom:"))
                && t.mid(7).trimmed() == msg) {
            removed = true;
            continue;
        }
        lines << line;
    }
    file.close();
    if (!removed)
        return QString();
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
        qWarning() << "FileHelper: cannot write" << file.fileName() << file.errorString();
        return QString();
    }
    QTextStream out(&file);
    out.setCodec("UTF-8");
    for (const QString &l : lines)
        out << l << "\n";
    return msg;
}
