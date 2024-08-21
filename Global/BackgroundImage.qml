// Pegasus Frontend
// Copyright (C) 2017-2018  Mátyás Mustoha
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


import QtQuick 2.15
import QtGraphicalEffects 1.12
import "qrc:/qmlutils" as PegasusUtils

Item {
    property var game

    visible: game

    readonly property double currentMaxOpacity: game && images.length > 0 && 1.0 || 0.35
    readonly property var images: fanArt(game)

    PegasusUtils.AutoScroll {
        id: autoScroll
        anchors.fill: parent
        scrollWaitDuration: 1000
        pixelsPerSecond: 15

        Column {
            id: imageColumn
            width: parent.width
            height: childrenRect.height
            spacing: -height * 0.05

            Repeater {
                id: repeater
                model: images
                delegate: Item {
                    width: parent.width
                    height: root.height * 0.9

                    Rectangle {
                        id: screenshotBox
                        anchors.fill: parent
                        opacity: 0.5
                        visible: false
                        Image {
                            id: screenshotImage
                            source: modelData
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            opacity: currentMaxOpacity
                            antialiasing: true
                            asynchronous: true
                            smooth: false
                        }
                    }

                    LinearGradient {
                        id: mask
                        anchors.fill: screenshotBox
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.05; color: "white" }
                            GradientStop { position: 0.97; color: "white" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                        visible: false
                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: screenshotBox
                        maskSource: mask
                    }
                }
            }
        }
    }

    LinearGradient {
        z: parent.z + 1
        width: parent.width * 0.75
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        start: Qt.point(0, 0)
        end: Qt.point(width, 0)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.5; color: "#cc000000" }
        }
    }

    function steamAppID (gameData) {
        var str = gameData.assets.boxFront.split("header");
        return str[0];
    }

    function steamHero(gameData) {
        return steamAppID(gameData) + "/library_hero.jpg";
    }

    function steamPage_bg_raw(gameData) {
        return steamAppID(gameData) + "/page_bg_raw.jpg";
    }

    function fanArt(data) {
        var images = [];
        if (data != null) {
            if (data.assets.boxFront.includes("/header.jpg"))
                images.push(steamHero(data));
            else {
                if (data.assets.background != "")
                    images.push(data.assets.background);
                else if (data.assets.screenshots.length > 0)
                    images = images.concat(data.assets.screenshots);
                else if (data.assets.titlescreen.length > 0)
                    images = images.concat(data.assets.titlescreen);
                else
                    return ""
            }
        }
        return images;
    }

}