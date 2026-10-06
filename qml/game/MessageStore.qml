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

pragma Singleton
import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

// SailfishOS: own messages without C++, so the app is pure QML and one
// noarch package (replaces FileHelper, same function names).
// - Messages typed in the app live in dconf (/apps/harbour-asteroid-heliograph/typed,
//   a JSON list) and can be removed in the app.
// - A hand-written custom.txt in the app's data directory is still read,
//   with the same "category: message" lines as before. QML can read files
//   but not write them, so lines from the file are only removed by editing it.
QtObject {
    id: store

    readonly property string filePath: StandardPaths.data + "/custom.txt"

    property QtObject _typedCfg: ConfigurationValue {
        key: "/apps/harbour-asteroid-heliograph/typed"
        defaultValue: "[]"
    }
    property var _fileLines: []

    function _typed() {
        try {
            var list = JSON.parse(_typedCfg.value)
            return Array.isArray(list) ? list : []
        } catch (e) {
            return []
        }
    }

    // custom.txt: read once at start, as before ("takes effect on next launch")
    function _readFile() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + filePath, false)   // local file, synchronous
        try { xhr.send() } catch (e) { return [] }
        var out = []
        var lines = (xhr.responseText || "").split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line === "" || line.charAt(0) === "#") continue
            var c = line.indexOf(":")
            if (c < 1) continue
            var msg = line.substring(c + 1).trim()
            if (msg !== "") out.push({ key: line.substring(0, c).trim().toLowerCase(), text: msg })
        }
        return out
    }

    function _clean(text) {
        return String(text).replace(/[\r\n]+/g, " ").replace(/\s+/g, " ").trim()
    }

    // file lines of that category; for "custom" the typed ones follow
    function messagesForCategory(key) {
        var out = []
        for (var i = 0; i < _fileLines.length; i++)
            if (_fileLines[i].key === key) out.push(_fileLines[i].text)
        if (key === "custom") out = out.concat(_typed())
        return out
    }

    function isTyped(text) { return _typed().indexOf(text) >= 0 }

    // both return the stored text, "" when nothing changed
    function addMessage(text) {
        var msg = _clean(text)
        if (msg === "") return ""
        var list = _typed()
        list.push(msg)
        _typedCfg.value = JSON.stringify(list)
        return msg
    }
    function removeMessage(text) {
        var list = _typed()
        var i = list.indexOf(text)
        if (i < 0) return ""
        list.splice(i, 1)
        _typedCfg.value = JSON.stringify(list)
        return text
    }

    Component.onCompleted: {
        _fileLines = _readFile()
        console.log("Heliograph: custom.txt " + filePath + ", " + _fileLines.length + " lines; "
                    + _typed().length + " typed messages")
    }
}
