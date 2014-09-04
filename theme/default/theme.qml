import QtQuick 1.1

Image {
    id: background
    source: "background.jpg"
    fillMode: Image.PreserveAspectCrop
    clip: true

    signal reset()
    signal error(string message)
    signal quit()

    onReset: {
        username.text = ""
        password.text = ""

        username.focus = true
    }

    onError: {
        error.text = message
    }

    Item {
        id: sessions
        objectName: "sessions"
        property variant text: [ ]
    }

    Item {
        id: session
        objectName: "session"
        property string text: ""
    }

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

        Text {
            id: hostname
            objectName: "hostname"
            width: 260
            height: 40
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter

            font.family: "Linux Biolinum"
            font.pointSize: 28
            font.bold: true
            color: "#ffffff"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            clip: true

            Text {
                anchors.fill: parent
                anchors.topMargin: 2
                anchors.leftMargin: 2
                z: -1

                text: parent.text
                font: parent.font
                color: "#60000000"
                verticalAlignment: parent.verticalAlignment
                horizontalAlignment: parent.horizontalAlignment
                clip: true
            }
        }

        Text {
            id: error
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            height: 20
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10

            font.family: "Terminus"
            font.pointSize: 14
            color: "red"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            clip: true

            onTextChanged: SequentialAnimation {
                PropertyAnimation {
                    target: error
                    property: "opacity"
                    from: 1
                    to: 1
                    duration: 4000
                }

                PropertyAnimation {
                    target: error
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 400
                    easing.type: Easing.InQuad
                }
            }

            Text {
                anchors.fill: parent
                anchors.topMargin: 2
                anchors.leftMargin: 2
                z: -1

                text: parent.text
                font: parent.font
                color: "#60000000"
                verticalAlignment: parent.verticalAlignment
                horizontalAlignment: parent.horizontalAlignment
                clip: true
            }
        }

        Item {
            id: username_area
            height: 30
            anchors.verticalCenter: parent.verticalCenter;
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 40

            Text {
                id: username_label
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: username_panel.left
                anchors.margins: username.anchors.margins
                anchors.rightMargin: 10

                text: "username"
                font: username.font
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
                id: username_panel
                width: 190
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                color: "#30ffffff"
                border.color: "#a0e0e0e0"

                TextInput {
                    id: username
                    objectName: "username"
                    anchors.fill: parent
                    anchors.margins: 4
                    font.family: "Terminus"
                    font.pointSize: 16

                    Keys.onTabPressed: password.focus = true
                    Keys.onReturnPressed: password.focus = true
                }
            }
        }

        Item {
            id: password_area
            height: username_area.height
            anchors.top: username_area.bottom
            anchors.topMargin: 10
            anchors.left: username_area.left
            anchors.right: username_area.right

            Text {
                id: password_label
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: password_panel.left
                anchors.margins: password.anchors.margins
                anchors.rightMargin: 10

                text: "password"
                font: username_label.font
                color: username_label.color
                verticalAlignment: username_label.verticalAlignment
                horizontalAlignment: username_label.horizontalAlignment
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
                id: password_panel
                width: username_panel.width
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                color: username_panel.color
                border.color: username_panel.border.color

                TextInput {
                    id: password
                    objectName: "password"
                    anchors.fill: parent
                    anchors.margins: username.anchors.margins
                    font: username.font

                    echoMode: TextInput.Password
                    passwordCharacter: "*"

                    Keys.onTabPressed: username.focus = true
                    Keys.onReturnPressed: quit()
                }
            }
        }
    }
}
