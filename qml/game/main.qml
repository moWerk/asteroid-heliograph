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

import QtQuick 2.6
import QtGraphicalEffects 1.0
import org.nemomobile.systemsettings 1.0
import Nemo.KeepAlive 1.2
import "."

// SailfishOS: Application of org.asteroid.utils draws a radial background;
// here a plain Item does the same. DisplaySettings comes from
// org.nemomobile.systemsettings instead of org.asteroid.settings.
Item {
    id: app
    anchors.fill: parent

    property color centerColor: "#2A1500"
    property color outerColor:  "#000000"

    RadialGradient {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: app.centerColor }
            GradientStop { position: 0.5; color: app.outerColor }
        }
    }


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
