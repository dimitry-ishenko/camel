import QtQuick 1.1

Rectangle {
    id: root
    color: "#000000"

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
        label.text = text
        label.color = color
        label.opacity = 1
        message_animation.start()
    }

    ////////////////////////////////////////
    SequentialAnimation {
        id: message_animation
        PauseAnimation { duration: 4000; }
        PropertyAnimation {
            target: label
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

    ////////////////////////////////////////
    Keys.onPressed: {
        if(event.key === Qt.Key_Escape)
            reset();

        else if(settings.username === "") switch(event.key) {
        case Qt.Key_F1: info("F8 session, F10 reboot, F11 poweroff")
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
    Text {
        id: hostname
        objectName: "hostname"
        width: 200
        height: 40
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: settings.hostname
        color: "#ffffff"
        font { pointSize: 20; bold: true }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        clip: true
    }

    ////////////////////////////////////////
    Rectangle {
        width: 200
        height: 30
        radius: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: 50 }
        color: "#ffffff"

        TextInput {
            id: username
            objectName: "username"
            anchors.fill: parent
            anchors.margins: 3
            font.pointSize: 14

            Keys.onTabPressed: password.focus = true
            Keys.onReturnPressed: password.focus = true
        }
    }

    ////////////////////////////////////////
    Rectangle {
        width: 200
        height: 30
        radius: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: 90 }
        color: "#ffffff"

        TextInput {
            id: password
            objectName: "password"
            anchors.fill: parent
            anchors.margins: username.anchors.margins
            font.pointSize: username.font.pointSize
            echoMode: TextInput.Password
            passwordCharacter: "*"

            Keys.onTabPressed: username.focus = true

            Keys.onReturnPressed: {
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
        }
    }

    ////////////////////////////////////////
    Text {
        id: label
        width: 400
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        anchors { verticalCenter: parent.verticalCenter; verticalCenterOffset: 150 }
        font.pointSize: 14
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        clip: true
    }
}
