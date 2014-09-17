import QtQuick 1.1

Rectangle
{
    ////////////////////////////////////////
    signal enter()
    signal cancel()

    signal reboot()
    signal poweroff()

    ////////////////////////////////////////
    function info(text)
    {
        info_text.color = "#555555"
        info_text.text = text
        info_anim.restart()
    }

    function error(text)
    {
        info_text.color = "#ff0000"
        info_text.text = text
        info_anim.restart()
    }

    ////////////////////////////////////////
    function enter_user_pass(text)
    {
        user_input.text = ""
        user_input.enabled = true
        user_input.focus = true

        pass_input.text = ""
        pass_input.enabled = true

        login_img.enabled = true

        if(text) info(text)
    }

    function enter_pass(text)
    {
        user_input.enabled = false

        pass_input.text = ""
        pass_input.enabled = true
        pass_input.focus = true

        login_img.enabled = true

        if(text) info(text)
    }

    ////////////////////////////////////////
    Connections
    {
        target: settings
        onSessionChanged: info(settings.session)
    }

    onEnter:
    {
        user_input.enabled = false
        pass_input.enabled = false
        login_img.enabled = false
    }

    ////////////////////////////////////////
    Image
    {
        id: background
        source: "background.png"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        clip: true

        ////////////////////////////////////////
        Image
        {
            id: panel
            source: "rectangle.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Image
            {
                source: "rectangle_overlay.png"
                anchors.fill: parent
                opacity: 0.1
            }

            ////////////////////////////////////////
            Text
            {
                id: name_text
                height: 24
                anchors { left: parent.left; leftMargin: 20 }
                anchors { right: parent.right; rightMargin: 20 }
                anchors { top: parent.top; topMargin: 20 }
                text: settings.hostname
                font { family: "Sans"; pointSize: 14; bold: true }
                color: "#0b678c"
                opacity: 0.75
                clip: true
            }

            ////////////////////////////////////////
            SequentialAnimation
            {
                id: info_anim
                PropertyAction { target: info_text; property: "opacity"; value: 1 }
                PauseAnimation { duration: 3000; }
                PropertyAnimation
                {
                    target: info_text
                    property: "opacity"
                    to: 0
                    duration: 300
                }
            }

            ////////////////////////////////////////
            Text
            {
                id: info_text
                height: 40
                anchors { left: parent.left; leftMargin: 20 }
                anchors { right: parent.right; rightMargin: 20 }
                anchors { top: pass_item.bottom }
                font { family: "Sans"; pointSize: 10; bold: true }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                clip: true
            }

            ////////////////////////////////////////
            Item
            {
                id: user_item
                width: 200; height: 50
                anchors { horizontalCenter: parent.horizontalCenter; }
                anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: -25 }

                Image
                {
                    source: "user_icon.png"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image
                {
                    source: user_m.containsMouse? "lineedit_active.png": "lineedit_normal.png"
                    anchors { left: parent.left; leftMargin: 42 }
                    anchors { verticalCenter: parent.verticalCenter }

                    MouseArea
                    {
                        id: user_m
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                TextInput
                {
                    id: user_input
                    width: 140; height: 20
                    anchors { left: parent.left; leftMargin: 49 }
                    anchors { verticalCenter: parent.verticalCenter }
                    font { family: "Sans"; pointSize: 12 }
                    color: "#0b678c"

                    Keys.onPressed:
                        if(event.key == Qt.Key_Return || event.key == Qt.Key_Tab)
                        {
                            settings.username = user_input.text
                            pass_input.focus = true
                            event.accepted = true
                        }
                        else if(event.key === Qt.Key_Escape)
                        {
                            cancel()
                            event.accepted = true
                        }
                }
            }

            ////////////////////////////////////////
            Item
            {
                id: pass_item
                height: user_item.height
                anchors.left: user_item.left
                anchors.right: user_item.right
                anchors.top: user_item.bottom

                Image
                {
                    source: "lock.png"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image
                {
                    source: pass_m.containsMouse? "lineedit_active.png": "lineedit_normal.png"
                    anchors { left: parent.left; leftMargin: 42 }
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea
                    {
                        id: pass_m
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                TextInput
                {
                    id: pass_input
                    width: user_input.width
                    height: user_input.height
                    anchors { left: parent.left; leftMargin: 49 }
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: "Sans"; pointSize: 12 }
                    color: "#0b678c"
                    echoMode: TextInput.Password
                    passwordCharacter: "*"

                    Keys.onPressed:
                        if(event.key == Qt.Key_Return)
                        {
                            settings.password = pass_input.text
                            enter()
                            event.accepted = true
                        }
                        else if(event.key == Qt.Key_Tab)
                        {
                            user_input.focus = true
                            event.accepted = true
                        }
                        else if(event.key == Qt.Key_Escape)
                        {
                            cancel()
                            event.accepted = true
                        }
                }
            }

            ////////////////////////////////////////
            Image
            {
                source: "session_normal.png"
                anchors { left: parent.left; leftMargin: 22 }
                anchors { bottom: parent.bottom; bottomMargin: 20 }
                opacity: 0.9

                MouseArea
                {
                    id: session_m
                    anchors.fill: parent

                    onClicked: settings.nextSession()
                }
            }

            Image
            {
                source: "system_normal.png"
                anchors { left: parent.left; leftMargin: 50 }
                anchors { bottom: parent.bottom; bottomMargin: 20 }
                opacity: 0.9

                MouseArea
                {
                    anchors.fill: parent
                    onClicked: system_img.visible = !system_img.visible
                }

                Image
                {
                    id: system_img
                    source: "sessions.png"
                    anchors.left: parent.left
                    anchors.top: parent.bottom
                    visible: false

                    Text
                    {
                        id: reboot_text
                        anchors { left: parent.left }
                        anchors { right: parent.right }
                        anchors { top: parent.top; topMargin: 5 }
                        anchors { bottom: parent.verticalCenter }
                        color: reboot_m.containsMouse? "#ffffff": "#000000"
                        font { family: "Sans"; pointSize: 10 }
                        text: "Reboot"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        MouseArea
                        {
                            id: reboot_m
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked:
                            {
                                system_img.visible = false
                                reboot()
                            }
                        }
                    }

                    Text
                    {
                        id: poweroff_text
                        anchors { left: parent.left }
                        anchors { right: parent.right }
                        anchors { top: reboot_text.bottom }
                        anchors { bottom: parent.bottom; bottomMargin: 5 }
                        color: poweroff_m.containsMouse? "#ffffff": "#000000"
                        font { family: "Sans"; pointSize: 10 }
                        text: "Power off"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        MouseArea
                        {
                            id: poweroff_m
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked:
                            {
                                system_img.visible = false
                                poweroff()
                            }
                        }
                    }
                }
            }

            Image
            {
                id: login_img
                source: login_m.containsMouse? "login_active.png": "login_normal.png"
                anchors { right: parent.right; rightMargin: 20 }
                anchors { verticalCenter: parent.verticalCenter }

                MouseArea
                {
                    id: login_m
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked:
                    {
                        settings.username = user_input.text
                        settings.password = pass_input.text
                        enter()
                    }
                }
            }
        }
    }
}
