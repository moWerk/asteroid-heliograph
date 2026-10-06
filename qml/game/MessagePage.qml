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
import Sailfish.Silica 1.0 as Silica
import "."

Item {
    id: root

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

    anchors.fill: parent
    clip: true

    // SailfishOS: the built-in lists stay untouched; reload() builds the
    // shown lists from them and custom.txt, again after an in-app edit.
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

    // a QStringList from C++ arrives as a sequence wrapper; a plain array
    // is what indexOf, concat and JSON need
    function fileMessages(key) {
        var list = MessageStore.messagesForCategory(key)
        var out = []
        for (var i = 0; i < list.length; i++) out.push(list[i])
        return out
    }

    function reload() {
        var cats = baseCategories.slice()
        var msgs = baseMessages.map(function (list) { return list.slice() })
        // Read user-defined custom category entries
        var customMsgs = fileMessages("custom")
        hasCustomCategory = customMsgs.length > 0
        if (hasCustomCategory) {
            msgs.unshift(customMsgs)
            //% "Custom"
            cats.unshift(qsTrId("id-cat-custom"))
        }

        var keys = ["emergency", "navigation", "social", "fun"]
        for (var i = 0; i < keys.length; i++) {
            var extra = fileMessages(keys[i])
            if (extra.length > 0) {
                var idx = i + (hasCustomCategory ? 1 : 0)
                msgs[idx] = extra.concat(msgs[idx])
            }
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
        // SailfishOS: the banner turns with the tilt. A rectangle the size of
        // a tall screen, turned sideways, covers only a square of it. As a
        // square with the screen's diagonal it covers the screen at any angle.
        readonly property real fullSize: Math.sqrt(root.width * root.width + root.height * root.height)
        width:  app.messageOn ? fullSize : Dims.w(40)
        height: app.messageOn ? fullSize : Dims.w(40)
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
            onRunningChanged: { if (!running) blinkLabel.opacity = 1.0 }

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
            onBlinkCycleMsChanged: {
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

    // ── SailfishOS: own messages, typed in the app ────────────────────────────
    // + opens a text field; − removes the shown message of the Custom
    // category (second tap within 3 s confirms). Both write custom.txt.
    Row {
        id: editButtons
        anchors.top: messageCycler.bottom
        anchors.topMargin: Dims.l(6)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Dims.l(14)
        visible: !app.messageOn && !editor.visible

        Item {
            width: Dims.l(12); height: width
            Rectangle { anchors.fill: parent; radius: width / 2; color: "#000000"; opacity: 0.4 }
            Icon {
                anchors.centerIn: parent
                width: Dims.l(8); height: width
                name: "ios-add"
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -Dims.l(3)
                onClicked: editor.open()
            }
        }

        Item {
            id: removeButton
            property bool armed: false
            // typed in the app: removable; from custom.txt: QML can not
            // write the file, so the button says where the line lives
            readonly property string shown: root.hasCustomCategory && root.catIndex === 0
                                            ? root.messages[0][root.msgIndex] : ""
            readonly property bool fromFile: shown !== "" && !MessageStore.isTyped(shown)
            property bool hintFile: false
            width: Dims.l(12); height: width
            visible: root.hasCustomCategory && root.catIndex === 0
            Rectangle {
                anchors.fill: parent; radius: width / 2
                color: removeButton.armed ? "#B00020" : "#000000"
                opacity: removeButton.armed ? 0.9 : (removeButton.fromFile ? 0.2 : 0.4)
            }
            Icon {
                anchors.centerIn: parent
                width: Dims.l(8); height: width
                name: "ios-remove"
                opacity: removeButton.fromFile ? 0.5 : 1.0
            }
            Timer {
                id: disarm; interval: 3000
                onTriggered: { removeButton.armed = false; removeButton.hintFile = false }
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -Dims.l(3)
                onClicked: {
                    if (removeButton.fromFile) {
                        removeButton.hintFile = true
                        disarm.restart()
                        return
                    }
                    if (!removeButton.armed) {
                        removeButton.armed = true
                        disarm.restart()
                        return
                    }
                    removeButton.armed = false
                    disarm.stop()
                    var gone = MessageStore.removeMessage(removeButton.shown)
                    if (gone !== "") {
                        var next = root.msgIndex > 0 ? root.messages[0][root.msgIndex - 1] : ""
                        root.msgIndex = 0   // valid in any list while they change
                        root.reload()
                        root.showCustom(next)
                    }
                }
            }
        }
    }

    Label {
        anchors.top: editButtons.bottom
        anchors.topMargin: Dims.l(2)
        anchors.horizontalCenter: parent.horizontalCenter
        visible: (removeButton.armed || removeButton.hintFile) && editButtons.visible
        text: removeButton.hintFile
              //% "This one is in custom.txt"
              ? qsTrId("id-message-in-file")
              //% "Tap again to delete"
              : qsTrId("id-tap-again-to-delete")
        font.pixelSize: Dims.l(5)
        opacity: 0.8
    }

    Rectangle {
        id: editor
        anchors.fill: parent
        color: "#000000"
        opacity: 0.92
        visible: false
        z: 10

        function open() {
            input.text = ""
            visible = true
            input.forceActiveFocus()
        }
        function close() {
            input.focus = false
            visible = false
        }
        function save() {
            var stored = MessageStore.addMessage(input.text)
            close()
            if (stored !== "") {
                root.reload()
                root.showCustom(stored)
            }
        }

        // swallow taps on the dimmed area; tapping outside the field cancels
        MouseArea { anchors.fill: parent; onClicked: editor.close() }

        Column {
            anchors.top: parent.top
            anchors.topMargin: Dims.l(26)
            width: parent.width
            spacing: Dims.l(4)

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                //% "New message"
                text: qsTrId("id-new-message")
                font.pixelSize: Dims.l(7)
            }

            Silica.TextField {
                id: input
                width: parent.width
                //% "Your message"
                placeholderText: qsTrId("id-your-message")
                Silica.EnterKey.enabled: text.trim().length > 0
                Silica.EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                Silica.EnterKey.onClicked: editor.save()
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Dims.l(6)
                Silica.Button {
                    //% "Cancel"
                    text: qsTrId("id-cancel")
                    onClicked: editor.close()
                }
                Silica.Button {
                    //% "Add"
                    text: qsTrId("id-add")
                    enabled: input.text.trim().length > 0
                    onClicked: editor.save()
                }
            }
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
