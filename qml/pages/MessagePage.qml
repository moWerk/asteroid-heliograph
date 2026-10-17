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
import QtSensors 5.2
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import Nemo.KeepAlive 1.2
import "."

Page {
    id: root

    allowedOrientations: Orientation.Portrait

    property real userPixelsPerSecond: 300
    property real blinkCycleMs:        1200

    property bool isBlinkMode: catIndex === categories.indexOf("Emoji")
    property bool isSmallFont: catIndex === categories.indexOf("Emoji") || catIndex === categories.indexOf("Kaomoji")

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
        onMessageOnChanged: {
            if (!app.messageOn) {
                root.smoothedX = 0
                root.smoothedY = 0
            }
        }
    }

    // SailfishOS: the built-in lists stay untouched; reload() builds the
    // shown lists from them and the typed messages, again after an edit.
    readonly property var baseCategories: [
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

    readonly property var baseMessages: [
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

    property var  categories: baseCategories
    property var  messages:   baseMessages
    property bool hasCustomCategory: false

    property int catIndex: 0

    function reload() {
        var cats = baseCategories.slice()
        var msgs = baseMessages.map(function (list) { return list.slice() })
        // own messages, typed in the app, as the first category
        var customMsgs = MessageStore.messages()
        hasCustomCategory = customMsgs.length > 0
        if (hasCustomCategory) {
            msgs.unshift(customMsgs)
            //% "Custom"
            cats.unshift(qsTrId("id-cat-custom"))
        }
        categories = cats
        messages = msgs
    }

    Component.onCompleted: reload()

    // after an edit: show the Custom category at the given message, or the
    // first category when the last own message is gone
    function showCustom(text) {
        catIndex = 0
        msgIndex = 0
        if (hasCustomCategory) {
            var i = messages[0].indexOf(text)
            msgIndex = i >= 0 ? i : messages[0].length - 1
        }
        resetSpeed()
    }

    property int msgIndex: 0

    function resetSpeed() {
        userPixelsPerSecond = 900
        blinkCycleMs        = 1200
    }

    readonly property string shownMessage: messages[catIndex] ? messages[catIndex][msgIndex] : ""

    // the cover shows the same banner
    Binding { target: app; property: "currentMessage"; value: root.shownMessage }
    Binding { target: app; property: "blinkMode";      value: root.isBlinkMode }
    Binding { target: app; property: "smallFont";      value: root.isSmallFont }
    Binding { target: app; property: "bannerSpeed";    value: root.userPixelsPerSecond }
    Binding { target: app; property: "blinkCycleMs";   value: root.blinkCycleMs }
    Binding { target: app; property: "screenWidth";    value: root.width }

    // keep the pickers on the shown category and message, also after a
    // reload or an edit

    // --- Display: full brightness while the app runs, restored when it closes ---
    property int startBrightness: -1

    DisplayBlanking { preventBlanking: app.messageOn }

    Component.onDestruction: {
        if (startBrightness !== -1)
            displaySettings.brightness = startBrightness
    }

    DisplaySettings {
        id: displaySettings
        onBrightnessChanged: {
            if (root.startBrightness !== -1) return
            root.startBrightness = brightness
            brightness = maximumBrightness
        }
    }

    readonly property real gap: Theme.paddingLarge * 8 / 3
    readonly property real squareSize: width - 8 * Theme.paddingLarge

    // The page scrolls, so a picker's list can open in full below it.
    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: Math.max(height, editButtons.y + editButtons.height + root.gap)
        interactive: !app.messageOn

        VerticalScrollDecorator { }

        Item {
            id: content
            width: flick.width
            height: flick.contentHeight

            PageHeader {
                id: header
                //% "Heliograph Banner"
                title: qsTrId("id-heliograph-banner")
                visible: !app.messageOn
            }

            Picker {
                id: categoryBox
                anchors.top: header.bottom
                width: parent.width
                visible: !app.messageOn
                //% "Category"
                label: qsTrId("id-category")
                model: root.categories
                currentIndex: root.catIndex
                onPicked: {
                    if (index === root.catIndex) return
                    root.catIndex = index
                    root.msgIndex = 0
                    root.resetSpeed()
                }
            }

            // where the banner sits while it is small
            Item {
                id: bannerSlot
                anchors {
                    top: categoryBox.bottom
                    topMargin: root.gap
                    horizontalCenter: parent.horizontalCenter
                }
                width: root.squareSize
                height: root.squareSize
            }

            Rectangle {
                id: messageRect
                color: "black"
                // SailfishOS: the banner turns with the tilt. A rectangle the size of
                // a tall screen, turned sideways, covers only a square of it. As a
                // square with the screen's diagonal it covers the screen at any angle.
                readonly property real fullSize: Math.sqrt(root.width * root.width + root.height * root.height)
                readonly property real size: app.messageOn ? fullSize : root.squareSize
                // the banner text scales with the screen width when big, with the square when small
                readonly property real base: app.messageOn ? root.width : root.squareSize
                width:  size
                height: size
                // big: centred on the screen, wherever the page is scrolled
                x: app.messageOn ? (root.width  - size) / 2 : bannerSlot.x
                y: app.messageOn ? flick.contentY + (root.height - size) / 2 : bannerSlot.y
                z: 1
                radius: app.messageOn ? 0 : Theme.paddingLarge
                // Only the small preview needs clipping. Big, the square is
                // larger than the screen, and a clip on a rotated item costs
                // a stencil pass every frame.
                clip: !app.messageOn

                rotation: app.messageOn ? root.rollAngle : 0
                Behavior on rotation {
                    NumberAnimation { duration: 200; easing.type: Easing.Linear }
                }

                BannerView {
                    anchors.fill: parent
                    message: root.shownMessage
                    blinkMode: root.isBlinkMode
                    smallFont: root.isSmallFont
                    base: messageRect.base
                    big: app.messageOn
                    // small: two square widths per second, as on the watch
                    pixelsPerSecond: app.messageOn ? root.userPixelsPerSecond : root.squareSize * 2
                    blinkCycleMs: root.blinkCycleMs
                    running: Qt.application.active
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !app.messageOn
                    onClicked: app.messageOn = true
                }

                Behavior on width  { NumberAnimation { duration: 120; easing.type: Easing.InCurve  } }
                Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.InCurve  } }
                Behavior on x      { NumberAnimation { duration: 120; easing.type: Easing.InCurve  } }
                Behavior on y      { NumberAnimation { duration: 120; easing.type: Easing.InCurve  } }
                Behavior on radius { NumberAnimation { duration: 120; easing.type: Easing.OutQuint } }
            }

            Picker {
                id: messageBox
                anchors {
                    top: bannerSlot.bottom
                    topMargin: root.gap
                }
                width: parent.width
                visible: !app.messageOn
                //% "Message"
                label: qsTrId("id-message")
                model: root.messages[root.catIndex]
                currentIndex: root.msgIndex
                onPicked: {
                    root.msgIndex = index
                    root.resetSpeed()
                }
            }

            // ── SailfishOS: own messages, typed in the app ────────────────────────────
            // Add Message opens a dialog; Remove takes the shown message of the
            // Custom category out, after the usual remorse timer. Both write dconf.
            RemorsePopup { id: remorse }

            Row {
                id: editButtons
                anchors {
                    top: messageBox.bottom
                    topMargin: root.gap
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: Theme.paddingLarge
                visible: !app.messageOn

                Button {
                    //% "Add Message"
                    text: qsTrId("id-add-message")
                    onClicked: {
                        var dialog = pageStack.push(Qt.resolvedUrl("AddMessageDialog.qml"))
                        dialog.accepted.connect(function () {
                            var stored = MessageStore.addMessage(dialog.text)
                            if (stored !== "") {
                                root.reload()
                                root.showCustom(stored)
                            }
                        })
                    }
                }

                Button {
                    visible: root.hasCustomCategory && root.catIndex === 0
                    //% "Remove"
                    text: qsTrId("id-remove")
                    onClicked: {
                        var shown = root.shownMessage
                        //% "Removing"
                        remorse.execute(qsTrId("id-removing"), function () {
                            var gone = MessageStore.removeMessage(shown)
                            if (gone !== "") {
                                var i = root.messages[0].indexOf(shown)
                                var next = i > 0 ? root.messages[0][i - 1] : ""
                                root.msgIndex = 0   // valid in any list while they change
                                root.reload()
                                root.showCustom(next)
                            }
                        })
                    }
                }
            }
        }
    }

    // While the banner is big: a tap closes it, a drag along it changes the speed.
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
        property real threshold:       Theme.startDragDistance

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
                    return
                }
            }

            if (!tracking) return
            var r     = -pressAngle * Math.PI / 180
            var delta = dx * Math.cos(r) - dy * Math.sin(r)
            if (root.isBlinkMode) {
                root.blinkCycleMs = Math.max(300, Math.min(1500, pressBlinkCycle - delta / 1.5))
            } else {
                // SailfishOS: up to 2000 px/s, 1500 was too slow for the long phone screen (mo)
                root.userPixelsPerSecond = Math.max(160, Math.min(2000, pressSpeed - delta / 1.5))
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
        rotation: app.messageOn ? root.rollAngle : 0
        text: root.isBlinkMode
            ? (root.blinkCycleMs > 0 ? Math.round(60000 / root.blinkCycleMs) + " bpm" : "static")
            : Math.round(root.userPixelsPerSecond) + " px/s"
        font.pixelSize: Theme.fontSizeHuge * 1.25
        color: Theme.highlightColor
        opacity: 0
        Behavior on opacity { FadeAnimation { duration: 150 } }
    }
}
