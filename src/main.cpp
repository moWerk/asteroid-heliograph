/*
 * Copyright (C) 2026 - Timo Könnecke <github.com/moWerk>
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

#include <sailfishapp.h>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QQuickView>
#include <QScopedPointer>
#include <QTimer>
#include <QtQml>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include "FileHelper.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setOrganizationName(QStringLiteral("net.mowerk"));
    app->setApplicationName(QStringLiteral("harbour-asteroid-heliograph"));

    qmlRegisterSingletonType<FileHelper>(
        "moWerk.FileHelper", 1, 0, "FileHelper",
        FileHelper::qmlInstance);

    // Your own messages live in the app's data directory; the first start
    // copies the documented template there.
    {
        const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir().mkpath(dir);
        if (!QFile::exists(dir + QStringLiteral("/custom.txt")))
            QFile::copy(SailfishApp::pathTo(QStringLiteral("custom.txt")).toLocalFile(),
                        dir + QStringLiteral("/custom.txt"));
    }

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    // Test hook: SFOS_SELFTEST_AUTOSTART=1 shows the banner without a tap.
    view->rootContext()->setContextProperty(QStringLiteral("selftestAutostart"),
                                            qEnvironmentVariableIsSet("SFOS_SELFTEST_AUTOSTART"));
    // Test hook: SFOS_SELFTEST_EDIT=1 adds a message the way the + does,
    // logs the lists, removes it the way the - does, logs again.
    view->rootContext()->setContextProperty(QStringLiteral("selftestEdit"),
                                            qEnvironmentVariableIsSet("SFOS_SELFTEST_EDIT"));
    view->setSource(SailfishApp::pathToMainQml());
    view->show();

    // Test hook, not used in normal runs: with SFOS_SELFTEST_SHOT=<file>
    // the window is grabbed after SFOS_SELFTEST_DELAY ms (default 6000)
    // and saved, so a build can be checked without looking at the phone.
    const QByteArray shot = qgetenv("SFOS_SELFTEST_SHOT");
    if (!shot.isEmpty()) {
        const int delay = qEnvironmentVariableIsSet("SFOS_SELFTEST_DELAY")
                ? qgetenv("SFOS_SELFTEST_DELAY").toInt() : 6000;
        QQuickView *v = view.data();
        QTimer::singleShot(delay, v, [v, shot]() {
            v->grabWindow().save(QString::fromLocal8Bit(shot));
        });
    }
    return app->exec();
}
