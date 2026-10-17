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
import Nemo.Configuration 1.0

// SailfishOS: own messages without C++, so the app is pure QML and one
// noarch package. Messages typed in the app live in dconf
// (/apps/harbour-asteroid-heliograph/typed, a JSON list) and can be
// removed in the app.
QtObject {
    id: store

    property QtObject _typedCfg: ConfigurationValue {
        key: "/apps/harbour-asteroid-heliograph/typed"
        defaultValue: "[]"
    }

    function _clean(text) {
        return String(text).replace(/[\r\n]+/g, " ").replace(/\s+/g, " ").trim()
    }

    function messages() {
        try {
            var list = JSON.parse(_typedCfg.value)
            return Array.isArray(list) ? list : []
        } catch (e) {
            return []
        }
    }

    // both return the stored text, "" when nothing changed
    function addMessage(text) {
        var msg = _clean(text)
        if (msg === "") return ""
        var list = messages()
        list.push(msg)
        _typedCfg.value = JSON.stringify(list)
        return msg
    }
    function removeMessage(text) {
        var list = messages()
        var i = list.indexOf(text)
        if (i < 0) return ""
        list.splice(i, 1)
        _typedCfg.value = JSON.stringify(list)
        return text
    }
}
