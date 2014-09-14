import QtQuick 1.1

Rectangle {
    ////////////////////////////////////////
    signal reset()

    signal info(string text)
    signal error(string text)

    signal login()
    signal reboot()
    signal poweroff()

    ////////////////////////////////////////
    onReset: {
        username.text = ""
        password.text = ""
        username.focus = true
    }

    ////////////////////////////////////////
    onInfo: message(text, "#555555")
    onError: message(text, "#ff0000")

    Connections {
        target: settings
        onSessionChanged: info(settings.session)
    }

    ////////////////////////////////////////
    function message(text, color) {
        animation.stop()
        animation_color.value = color
        message_label.text = text
        animation.start()
    }

    SequentialAnimation {
        id: animation

        PropertyAction {
            id: animation_color
            target: message_label
            property: "color"
            value: "white"
        }
        PropertyAction {
            target: message_label
            property: "opacity"
            value: 1
        }
        PauseAnimation {
            duration: 4000
        }
        PropertyAnimation {
            target: message_label
            property: "opacity"
            from: 1
            to: 0
            duration: 300
            easing.type: Easing.InQuad
        }
    }

    ////////////////////////////////////////
    Keys.onPressed: {
        switch(event.key) {
            case Qt.Key_Escape: reset()
                break
            case Qt.Key_F1: info("F8 session F10 reboot F11 poweroff")
                break
            case Qt.Key_F8: settings.nextSession()
                break
            case Qt.Key_F10: reboot()
                break
            case Qt.Key_F11: poweroff()
                break
        }
    }

    ////////////////////////////////////////
    Image {
        id: background
        source: "background.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        clip: true

        ////////////////////////////////////////
        Rectangle {
            id: panel
            width: 380
            height: 180
            radius: 5
            color: "#30ffffff"
            border.color: "#a0e0e0e0"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors { verticalCenterOffset: 80; verticalCenter: parent.verticalCenter }

            ////////////////////////////////////////
            Text {
                id: hostname
                objectName: "hostname"
                width: 260
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter
                anchors { top: parent.top; topMargin: 16 }
                text: settings.hostname
                font { family: "Linux Biolinum"; pointSize: 28; bold: true }
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                clip: true
            }

            ////////////////////////////////////////
            Text {
                id: message_label
                height: 40
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                font { family: "Terminus"; pointSize: 14 }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                clip: true
            }

            ////////////////////////////////////////
            Item {
                id: username_area
                height: 26
                anchors { left: parent.left; leftMargin: 40 }
                anchors { right: parent.right; rightMargin: 40 }
                anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: -5 }

                Text {
                    id: username_label
                    anchors { left: parent.left; leftMargin: username.anchors.leftMargin }
                    anchors { right: username_panel.left; rightMargin: 10 }
                    anchors { top: parent.top; topMargin: username.anchors.topMargin }
                    anchors { bottom: parent.bottom; bottomMargin: username.anchors.bottomMargin }
                    text: "username"
                    font: username.font
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignTop
                    clip: true
                }

                Rectangle {
                    id: username_panel
                    width: 190
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: "#30ffffff"
                    border.color: "#a0e0e0e0"

                    TextInput {
                        id: username
                        objectName: "username"
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 2
                        anchors.bottomMargin: 2
                        font { family: "Terminus"; pointSize: 16 }

                        Keys.onTabPressed: password.focus = true
                        Keys.onReturnPressed: password.focus = true
                    }
                }
            }

            ////////////////////////////////////////
            Item {
                id: password_area
                height: username_area.height
                anchors.left: username_area.left
                anchors.right: username_area.right
                anchors { top: username_area.bottom; topMargin: 16 }

                Text {
                    id: password_label
                    anchors { left: parent.left; leftMargin: password.anchors.leftMargin }
                    anchors { right: password_panel.left; rightMargin: 10 }
                    anchors { top: parent.top; topMargin: password.anchors.topMargin }
                    anchors { bottom: parent.bottom; bottomMargin: password.anchors.bottomMargin }
                    text: "password"
                    font: username_label.font
                    color: username_label.color
                    horizontalAlignment: username_label.horizontalAlignment
                    verticalAlignment: username_label.verticalAlignment
                    clip: true
                }

                Rectangle {
                    id: password_panel
                    width: username_panel.width
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: username_panel.color
                    border.color: username_panel.border.color

                    TextInput {
                        id: password
                        objectName: "password"
                        anchors.fill: parent
                        anchors.leftMargin: username.anchors.leftMargin
                        anchors.rightMargin: username.anchors.rightMargin
                        anchors.topMargin: username.anchors.topMargin
                        anchors.bottomMargin: username.anchors.bottomMargin
                        font: username.font
                        echoMode: TextInput.Password
                        passwordCharacter: "*"

                        Keys.onTabPressed: username.focus = true
                        Keys.onReturnPressed: {
                            settings.username = username.text
                            settings.password = password.text
                            login()
                        }
                    }
                }
            }
        }
    }
}
