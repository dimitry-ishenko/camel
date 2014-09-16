import QtQuick 1.1

Rectangle
{
    id: root
    color: "#000000"

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
            info("F8 session, F10 reboot, F11 poweroff")
        else if(event.key == Qt.Key_F8)
            settings.nextSession()
        else if(event.key == Qt.Key_F10)
            reboot()
        else if(event.key == Qt.Key_F11)
            poweroff()

    ////////////////////////////////////////
    Rectangle
    {
        id: user_rect
        width: 200; height: 30
        anchors { horizontalCenter: parent.horizontalCenter }
        anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: 50 }
        color: "#ffffff"
        radius: 2

        TextInput
        {
            id: user_input
            anchors.fill: parent
            anchors.margins: 3
            font.pointSize: 14
            enabled: false

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
        anchors { horizontalCenter: user_rect.horizontalCenter }
        anchors { top: user_rect.bottom; topMargin: 20 }
        color: "#ffffff"
        radius: user_rect.radius

        TextInput
        {
            id: pass_input
            anchors.fill: parent
            anchors.margins: user_input.anchors.margins
            font.pointSize: user_input.font.pointSize
            enabled: false
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
        width: 400; height: 80
        anchors { horizontalCenter: pass_rect.horizontalCenter }
        anchors { top: pass_rect.bottom; topMargin: 20 }
        font.pointSize: 14
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        clip: true
    }

    ////////////////////////////////////////
    Text
    {
        id: name_text
        width: 200; height: 40
        anchors { horizontalCenter: user_rect.horizontalCenter }
        anchors { bottom: user_rect.top; bottomMargin: 20 }
        text: settings.hostname
        color: "#ffffff"
        font { pointSize: 20; bold: true }
        horizontalAlignment: Text.AlignHCenter
        clip: true
    }
}
