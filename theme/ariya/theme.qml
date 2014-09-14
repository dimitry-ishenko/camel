import QtQuick 1.1

Rectangle {
    ////////////////////////////////////////
    signal reset()
    signal info(string text)
    signal error(string text)
    signal quit()

    ////////////////////////////////////////
    onReset: {
        username.text = ""
        password.text = ""
        username.focus = true
    }

    ////////////////////////////////////////
    onInfo: message(text, "#555555")
    onError: message(text, "#ff0000")

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
    Keys.onEscapePressed: reset()

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
                    Keys.onReturnPressed: quit()
                }
            }

            ////////////////////////////////////////
            Image {
                id: session_icon
                source: "session_normal.png"
                opacity: 0.9
                anchors { left: parent.left; leftMargin: 22 }
                anchors { bottom: parent.bottom; bottomMargin: 20 }

                MouseArea {
                    id: session_mouse
                    anchors.fill: parent

                    onClicked: {
                        ++sessions.index
                        if(sessions.index >= sessions.text.length)
                            sessions.index = 0
                        session.text = sessions.text[sessions.index]
                    }
                }
            }

            Image {
                id: system_icon
                source: "system_normal.png"
                opacity: 0.9
                anchors { left: parent.left; leftMargin: 50 }
                anchors { bottom: parent.bottom; bottomMargin: 20 }

                MouseArea {
                    anchors.fill: parent
                    onClicked: systems.visible = !systems.visible
                }

                Image {
                    id: systems
                    source: "sessions.png"
                    anchors.left: system_icon.left
                    anchors.top: system_icon.bottom
                    visible: false

                    Text {
                        id: reboot
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

                            onClicked: {
                                session.text = "reboot"
                                systems.visible = false
                                info("Rebooting")
                                quit()
                            }
                        }
                    }

                    Text {
                        id: poweroff
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: reboot.bottom
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

            Image {
                id: login_icon
                source: login_mouse.containsMouse? "login_active.png": "login_normal.png"
                anchors { right: parent.right; rightMargin: 20 }
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    id: login_mouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: quit()
                }
            }
        }
    }
}
