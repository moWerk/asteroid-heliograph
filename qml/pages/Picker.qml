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

// A ComboBox in two lines: the label as Silica sets it, the value below at
// double size, easy to hit on a phone. A tap opens the list below it.
BackgroundItem {
    id: picker

    property string label
    property var    model: []
    property int    currentIndex: 0
    signal picked(int index)

    property ContextMenu menu: ContextMenu {
        Repeater {
            model: picker.model
            MenuItem {
                text: modelData
                onClicked: picker.picked(index)
            }
        }
    }

    contentHeight: column.height + 2 * Theme.paddingLarge * 2
    // follows the list as it opens and closes, as Silica's ComboBox does;
    // switching back at once showed the closing list inside the picker
    height: contentHeight + (menu.parent === menuAnchor ? menu.height : 0)
    // The list opens on this anchor below the text, not on the picker:
    // ContextMenu highlights its whole parent while it opens, which flashed
    // over the label (mo, found in Benchymark 2026-10-17).
    onClicked: menu.open(menuAnchor)

    Item {
        id: menuAnchor
        y: picker.contentHeight
        width: picker.width
        height: picker.menu.parent === menuAnchor ? picker.menu.height : 0
    }

    Column {
        id: column
        x: Theme.horizontalPageMargin
        y: Theme.paddingLarge * 2
        width: parent.width - 2 * x

        Label {
            text: picker.label
            color: picker.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            font.pixelSize: Theme.fontSizeMedium
        }
        Label {
            width: parent.width
            text: picker.model[picker.currentIndex] !== undefined ? picker.model[picker.currentIndex] : ""
            color: picker.highlighted ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeMedium * 2
            truncationMode: TruncationMode.Fade
        }
    }
}
