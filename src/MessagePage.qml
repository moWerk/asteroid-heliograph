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

import QtQuick 2.9
import QtSensors 5.11
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0

Item {
    id: root

    property real userPixelsPerSecond: 300
    property real blinkCycleMs:        1200

    property bool isBlinkMode: catIndex === 4
    property bool isSmallFont: catIndex === 4 || catIndex === 5

    property real smoothedX: 0
    property real smoothedY: 0
    property real rollAngle: Math.atan2(smoothedX, smoothedY) * 180 / Math.PI

    Accelerometer {
        id: accel
        active: app.messageOn
        dataRate: 30
        onReadingChanged: {
            root.smoothedX = root.smoothedX + 0.4 * (reading.x - root.smoothedX)
            root.smoothedY = root.smoothedY + 0.4 * (reading.y - root.smoothedY)
        }
    }

    Connections {
        target: app
        function onMessageOnChanged() {
            if (!app.messageOn) {
                root.smoothedX = 0
                root.smoothedY = 0
            }
        }
    }

    anchors.fill: parent
    clip: true

    property var categories: [
        //% "Emergency"
        qsTrId("id-cat-emergency"),
        //% "Navigation"
        qsTrId("id-cat-navigation"),
        //% "Social"
        qsTrId("id-cat-social"),
        //% "Fun"
        qsTrId("id-cat-fun"),
        "Emoji",
        "Kaomoji"
    ]

    property var messages: [
        [
            //% "Help"
            qsTrId("id-msg-help"),
            //% "Call 911"
            qsTrId("id-msg-call-911"),
            //% "Need help"
            qsTrId("id-msg-need-help"),
            //% "Lost"
            qsTrId("id-msg-lost"),
            //% "Injured"
            qsTrId("id-msg-injured")
        ],
        [
            //% "Follow me"
            qsTrId("id-msg-follow-me"),
            //% "This way"
            qsTrId("id-msg-this-way"),
            //% "Come over"
            qsTrId("id-msg-come-over"),
            //% "Stay back"
            qsTrId("id-msg-stay-back")
        ],
        [
            //% "Let's go!"
            qsTrId("id-msg-lets-go"),
            //% "Taxi!"
            qsTrId("id-msg-taxi"),
            //% "Encore!"
            qsTrId("id-msg-encore"),
            //% "Quiet!"
            qsTrId("id-msg-quiet"),
            //% "Oi!"
            qsTrId("id-msg-oi"),
            //% "Over here!"
            qsTrId("id-msg-over-here")
        ],
        [
            //% "Boooring"
            qsTrId("id-msg-boooring"),
            //% "Free hugs"
            qsTrId("id-msg-free-hugs"),
            //% "Burp!"
            qsTrId("id-msg-burp"),
            //% "Plot twist!"
            qsTrId("id-msg-plot-twist")
        ],
        ["\uD83D\uDD25", "\uD83D\uDE80", "\uD83C\uDF89",
         "\uD83D\uDCA9", "\uD83D\uDC80", "\uD83E\uDD21"],
        ["\u00AF\\\_(\u30C4)_/\u00AF",
         "(\u256F\u00B0\u25A1\u00B0\uFF09\u256F\uFE35 \u253B\u2501\u253B",
         "( \u0361\u00B0 \u035C\u0296 \u0361\u00B0)",
         "(^_^)",
         "<(^_^<)"]
    ]

    property int catIndex: 0
    property int msgIndex: 0

    function resetSpeed() {
        userPixelsPerSecond = 900
        blinkCycleMs        = 1200
    }

    //% "Message"
    PageHeader {
        text: qsTrId("id-message")
        visible: !app.messageOn
    }

    ValueCycler {
        id: categoryCycler
        anchors {
            bottom:       messageRect.top
            bottomMargin: Dims.l(1)
            left:         parent.left
            right:        parent.right
        }
        height: Dims.l(16)
        valueArray:   categories
        currentValue: categories[catIndex]
        onValueChanged: {
            catIndex = categories.indexOf(value)
            msgIndex = 0
            resetSpeed()
        }
    }

    Rectangle {
        id: messageRect
        anchors.centerIn: parent
        color: "#000000"
        width:  app.messageOn ? root.width  : Dims.w(40)
        height: app.messageOn ? root.height : Dims.w(40)
        radius: app.messageOn
            ? (DeviceSpecs.hasRoundScreen ? width / 2 : 0)
            : Dims.l(4)
        clip: true

        rotation: app.messageOn ? root.rollAngle : 0
        Behavior on rotation {
            NumberAnimation { duration: 200; easing.type: Easing.Linear }
        }

        BannerScroll {
            id: bannerScroll
            anchors.centerIn: parent
            anchors.verticalCenterOffset: app.messageOn ? -Dims.l(3) : -Dims.l(1.54)
            width:  parent.width
            height: app.messageOn ? Dims.l(100) : Dims.l(40)
            visible: !root.isBlinkMode
            message: messages[catIndex][msgIndex]
            fontSize: {
                var base = app.messageOn ? Dims.l(100) : Dims.l(40)
                return root.isSmallFont ? base * 0.75 : base
            }
            dimsPerSecond: app.messageOn ? root.userPixelsPerSecond / Dims.l(1) : 80
            scrolling: !root.isBlinkMode
        }

        Label {
            id: blinkLabel
            anchors.centerIn: parent
            anchors.verticalCenterOffset: app.messageOn ? -Dims.l(10) : -Dims.l(2.5)
            visible: root.isBlinkMode
            text: root.isBlinkMode ? messages[catIndex][msgIndex] : ""
            font.pixelSize: {
                var base = app.messageOn ? Dims.l(100) : Dims.l(40)
                return base * 0.81
            }
            verticalAlignment: Text.AlignVCenter
            opacity: 1.0
        }

        SequentialAnimation {
            id: blinkAnim
            running: root.isBlinkMode && root.blinkCycleMs > 0
            loops:   Animation.Infinite
            function onRunningChanged() { if (!running) blinkLabel.opacity = 1.0 }

            NumberAnimation {
                target: blinkLabel; property: "opacity"
                to: 0.2; duration: root.blinkCycleMs * 0.67
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: blinkLabel; property: "opacity"
                to: 1.0; duration: root.blinkCycleMs * 0.33
                easing.type: Easing.InOutQuad
            }
        }

        Connections {
            target: root
            function onBlinkCycleMsChanged() {
                if (root.isBlinkMode && root.blinkCycleMs > 0) {
                    blinkAnim.restart()
                } else {
                    blinkAnim.stop()
                    blinkLabel.opacity = 1.0
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: !app.messageOn
            onClicked: app.messageOn = true
        }

        Behavior on width  { NumberAnimation { duration: 120; easing.type: Easing.InCurve  } }
        Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.InCurve  } }
        Behavior on radius { NumberAnimation { duration: 120; easing.type: Easing.OutQuint } }
    }

    ValueCycler {
        id: messageCycler
        anchors {
            top:       messageRect.bottom
            topMargin: Dims.l(2)
            left:      parent.left
            right:     parent.right
        }
        height: Dims.l(16)
        valueArray:   messages[catIndex]
        currentValue: messages[catIndex][msgIndex]
        onValueChanged: {
            msgIndex = messages[catIndex].indexOf(value)
            resetSpeed()
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: app.messageOn

        property real pressX:          0
        property real pressY:          0
        property real pressSpeed:      0
        property real pressBlinkCycle: 0
        property real pressAngle:      0
        property bool tracking:        false
        property bool axisDecided:     false
        property real threshold:       Dims.l(3)

        onPressed: {
            pressX          = mouse.x
            pressY          = mouse.y
            pressSpeed      = root.userPixelsPerSecond
            pressBlinkCycle = root.blinkCycleMs
            pressAngle      = root.rollAngle
            tracking        = false
            axisDecided     = false
        }

        onPositionChanged: {
            var dx = mouse.x - pressX
            var dy = mouse.y - pressY

            if (!axisDecided) {
                if (Math.sqrt(dx*dx + dy*dy) < threshold) return
                axisDecided = true
                var rad        = -pressAngle * Math.PI / 180
                var scrollAxis = dx * Math.cos(rad) - dy * Math.sin(rad)
                var crossAxis  = dx * Math.sin(rad) + dy * Math.cos(rad)
                if (Math.abs(scrollAxis) >= Math.abs(crossAxis)) {
                    tracking        = true
                    preventStealing = true
                } else {
                    mouse.accepted = false
                    return
                }
            }

            if (!tracking) return
            var r     = -pressAngle * Math.PI / 180
            var delta = dx * Math.cos(r) - dy * Math.sin(r)
            if (root.isBlinkMode) {
                root.blinkCycleMs = Math.max(300, Math.min(1500, pressBlinkCycle - delta / 1.5))
            } else {
                root.userPixelsPerSecond = Math.max(160, Math.min(1500, pressSpeed - delta / 1.5))
            }
            speedLabel.opacity = 1
        }

        onReleased: {
            if (!tracking) app.messageOn = false
            tracking        = false
            axisDecided     = false
            preventStealing = false
            speedHideTimer.restart()
        }

        onCanceled: {
            tracking        = false
            axisDecided     = false
            preventStealing = false
            speedHideTimer.restart()
        }
    }

    Timer {
        id: speedHideTimer
        interval: 800
        repeat:   false
        onTriggered: speedLabel.opacity = 0
    }

    Label {
        id: speedLabel
        anchors.centerIn: parent
        visible: app.messageOn
        enabled: false
        rotation: app.messageOn ? root.rollAngle : 0
        text: root.isBlinkMode
            ? (root.blinkCycleMs > 0 ? Math.round(60000 / root.blinkCycleMs) + " bpm" : "static")
            : Math.round(root.userPixelsPerSecond) + " px/s"
        font.pixelSize: Dims.l(14)
        color: "#00A698"
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
