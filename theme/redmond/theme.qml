import QtQuick 1.1

Rectangle {
    ////////////////////////////////////////
    signal login()
    signal change_pass()
    signal reboot()
    signal poweroff()

    ////////////////////////////////////////
    function reset() {
        username.enabled = true
        username.text = ""
        password.text = ""
        settings.username = ""
        username.focus = true
    }

    function reset_pass() {
        username.enabled = false
        password.text = ""
        password.focus = true
        settings.password_n = ""
        enter_animation.start()
    }

    SequentialAnimation {
        id: enter_animation
        PauseAnimation { duration: 2000 }
        ScriptAction { script: info("Enter new password") }
    }

    ////////////////////////////////////////
    function info(text) { message(text, "#ffffff") }
    function error(text) { message(text, "#ff0000") }

    function message(text, color) {
        message_animation.stop()
        message_label.text = text
        message_label.color = color
        message_label.opacity = 1
        message_animation.start()
    }

    ////////////////////////////////////////
    SequentialAnimation {
        id: message_animation
        PauseAnimation { duration: 4000 }
        PropertyAnimation {
            target: message_label
            property: "opacity"
            from: 1; to: 0; duration: 300
            easing.type: Easing.InQuad
        }
    }

    ////////////////////////////////////////
    Connections {
        target: settings
        onSessionChanged: info(settings.session)
    }

    Keys.onEscapePressed: reset()

    ////////////////////////////////////////
    function process() {
        if(settings.username === "") {
            settings.username = username.text
            settings.password = password.text
            login()
        }
        else if(settings.password_n === "") {
            settings.password_n = password.text
            password.text = ""
            info("Retype new password")
        }
        else if(password.text !== settings.password_n) {
            error("Passwords don't match")
            reset_pass()
        }
        else change_pass()
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
            id: panel
            source: "tile.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: -38 }
        }

        ////////////////////////////////////////
        Image {
            id: username_panel
            source: username.text ? "username_active.png": "username.png"
            anchors.horizontalCenter: panel.horizontalCenter
            anchors { top: panel.bottom; topMargin: 10 }

            TextInput {
                id: username
                objectName: "username"
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                font { family: "Sans"; pixelSize: 12 }

                Keys.onTabPressed: password.focus = true
                Keys.onReturnPressed: password.focus = true
            }
        }

        ////////////////////////////////////////
        Image {
            id: password_panel
            source: password.text ? "password_active.png": "password.png"
            anchors.horizontalCenter: username_panel.horizontalCenter
            anchors { top: username_panel.bottom; topMargin: 10 }

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
                Keys.onReturnPressed: process()
            }
        }

        ////////////////////////////////////////
        Image {
            id: login_button
            source: login_mouse.containsMouse? "login_active.png": "login.png"
            anchors { left: password_panel.right; leftMargin: 20 }
            anchors.verticalCenter: password_panel.verticalCenter

            MouseArea {
                id: login_mouse
                anchors.fill: parent
                hoverEnabled: true

                onClicked: process()
            }
        }

        ////////////////////////////////////////
        Text {
            id: message_label
            width: 300
            height: 40
            anchors.horizontalCenter: password_panel.horizontalCenter
            anchors { top: password_panel.bottom; topMargin: 10 }
            font { family: "Sans"; pixelSize: 12 }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            clip: true
        }

        ////////////////////////////////////////
        Image {
            id: session_button
            source: session_mouse.containsMouse ? "session_active.png" : "session.png"
            anchors { left: parent.left; leftMargin: 40 }
            anchors { bottom: parent.bottom; bottomMargin: 40 }

            MouseArea {
                id: session_mouse
                anchors.fill: parent
                hoverEnabled: true

                onClicked: settings.nextSession()
            }
        }

        Image {
            id: power_button
            source: (shutdown_mouse.containsMouse || power_mouse.containsMouse) ? "power_active.png": "power.png"
            anchors { right: parent.right; rightMargin: 40 }
            anchors { bottom: parent.bottom; bottomMargin: 40 }

            MouseArea {
                id: shutdown_mouse
                width: 37
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                hoverEnabled: true

                onClicked: poweroff()
            }

            MouseArea {
                id: power_mouse
                width: 20
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                hoverEnabled: true

                onClicked: system_menu.visible = !system_menu.visible
            }

            Image {
                id: system_menu
                source: "system_menu.png"
                anchors.right: power_button.right
                anchors.bottom: power_button.top
                visible: false

                Image {
                    id: reboot_item
                    source: "menu_item_active.png"
                    anchors { left: parent.left; leftMargin: 3 }
                    anchors { top: parent.top; topMargin: 3 }
                    visible: reboot_mouse.containsMouse ? true : false
                }

                MouseArea {
                    id: reboot_mouse
                    anchors.fill: reboot_item
                    hoverEnabled: true

                    onClicked: {
                        system_menu.visible = false
                        reboot()
                    }
                }

                Image {
                    id: poweroff_item
                    source: "menu_item_active.png"
                    anchors { left: parent.left; leftMargin: 3 }
                    anchors { top: parent.top; topMargin: 33 }
                    visible: poweroff_mouse.containsMouse ? true : false
                }

                MouseArea {
                    id: poweroff_mouse
                    anchors.fill: poweroff_item
                    hoverEnabled: true

                    onClicked: {
                        system_menu.visible = false
                        poweroff()
                    }
                }
            }
        }
    }
}
