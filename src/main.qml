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

import QtQuick
import org.asteroid.controls
import org.asteroid.settings
import Nemo.KeepAlive

Application {
    id: app

    centerColor: "#2A1500"
    outerColor:  "#000000"

    property bool messageOn:       false
    property int  startBrightness: -1

    DisplayBlanking { preventBlanking: messageOn }

    Component.onDestruction: {
        if (startBrightness !== -1)
            displaySettings.brightness = startBrightness
    }

    DisplaySettings {
        id: displaySettings
        onBrightnessChanged: {
            if (app.startBrightness !== -1) return
            app.startBrightness = brightness
            brightness = maximumBrightness
        }
    }

    MessagePage {
        anchors.fill: parent
    }
}
