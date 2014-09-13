import QtQuick 1.1

Rectangle {

    signal reset()
    signal info(string text)
    signal error(string text)
    signal message(string text, color color)
    signal quit()

    ////////////////////////////////////////
    onReset: {
        username.text = ""
        password.text = ""

        username.focus = true
    }

    ////////////////////////////////////////
    onInfo: message(text, "#ffffff")
    onError: message(text, "#ff0000")

    ////////////////////////////////////////
    onMessage: {
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
    Item {
        id: sessions
        objectName: "sessions"
        property variant text: [ ]
        property int index: 0
    }

    ////////////////////////////////////////
    Item {
        id: session
        objectName: "session"
        property string text: ""

        onTextChanged: info(text)
    }

    ////////////////////////////////////////
    Image {
        id: background
        source: "background.png"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        clip: true

        ////////////////////////////////////////
        Image {
            id: tile
            source: "tile.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -38
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ////////////////////////////////////////
        Image {
            id: username_panel
            source: username.text ? "username_active.png": "username.png"
            anchors.top: tile.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: tile.horizontalCenter

            TextInput {
                id: username
                objectName: "username"
                anchors.fill: parent
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                font.family: "Sans"
                font.pixelSize: 12

                Keys.onTabPressed: password.focus = true
                Keys.onReturnPressed: password.focus = true
            }
        }

        ////////////////////////////////////////
        Image {
            id: password_panel
            source: password.text ? "password_active.png": "password.png"
            anchors.top: username_panel.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: username_panel.horizontalCenter

            TextInput {
                id: password
                objectName: "password"
                anchors.fill: parent
                anchors.topMargin: username.anchors.topMargin
                anchors.bottomMargin: username.anchors.bottomMargin
                anchors.leftMargin: username.anchors.leftMargin
                anchors.rightMargin: username.anchors.rightMargin
                font: username.font

                echoMode: TextInput.Password
                passwordCharacter: "*"

                Keys.onTabPressed: username.focus = true
                Keys.onReturnPressed: quit()
            }
        }

        ////////////////////////////////////////
        Image {
            id: login
            source: login_mouse.containsMouse? "login_active.png": "login.png"
            anchors.verticalCenter: password_panel.verticalCenter
            anchors.left: password_panel.right
            anchors.leftMargin: 20

            MouseArea {
                id: login_mouse
                anchors.fill: parent
                hoverEnabled: true

                onClicked: quit()
            }
        }

        ////////////////////////////////////////
        Text {
            id: message_label
            width: 300
            height: 40
            anchors.top: password_panel.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: password_panel.horizontalCenter
            font.family: "Sans"
            font.pixelSize: 12

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            clip: true
        }

        ////////////////////////////////////////
        Image {
            id: session_icon
            source: session_mouse.containsMouse ? "session_active.png" : "session.png"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.left: parent.left
            anchors.leftMargin: 40

            MouseArea {
                id: session_mouse
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    ++sessions.index
                    if(sessions.index >= sessions.text.length)
                        sessions.index = 0
                    session.text = sessions.text[sessions.index]
                }
            }
        }

        Image {
            id: power
            source: (shutdown_mouse.containsMouse || power_mouse.containsMouse) ? "power_active.png": "power.png"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.right: parent.right
            anchors.rightMargin: 40

            MouseArea {
                id: shutdown_mouse
                width: 37
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                hoverEnabled: true

                onClicked: {
                    session.text = "poweroff"
                    info("Shutting down")
                    quit()
                }
            }

            MouseArea {
                id: power_mouse
                width: 20
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                hoverEnabled: true

                onClicked: systems.visible = !systems.visible
            }

            Image {
                id: systems
                source: "system_menu.png"
                anchors.bottom: power.top
                anchors.right: power.right
                visible: false

                Image {
                    id: reboot
                    source: "menu_item_active.png"
                    anchors.top: parent.top
                    anchors.topMargin: 3
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    visible: reboot_mouse.containsMouse ? true : false
                }

                MouseArea {
                    id: reboot_mouse
                    anchors.fill: reboot
                    hoverEnabled: true

                    onClicked: {
                        session.text = "reboot"
                        systems.visible = false
                        info("Rebooting")
                        quit()
                    }
                }

                Image {
                    id: poweroff
                    source: "menu_item_active.png"
                    anchors.top: parent.top
                    anchors.topMargin: 33
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    visible: poweroff_mouse.containsMouse ? true : false
                }

                MouseArea {
                    id: poweroff_mouse
                    anchors.fill: poweroff
                    hoverEnabled: true

                    onClicked: {
                        session.text = "poweroff"
                        systems.visible = false
                        info("Shutting down")
                        quit()
                    }
                }
            }
        }
    }
}
