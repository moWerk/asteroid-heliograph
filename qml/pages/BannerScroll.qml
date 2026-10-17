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

// The text runs through with an XAnimator, which moves it on the render
// thread in step with the display; a Timer stepping x from JavaScript gave
// uneven steps and visible stutter. The parent clips where needed.
Item {
    id: root

    property string message:        ""
    property real   fontSize:       height
    property real   pixelsPerSecond: 300
    property bool   scrolling:      true

    Label {
        id: scrollLabel
        x: root.width
        y: Math.round((root.height - contentHeight) / 2)
        text:           root.message.toUpperCase()
        font.pixelSize: root.fontSize
        font.weight:    Font.Bold
        // the banner is white on black in any ambience
        color:          "white"
        verticalAlignment: Text.AlignVCenter
        onContentWidthChanged: root._run(root.width)
    }

    readonly property real _end: -scrollLabel.contentWidth
    property real _x0: 0
    property real _t0: 0
    property real _v:  1
    property bool _manual: false

    // where the text is now; an Animator writes x back only when it stops
    function _currentX() {
        return Math.max(_end, _x0 - _v * (Date.now() - _t0) / 1000)
    }

    function _run(fromX) {
        _manual = true
        anim.stop()
        _manual = false
        if (!scrolling || scrollLabel.contentWidth <= 0 || pixelsPerSecond <= 0) {
            scrollLabel.x = root.width
            return
        }
        _x0 = fromX
        _t0 = Date.now()
        _v  = pixelsPerSecond
        anim.from = fromX
        anim.to = _end
        anim.duration = Math.max(1, (fromX - _end) / _v * 1000)
        anim.start()
    }

    XAnimator {
        id: anim
        target: scrollLabel
        // A pass can be started while the text is still being measured and
        // end short of the real end; then it carries on instead of starting
        // over halfway through the text.
        onRunningChanged: {
            if (running || root._manual) return
            root._run(to > root._end + 1 ? to : root.width)
        }
    }

    onPixelsPerSecondChanged: if (anim.running) _run(_currentX())
    onScrollingChanged: _run(root.width)
    onWidthChanged: _run(root.width)
    Component.onCompleted: _run(root.width)
}
