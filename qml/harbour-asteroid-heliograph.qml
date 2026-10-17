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
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow {
    id: app

    property bool   messageOn: false

    // the shown banner, set by the page, for the cover
    property string currentMessage: ""
    property bool   blinkMode:    false
    property bool   smallFont:    false
    property real   bannerSpeed:  900
    property real   blinkCycleMs: 1200
    property real   screenWidth:  1

    allowedOrientations: Orientation.Portrait

    // A banner in the background would show to nobody; it closes when the
    // app leaves the screen.
    onApplicationActiveChanged: if (!applicationActive) messageOn = false

    initialPage: Component { MessagePage { } }

    // The home screen tile is the full screen banner, scaled down: black,
    // the message scrolling through at the same pace relative to the width.
    cover: Component {
        CoverBackground {
            id: cover

            Rectangle {
                anchors.fill: parent
                color: "black"
            }

            BannerView {
                anchors.fill: parent
                clip: true
                message: app.currentMessage
                blinkMode: app.blinkMode
                smallFont: app.smallFont
                base: width
                big: true
                pixelsPerSecond: app.bannerSpeed * width / app.screenWidth
                blinkCycleMs: app.blinkCycleMs
                running: cover.status === Cover.Active
            }
        }
    }
}
