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
        info_text.color = "#ffffff"
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
            source: "tile.png"
            anchors { horizontalCenter: parent.horizontalCenter }
            anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: -38 }
        }

        ////////////////////////////////////////
        Rectangle
        {
            id: user_rect
            width: 220; height: 25
            color: "#ffffff"
            border.color: "#999999"
            radius: 2
            anchors { horizontalCenter: panel.horizontalCenter }
            anchors { top: panel.bottom; topMargin: 10 }

            Text
            {
                id: user_text
                anchors.fill: parent
                anchors.leftMargin: user_input.anchors.leftMargin
                anchors.rightMargin: user_input.anchors.rightMargin
                anchors.topMargin: user_input.anchors.topMargin
                anchors.bottomMargin: user_input.anchors.bottomMargin
                font: user_input.font
                text: "Username"
                opacity: user_input.text ? 0 : 0.3
            }

            TextInput
            {
                id: user_input
                anchors { fill: parent }
                anchors { leftMargin: 8; rightMargin: 8; topMargin: 5; bottomMargin: 5 }
                font { family: "Sans"; pointSize: 10 }

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
        Rectangle
        {
            id: pass_rect
            width: user_rect.width
            height: user_rect.height
            color: user_rect.color
            border.color: user_rect.border.color
            radius: user_rect.radius
            anchors { horizontalCenter: user_rect.horizontalCenter }
            anchors { top: user_rect.bottom; topMargin: 10 }

            Text
            {
                id: pass_text
                anchors.fill: parent
                anchors.leftMargin: pass_input.anchors.leftMargin
                anchors.rightMargin: pass_input.anchors.rightMargin
                anchors.topMargin: pass_input.anchors.topMargin
                anchors.bottomMargin: pass_input.anchors.bottomMargin
                font: pass_input.font
                text: "Password"
                opacity: pass_input.text ? 0 : 0.3
            }

            TextInput
            {
                id: pass_input
                anchors.fill: parent
                anchors.leftMargin: user_input.anchors.leftMargin
                anchors.rightMargin: user_input.anchors.rightMargin
                anchors.topMargin: user_input.anchors.topMargin
                anchors.bottomMargin: user_input.anchors.bottomMargin
                font: user_input.font
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
            id: login_img
            source: login_m.containsMouse? "login_active.png": "login.png"
            anchors { left: pass_rect.right; leftMargin: 20 }
            anchors { verticalCenter: pass_rect.verticalCenter }

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
            width: 300; height: 40
            anchors { horizontalCenter: pass_rect.horizontalCenter }
            anchors { top: pass_rect.bottom; topMargin: 10 }
            font { family: "Sans"; pointSize: 10 }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            clip: true
        }

        ////////////////////////////////////////
        Image
        {
            source: session_m.containsMouse ? "session_active.png" : "session.png"
            anchors { left: parent.left; leftMargin: 40 }
            anchors { bottom: parent.bottom; bottomMargin: 40 }

            MouseArea
            {
                id: session_m
                anchors.fill: parent
                hoverEnabled: true

                onClicked: settings.nextSession()
            }
        }

        Image
        {
            id: power_img
            source: (shutdown_m.containsMouse || power_m.containsMouse) ? "power_active.png": "power.png"
            anchors { right: parent.right; rightMargin: 40 }
            anchors { bottom: parent.bottom; bottomMargin: 40 }

            MouseArea
            {
                id: shutdown_m
                width: 37
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                hoverEnabled: true

                onClicked: poweroff()
            }
            MouseArea
            {
                id: power_m
                width: 20
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                hoverEnabled: true

                onClicked: system_img.visible = !system_img.visible
            }

            Image
            {
                id: system_img
                source: "system_menu.png"
                anchors.right: power_img.right
                anchors.bottom: power_img.top
                visible: false

                Text
                {
                    id: reboot_text
                    anchors { fill: reboot_img }
                    anchors { leftMargin: 35; rightMargin: 10; topMargin: 3; bottomMargin: 3 }
                    font { family: "Sans"; pointSize: 9 }
                    text: "Reboot"
                }
                Image
                {
                    id: reboot_img
                    source: "menu_item_active.png"
                    anchors { left: parent.left; leftMargin: 4 }
                    anchors { top: parent.top; topMargin: 4 }
                    visible: reboot_m.containsMouse ? true : false
                }
                MouseArea
                {
                    id: reboot_m
                    anchors.fill: reboot_img
                    hoverEnabled: true

                    onClicked:
                    {
                        system_img.visible = false
                        reboot()
                    }
                }

                Text
                {
                    id: poweroff_text
                    anchors.fill: poweroff_img
                    anchors.leftMargin: reboot_text.anchors.leftMargin
                    anchors.rightMargin: reboot_text.anchors.rightMargin
                    anchors.topMargin: reboot_text.anchors.topMargin
                    anchors.bottomMargin: reboot_text.anchors.bottomMargin
                    font: reboot_text.font
                    text: "Power off"
                }
                Image {
                    id: poweroff_img
                    source: "menu_item_active.png"
                    anchors { left: parent.left; leftMargin: 4 }
                    anchors { top: parent.top; topMargin: 34 }
                    visible: poweroff_m.containsMouse ? true : false
                }
                MouseArea
                {
                    id: poweroff_m
                    anchors.fill: poweroff_img
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
}
