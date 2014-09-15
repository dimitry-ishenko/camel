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
    function info(text) { message(text, "#555555") }
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
            source: "rectangle.png"
            width: 416
            height: 262
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: panel_overlay
                source: "rectangle_overlay.png"
                opacity: 0.1
                width: 416
                height: 262
                anchors.fill: parent
            }

            ////////////////////////////////////////
            Text {
                id: hostname
                objectName: "hostname"
                height: 24
                anchors { left: parent.left; leftMargin: 20 }
                anchors { right: parent.right; rightMargin: 20 }
                anchors { top: parent.top; topMargin: 20 }
                text: settings.hostname
                font { family: "Sans"; pointSize: 14; bold: true }
                color: "#0b678c"
                opacity: 0.75
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                clip: true
            }

            ////////////////////////////////////////
            Text {
                id: message_label
                height: 40
                anchors { left: parent.left; leftMargin: 20 }
                anchors { right: parent.right; rightMargin: 20 }
                anchors.top: password_area.bottom
                font { family: "Sans"; pointSize: 10; bold: true }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                clip: true
            }

            ////////////////////////////////////////
            Item {
                id: username_area
                width: 200
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter;
                anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: -25 }

                Image {
                    id: username_icon
                    source: "user_icon.png"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    id: username_panel
                    source: username_mouse.containsMouse? "lineedit_active.png": "lineedit_normal.png"
                    anchors { left: parent.left; leftMargin: 42 }
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        id: username_mouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                TextInput {
                    id: username
                    objectName: "username"
                    width: 140
                    height: 20
                    anchors { left: parent.left; leftMargin: 49 }
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: "Sans"; pointSize: 12 }
                    color: "#0b678c"

                    Keys.onTabPressed: password.focus = true
                    Keys.onReturnPressed: password.focus = true
                }
            }

            ////////////////////////////////////////
            Item {
                id: password_area
                height: username_area.height
                anchors.left: username_area.left
                anchors.right: username_area.right
                anchors.top: username_area.bottom

                Image {
                    id: password_icon
                    source: "lock.png"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    id: password_panel
                    source: password_mouse.containsMouse? "lineedit_active.png": "lineedit_normal.png"
                    anchors { left: parent.left; leftMargin: 42 }
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        id: password_mouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                TextInput {
                    id: password
                    objectName: "password"
                    width: 140
                    height: 20
                    anchors { left: parent.left; leftMargin: 49 }
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: "Sans"; pointSize: 12 }
                    color: "#0b678c"
                    echoMode: TextInput.Password
                    passwordCharacter: "*"

                    Keys.onTabPressed: username.focus = true
                    Keys.onReturnPressed: process()
                }
            }

            ////////////////////////////////////////
            Image {
                id: session_button
                source: "session_normal.png"
                opacity: 0.9
                anchors { left: parent.left; leftMargin: 22 }
                anchors { bottom: parent.bottom; bottomMargin: 20 }

                MouseArea {
                    id: session_mouse
                    anchors.fill: parent

                    onClicked: settings.nextSession()
                }
            }

            Image {
                id: system_button
                source: "system_normal.png"
                opacity: 0.9
                anchors { left: parent.left; leftMargin: 50 }
                anchors { bottom: parent.bottom; bottomMargin: 20 }

                MouseArea {
                    anchors.fill: parent
                    onClicked: system_menu.visible = !system_menu.visible
                }

                Image {
                    id: system_menu
                    source: "sessions.png"
                    anchors.left: system_button.left
                    anchors.top: system_button.bottom
                    visible: false

                    Text {
                        id: reboot_item
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors { top: parent.top; topMargin: 5 }
                        anchors.bottom: parent.verticalCenter

                        text: "Reboot"
                        color: reboot_mouse.containsMouse? "#ffffff": "#000000"
                        font { family: "Sans"; pointSize: 10 }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            id: reboot_mouse
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: reboot()
                        }
                    }

                    Text {
                        id: poweroff_item
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: reboot_item.bottom
                        anchors { bottom: parent.bottom; bottomMargin: 5 }

                        text: "Shutdown"
                        color: poweroff_mouse.containsMouse? "#ffffff": "#000000"
                        font { family: "Sans"; pointSize: 10 }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            id: poweroff_mouse
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: poweroff()
                        }
                    }
                }
            }

            Image {
                id: login_button
                source: login_mouse.containsMouse? "login_active.png": "login_normal.png"
                anchors { right: parent.right; rightMargin: 20 }
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    id: login_mouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: process()
                }
            }
        }
    }
}
