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

Dialog {
    id: dialog

    property alias text: input.text

    allowedOrientations: Orientation.Portrait
    canAccept: input.text.trim().length > 0

    Column {
        width: parent.width

        DialogHeader {
            //% "Add"
            acceptText: qsTrId("id-add")
            //% "Cancel"
            cancelText: qsTrId("id-cancel")
        }

        TextField {
            id: input
            width: parent.width
            focus: true
            //% "New message"
            label: qsTrId("id-new-message")
            //% "Your message"
            placeholderText: qsTrId("id-your-message")
            EnterKey.enabled: text.trim().length > 0
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: dialog.accept()
        }
    }
}
