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

        if(text) info(text)
    }

    function enter_pass(text)
    {
        user_input.enabled = false

        pass_input.text = ""
        pass_input.enabled = true
        pass_input.focus = true

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
    }

    ////////////////////////////////////////
    Keys.onPressed:
        if(event.key == Qt.Key_F1)
            info("F8 session F10 reboot F11 poweroff")
        else if(event.key == Qt.Key_F8)
            settings.nextSession()
        else if(event.key == Qt.Key_F10)
            reboot()
        else if(event.key == Qt.Key_F11)
            poweroff()

    ////////////////////////////////////////
    Image
    {
        id: background
        source: "background.jpg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        clip: true

        ////////////////////////////////////////
        Rectangle
        {
            id: panel
            width: 380; height: 180
            color: "#30ffffff"
            border.color: "#a0e0e0e0"
            radius: 5
            anchors { horizontalCenter: parent.horizontalCenter }
            anchors { verticalCenterOffset: 80; verticalCenter: parent.verticalCenter }

            ////////////////////////////////////////
            Text
            {
                id: name_text
                width: 260; height: 40
                anchors { horizontalCenter: parent.horizontalCenter }
                anchors { top: parent.top; topMargin: 16 }
                text: settings.hostname
                font { family: "Linux Biolinum"; pointSize: 28; bold: true }
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
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
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                font { family: "Terminus"; pointSize: 14 }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                clip: true
            }

            ////////////////////////////////////////
            Item
            {
                id: user_item
                height: 26
                anchors { left: parent.left; leftMargin: 40 }
                anchors { right: parent.right; rightMargin: 40 }
                anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: -5 }

                Text
                {
                    id: user_text
                    anchors { left: parent.left; leftMargin: user_input.anchors.leftMargin }
                    anchors { right: user_rect.left; rightMargin: 10 }
                    anchors { top: parent.top; topMargin: user_input.anchors.topMargin }
                    anchors { bottom: parent.bottom; bottomMargin: user_input.anchors.bottomMargin }
                    text: "username"
                    font: user_input.font
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignTop
                    clip: true
                }

                Rectangle
                {
                    id: user_rect
                    width: 190
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                    color: "#30ffffff"
                    border.color: "#a0e0e0e0"

                    TextInput
                    {
                        id: user_input
                        anchors { fill: parent }
                        anchors { leftMargin: 8; rightMargin: 8; topMargin: 2; bottomMargin: 2 }
                        font { family: "Terminus"; pointSize: 16 }

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
            }

            ////////////////////////////////////////
            Item
            {
                id: pass_item
                height: user_item.height
                anchors { left: user_item.left; right: user_item.right }
                anchors { top: user_item.bottom; topMargin: 16 }

                Text
                {
                    id: pass_text
                    anchors { left: parent.left; leftMargin: pass_input.anchors.leftMargin }
                    anchors { right: pass_rect.left; rightMargin: 10 }
                    anchors { top: parent.top; topMargin: pass_input.anchors.topMargin }
                    anchors { bottom: parent.bottom; bottomMargin: pass_input.anchors.bottomMargin }
                    text: "password"
                    font: user_text.font
                    color: user_text.color
                    horizontalAlignment: user_text.horizontalAlignment
                    verticalAlignment: user_text.verticalAlignment
                    clip: true
                }

                Rectangle
                {
                    id: pass_rect
                    width: user_rect.width
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                    color: user_rect.color
                    border.color: user_rect.border.color

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
            }
        }
    }
}
