import QtQuick 1.1

Image {
    id: background
    width: 1920
    height: 1200
    clip: true
    source: "background.jpg"
    fillMode: Image.PreserveAspectCrop

    signal user(string x)
    signal pass(string x)
    signal exec(string x)

    Rectangle {
        id: panel
        width: 330
        height: 150
        radius: 5
        color: "#30ffffff"
        border.color: "#a0e0e0e0"
        anchors.verticalCenterOffset: 80
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            id: user_label
            width: 60
            text: "username"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            anchors.top: user_panel.top
            anchors.bottom: user_panel.bottom
            anchors.left: panel.left
            anchors.leftMargin: 10
            anchors.right: user_panel.left
            anchors.rightMargin: 10
            clip: true
            font.pointSize: 11
        }

        Rectangle {
            id: user_panel
            width: 140
            height: 24
            color: "#30ffffff"
            border.color: "#a0e0e0e0"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            TextInput {
                id: user_text
                anchors.fill: parent
                anchors.margins: 2
                font.pointSize: 12
                focus: true

                Keys.onPressed:
                    if(event.key === Qt.Key_Tab || event.key === Qt.Key_Return) {
                        user(user_text.text);
                        pass_text.focus = true;
                        event.accepted = true;
                    }
            }
        }

        Text {
            id: pass_label
            width: 60
            text: "password"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            anchors.top: pass_panel.top
            anchors.bottom: pass_panel.bottom
            anchors.left: panel.left
            anchors.leftMargin: 10
            anchors.right: pass_panel.left
            anchors.rightMargin: 10
            clip: true
            font.pointSize: 11
        }

        Rectangle {
            id: pass_panel
            width: 140
            height: 24
            color: "#30ffffff"
            border.color: "#a0e0e0e0"
            anchors.top: user_panel.top
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter

            TextInput {
                id: pass_text
                passwordCharacter: "*"
                echoMode: TextInput.Password
                anchors.fill: parent
                anchors.margins: 2
                font.pointSize: 12

                Keys.onPressed:
                    if(event.key == Qt.Key_Tab) {
                        user_text.focus = true;
                        event.accepted = true;
                    }
                    else if(event.key == Qt.Key_Return) {
                        pass(pass_text.text)
                        event.accepted = true
                    }
            }
        }

    }
}
