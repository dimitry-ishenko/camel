import QtQuick 1.1

Image {
    id: background
    width: 1920
    height: 1200
    clip: true
    source: "background.jpg"
    fillMode: Image.PreserveAspectCrop

    signal login()

    Rectangle {
        id: panel
        width: 400
        height: 180
        radius: 5
        color: "#30ffffff"
        border.color: "#a0e0e0e0"
        anchors.verticalCenterOffset: 80
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Item {
            id: user_area
            height: 30
            anchors.verticalCenter: parent.verticalCenter;
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 40

            Text {
                id: user_label
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: user_panel.left
                anchors.margins: user_text.anchors.margins
                anchors.rightMargin: 10

                text: "username"
                font: user_text.font
                color: "#ffffff"
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignRight
                clip: true

                Text {
                    anchors.fill: parent
                    anchors.topMargin: 1
                    anchors.rightMargin: -1
                    z: -1

                    text: parent.text
                    font: parent.font
                    color: "#60000000"
                    verticalAlignment: parent.verticalAlignment
                    horizontalAlignment: parent.horizontalAlignment
                    clip: true
                }
            }

            Rectangle {
                id: user_panel
                width: 200
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                color: "#30ffffff"
                border.color: "#a0e0e0e0"

                TextInput {
                    id: user_text
                    font.bold: false
                    objectName: "username"
                    anchors.fill: parent
                    anchors.margins: 4
                    font.family: "Terminus"
                    font.pointSize: 16
                    focus: true

                    Keys.onTabPressed: pass_text.focus = true
                    Keys.onReturnPressed: pass_text.focus = true
                }
            }
        }

        Item {
            id: pass_area
            height: user_area.height
            anchors.top: user_area.bottom
            anchors.topMargin: 10
            anchors.left: user_area.left
            anchors.right: user_area.right

            Text {
                id: pass_label
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: pass_panel.left
                anchors.margins: pass_text.anchors.margins
                anchors.rightMargin: 10

                text: "password"
                font: user_label.font
                color: user_label.color
                verticalAlignment: user_label.verticalAlignment
                horizontalAlignment: user_label.horizontalAlignment
                clip: true

                Text {
                    anchors.fill: parent
                    anchors.topMargin: 1
                    anchors.rightMargin: -1
                    z: -1

                    text: parent.text
                    font: parent.font
                    color: "#60000000"
                    verticalAlignment: parent.verticalAlignment
                    horizontalAlignment: parent.horizontalAlignment
                    clip: true
                }
            }

            Rectangle {
                id: pass_panel
                width: user_panel.width
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                color: user_panel.color
                border.color: user_panel.border.color

                TextInput {
                    id: pass_text
                    objectName: "password"
                    anchors.fill: parent
                    anchors.margins: user_text.anchors.margins
                    font: user_text.font

                    echoMode: TextInput.Password
                    passwordCharacter: "*"

                    Keys.onTabPressed: user_text.focus = true
                    Keys.onReturnPressed: login()
                }
            }
        }
    }
}
