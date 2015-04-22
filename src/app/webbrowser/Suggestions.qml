/*
 * Copyright 2013-2014 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 1.1

Rectangle {
    id: suggestions

    property var searchTerms
    property var models
    property int count: models.reduce(countItems, 0)
    property alias contentHeight: suggestionsList.contentHeight

    signal selected(url url)

    radius: units.gu(0.5)
    border {
        color: "#dedede"
        width: 1
    }

    clip: true

    ListView {
        id: suggestionsList
        anchors.fill: parent

        model: suggestions.models
        delegate: Column {
            id: suggestionsSection
            width: suggestionsList.width
            height: childrenRect.height

            property string icon: models[index].icon
            property bool displayUrl: models[index].displayUrl
            property int firstItemIndex: models.slice(0, index).reduce(countItems, 0)

            Repeater {
                id: suggestionsSource
                model: modelData

                delegate: Suggestion {
                    id: suggestion
                    width: suggestionsList.width
                    showDivider: suggestionsSection.firstItemIndex + index <
                                 suggestions.count - 1

                    // Necessary to support both using objects inheriting from
                    // QAbstractItemModel and JS arrays as models, since they
                    // expose their data differently
                    property var item: (model.modelData) ? model.modelData : model

                    title: highlightTerms(item.title)
                    subtitle: suggestionsSection.displayUrl ? highlightTerms(item.url) : ""
                    icon: suggestionsSection.icon

                    onSelected: suggestions.selected(item.url)
                }
            }
        }
    }

    Scrollbar {
        flickableItem: suggestionsList
        align: Qt.AlignTrailing
    }

    function escapeTerm(term) {
        // Build a regular expression suitable for highlighting a term
        // in a case-insensitive manner and globally, by escaping
        // special characters (a simpler version of preg_quote).
        var escaped = term.replace(/[().?]/g, '\\$&')
        return new RegExp(escaped, 'ig')
    }

    function highlightTerms(text) {
        // Highlight the matching terms (bold and Ubuntu orange)
        if (text === undefined) {
            return ''
        }
        var highlighted = text.toString()
        var count = searchTerms.length
        var highlight = '<b><font color="%1">$&</font></b>'.arg(UbuntuColors.orange)
        for (var i = 0; i < count; ++i) {
            var term = searchTerms[i]
            highlighted = highlighted.replace(escapeTerm(term), highlight)
        }
        highlighted = highlighted.replace(new RegExp('&', 'g'), '&amp;')
        highlighted = '<html>' + highlighted + '</html>'
        return highlighted
    }

    function countItems(total, model) {
        return total + (model.hasOwnProperty("length") ? model.length : model.count);
    }
}
