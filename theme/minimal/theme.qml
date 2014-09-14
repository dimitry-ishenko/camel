import QtQuick 1.1

Rectangle {
    color: "#000000"

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
    onInfo: message(text, "#ffffff")
    onError: message(text, "#ff0000")

    Connections {
        target: settings
        onSessionChanged: info(settings.session)
    }

    ////////////////////////////////////////
    function message(text, color) {
        animation.stop()
        label.text = text
        label.color = color
        label.opacity = 1
        animation.start()
    }

    SequentialAnimation {
        id: animation

        PauseAnimation { duration: 4000; }
        PropertyAnimation {
            target: label
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
                settings.username = username.text
                settings.password = password.text
                login()
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
