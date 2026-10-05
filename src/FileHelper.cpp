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
