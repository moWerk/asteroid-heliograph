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

// The banner itself: a message scrolling through, or an emoji blinking.
// Used by the page (small and full screen) and by the cover, so the home
// screen tile shows the same banner, scaled down.
Item {
    id: view

    property string message:   ""
    property bool   blinkMode: false
    property bool   smallFont: false
    // the text height; the screen width when big
    property real   base:      width
    // offsets as on the full screen banner, or as in the small preview
    property bool   big:       true
    property real   pixelsPerSecond: 300
    property real   blinkCycleMs:    1200
    property bool   running:   true

    // SailfishOS draws emoji from Twemoji's SVG-in-OpenType font, which
    // Qt 5.6 shows only as outlines; the built-in ones come as pictures.
    readonly property var twemoji: ["1f525", "1f680", "1f389", "1f4a9", "1f480", "1f921"]
    function emojiFile(text) {
        if (text.length !== 2) return ""
        var hi = text.charCodeAt(0), lo = text.charCodeAt(1)
        if (hi < 0xD800 || hi > 0xDBFF) return ""
        var cp = ((hi - 0xD800) * 0x400 + (lo - 0xDC00) + 0x10000).toString(16)
        return twemoji.indexOf(cp) >= 0 ? Qt.resolvedUrl("../images/twemoji/" + cp + ".svg") : ""
    }
    readonly property string emojiSource: blinkMode ? emojiFile(message) : ""

    BannerScroll {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -view.base * (view.big ? 0.03 : 0.0385)
        width:  parent.width
        height: view.base
        visible: !view.blinkMode
        message: view.message
        fontSize: view.smallFont ? view.base * 0.75 : view.base
        pixelsPerSecond: view.pixelsPerSecond
        scrolling: !view.blinkMode && view.running
    }

    Item {
        id: blinkItem
        anchors.centerIn: parent
        visible: view.blinkMode
        width: parent.width
        height: view.base

        Image {
            anchors.centerIn: parent
            width: view.base * 0.7
            height: width
            sourceSize { width: width; height: height }
            source: view.emojiSource
            visible: view.emojiSource !== ""
            smooth: true
        }

        Label {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -view.base * (view.big ? 0.1 : 0.0625)
            visible: view.emojiSource === ""
            text: view.blinkMode ? view.message : ""
            font.pixelSize: view.base * 0.81
            color: "white"
            verticalAlignment: Text.AlignVCenter
        }
    }

    SequentialAnimation {
        id: blinkAnim
        running: view.blinkMode && view.blinkCycleMs > 0 && view.running
        loops:   Animation.Infinite
        onRunningChanged: { if (!running) blinkItem.opacity = 1.0 }

        // Animators run on the render thread, like the scrolling
        OpacityAnimator {
            target: blinkItem
            to: 0.2; duration: view.blinkCycleMs * 0.67
            easing.type: Easing.InOutQuad
        }
        OpacityAnimator {
            target: blinkItem
            to: 1.0; duration: view.blinkCycleMs * 0.33
            easing.type: Easing.InOutQuad
        }
    }

    onBlinkCycleMsChanged: if (blinkAnim.running) blinkAnim.restart()
}
