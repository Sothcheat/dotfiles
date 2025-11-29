import QtQuick 2.15
import SddmComponents 2.0
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#0E1E36"

    // <<< TOUCH FIX FOR HYPRWAYLAND — ONLY ADDED LINES >>>
    Component.onCompleted: {
        // Convert every touch/tap into a proper left-click that MouseArea understands
        Qt.application.touchAsMouse = true
        // Make ALL MouseAreas accept touch events (the real fix)
        MouseArea.prototype.acceptTouchEvents = true
    }
    // <<< END OF TOUCH FIX >>>

    // Password visibility state
    property bool showPassword: false

    Item {
        anchors.centerIn: parent
        width: 600
        height: 500

        // === ASCII LOGO ===
        Text {
            id: logo
	    text: "██╗     ██╗   ██╗ ██████╗██╗███████╗███████╗██████╗ \n" +
                  " ██║     ██║   ██║██╔════╝██║██╔════╝██╔════╝██╔══██╗\n" +
                  " ██║     ██║   ██║██║     ██║█████╗  █████╗  ██████╔╝\n" +
                  " ██║     ██║   ██║██║     ██║██╔══╝  ██╔══╝  ██╔══██╗\n" +
                  " ███████╗╚██████╔╝╚██████╗██║██║     ███████╗██║  ██║\n" +
                  " ╚══════╝ ╚═════╝  ╚═════╝╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝" 
            color: "#F4B999"
            font.family: "Monospace"
            font.pixelSize: Math.max(16, root.height * 0.019)
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
        }

        // === PASSWORD FIELD ===
        Rectangle {
            id: passwordField
            width: 520
            height: 75
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: logo.bottom
            anchors.topMargin: 50

            // Main input rectangle
            Rectangle {
                id: inputBg
                anchors.fill: parent
                radius: 12
                color: passwordWrong ? Qt.rgba(0.82, 0.29, 0.36, 0.12) : Qt.rgba(0.33, 0.31, 0.45, 0.18)
                border.color: passwordWrong ? "#D2495B" : "#574F72"
                border.width: passwordWrong ? 2 : 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 16
                    spacing: 16

                    // Lock icon
                    Item {
                        width: 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            id: lockIcon
                            source: "icons/lock.svg"
                            width: 32
                            height: 32
                            sourceSize: Qt.size(32, 32)
                            fillMode: Image.PreserveAspectFit
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: lockIcon
                            source: lockIcon
                            color: passwordWrong ? "#D2495B" : "#F4B999"
                        }
                    }

                    // Password input container - centered content
                    Item {
                        width: parent.width - 100
                        height: parent.height

                        // Password input field (hidden)
                        PasswordBox {
                            id: passwordHidden
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: -10
                            width: parent.width + 10
                            height: 40
                            color: "transparent"
                            borderColor: "transparent"
                            focusColor: "transparent"
                            hoverColor: "transparent"
                            textColor: passwordWrong ? "#D2495B" : "#9279AA"
                            font.family: "Monospace"
                            font.pixelSize: 26
                            focus: !showPassword
                            visible: !passwordWrong && !showPassword

                            Keys.onReturnPressed: {
                                if (!isLoggingIn) {
                                    attemptLogin()
                                }
                            }
                            
                            onTextChanged: {
                                passwordVisible.text = passwordHidden.text
                            }
                        }

                        // Password input field (visible)
                        TextInput {
                            id: passwordVisible
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: -10
                            width: parent.width + 10
                            height: 40
                            color: passwordWrong ? "#D2495B" : "#9279AA"
                            font.family: "Monospace"
                            font.pixelSize: 26
                            focus: showPassword
                            visible: !passwordWrong && showPassword
                            selectByMouse: true
                            echoMode: TextInput.Normal

                            Keys.onReturnPressed: {
                                if (!isLoggingIn) {
                                    attemptLogin()
                                }
                            }
                            
                            onTextChanged: {
                                if (showPassword) {
                                    passwordHidden.text = passwordVisible.text
                                }
                            }
                        }

                        // ERROR MESSAGE - centered in password field
                        Text {
                            id: errorText
                            text: "Incorrect password"
                            color: "#D2495B"
                            font.family: "Monospace"
                            font.pixelSize: 18
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: -10
                            opacity: 0
                            z: 10

                            Behavior on opacity { NumberAnimation { duration: 300 } }
                        }
                    }

                    // Eye icon - toggle password visibility
                    Item {
                        width: 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            id: eyeIcon
                            source: showPassword ? "icons/eyeOpen.svg" : "icons/eyeClose.svg"
                            width: 32
                            height: 32
                            sourceSize: Qt.size(32, 32)
                            fillMode: Image.PreserveAspectFit
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: eyeIcon
                            source: eyeIcon
                            color: eyeMouse.containsMouse ? "#F4B999" : "#9279AA"
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        MouseArea {
                            id: eyeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            pressAndHoldInterval: 0
                            onReleased: {
                                showPassword = !showPassword
                                if (showPassword) {
                                    passwordVisible.forceActiveFocus()
                                } else {
                                    passwordHidden.forceActiveFocus()
                                }
                            }
                        }
                    }
                }

                // Subtle red flash on wrong password
                Rectangle {
                    id: flashRect
                    anchors.fill: parent
                    color: "#D2495B"
                    opacity: 0
                    radius: 12
                    Behavior on opacity { NumberAnimation { duration: 800 } }
                }
            }
        }

        // === CLOCK ===
        Text {
            id: timeText
            color: "#FA7E75"
            font.pixelSize: 28
            font.family: "Monospace"
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: passwordField.bottom
            anchors.topMargin: 45
            
            function update() { 
                text = Qt.formatDateTime(new Date(), "hh:mm:ss AP") 
            }
            
            Timer { 
                interval: 1000
                running: true
                repeat: true
                onTriggered: timeText.update() 
            }
            
            Component.onCompleted: update()
        }
    }

    // === HIDDEN FIELDS ===
    Text { 
        id: user
        text: userModel.lastUser
        visible: false 
    }
    
    ComboBox { 
        id: session
        visible: false
        model: sessionModel
        index: sessionModel.lastIndex
        
        Component.onCompleted: {
            for (var i = 0; i < sessionModel.rowCount(); i++) {
                var sessionName = sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole)
                if (sessionName && sessionName.toLowerCase().indexOf("hyprland") !== -1) {
                    index = i
                    break
                }
            }
        }
    }

    // === LOGIN STATE MANAGEMENT ===
    property bool passwordWrong: false
    property bool isLoggingIn: false

    function attemptLogin() {
        if (isLoggingIn) {
            return
        }
        
        isLoggingIn = true
        var passwordText = showPassword ? passwordVisible.text : passwordHidden.text
        sddm.login(user.text, passwordText, session.index)
    }

    Connections {
        target: sddm
        
        onLoginFailed: {
            isLoggingIn = false
            passwordWrong = true
            errorText.opacity = 1
            flashRect.opacity = 0.3
            
            // Clear both password fields
            passwordHidden.text = ""
            passwordVisible.text = ""
            
            // Reset to hidden password mode
            showPassword = false
            passwordHidden.forceActiveFocus()
            
            resetTimer.restart()
        }
        
        onLoginSucceeded: {
            isLoggingIn = false
            passwordWrong = false
            errorText.opacity = 0
        }
    }

    Timer {
        id: resetTimer
        interval: 2500
        onTriggered: {
            passwordWrong = false
            errorText.opacity = 0
            flashRect.opacity = 0
            isLoggingIn = false
        }
    }

    // === CONFIRMATION DIALOG ===
    Rectangle {
        id: confirmDialog
        anchors.centerIn: parent
        width: 450
        height: 200
        radius: 16
        color: "#0E1E36"
        border.color: "#574F72"
        border.width: 2
        visible: false
        z: 100

        property var actionFunction: null

        Column {
            anchors.centerIn: parent
            spacing: 30

            Text {
                id: dialogText
                text: "Are you sure?"
                color: "#F4B999"
                font.family: "Monospace"
                font.pixelSize: 20
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                // Cancel button
                Rectangle {
                    width: 120
                    height: 50
                    radius: 10
                    color: cancelMouse.containsMouse ? "#574F72" : "#0E1E36"
                    border.color: "#574F72"
                    border.width: 2

                    Text {
                        text: "Cancel"
                        color: "#F4B999"
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        pressAndHoldInterval: 0
                        onReleased: {
                            confirmDialog.visible = false
                            if (showPassword) {
                                passwordVisible.forceActiveFocus()
                            } else {
                                passwordHidden.forceActiveFocus()
                            }
                        }
                    }
                }

                // Confirm button
                Rectangle {
                    width: 120
                    height: 50
                    radius: 10
                    color: confirmMouse.containsMouse ? "#BE6F76" : "#D2495B"
                    border.color: "#D2495B"
                    border.width: 2

                    Text {
                        text: "Confirm"
                        color: "#F4B999"
                        font.family: "Monospace"
                        font.pixelSize: 16
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: confirmMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        pressAndHoldInterval: 0
                        onReleased: {
                            confirmDialog.visible = false
                            if (confirmDialog.actionFunction) {
                                confirmDialog.actionFunction()
                            }
                        }
                    }
                }
            }
        }
    }

    // Dim background when dialog is visible
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: confirmDialog.visible ? 0.7 : 0
        visible: confirmDialog.visible
        z: 99
        
        MouseArea {
            anchors.fill: parent
            onReleased: {
                confirmDialog.visible = false
                if (showPassword) {
                    passwordVisible.forceActiveFocus()
                } else {
                    passwordHidden.forceActiveFocus()
                }
            }
        }
        
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // === POWER BUTTONS ===
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 36
        spacing: 24

        // Suspend Button
        Rectangle {
            width: 58
            height: 58
            radius: 14
            color: suspendMouse.containsMouse ? "#574F72" : "#0E1E36"
            border.color: "#574F72"
            border.width: 2

            Item {
                anchors.centerIn: parent
                width: 38
                height: 38
                
                Image {
                    id: suspendIcon
                    source: "icons/suspend.svg"
                    width: 38
                    height: 38
                    sourceSize: Qt.size(38, 38)
                    fillMode: Image.PreserveAspectFit
                    visible: false
                }
                
                ColorOverlay {
                    anchors.fill: suspendIcon
                    source: suspendIcon
                    color: "#F4B999"
                }
            }
            
            MouseArea {
                id: suspendMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                pressAndHoldInterval: 0
                onReleased: {
                    dialogText.text = "Suspend the system?"
                    confirmDialog.actionFunction = function() {
                        sddm.suspend()
                    }
                    confirmDialog.visible = true
                }
            }
        }

        // Restart Button
        Rectangle {
            width: 58
            height: 58
            radius: 14
            color: restartMouse.containsMouse ? "#574F72" : "#0E1E36"
            border.color: "#574F72"
            border.width: 2

            Item {
                anchors.centerIn: parent
                width: 38
                height: 38
                
                Image {
                    id: restartIcon
                    source: "icons/restart.svg"
                    width: 38
                    height: 38
                    sourceSize: Qt.size(38, 38)
                    fillMode: Image.PreserveAspectFit
                    visible: false
                }
                
                ColorOverlay {
                    anchors.fill: restartIcon
                    source: restartIcon
                    color: "#F4B999"
                }
            }
            
            MouseArea {
                id: restartMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                pressAndHoldInterval: 0
                onReleased: {
                    dialogText.text = "Restart the system?"
                    confirmDialog.actionFunction = function() {
                        sddm.reboot()
                    }
                    confirmDialog.visible = true
                }
            }
        }

        // Power Off Button
        Rectangle {
            width: 58
            height: 58
            radius: 14
            color: powerMouse.containsMouse ? "#574F72" : "#0E1E36"
            border.color: "#D2495B"
            border.width: 2

            Item {
                anchors.centerIn: parent
                width: 38
                height: 38
                
                Image {
                    id: powerIcon
                    source: "icons/power.svg"
                    width: 38
                    height: 38
                    sourceSize: Qt.size(38, 38)
                    fillMode: Image.PreserveAspectFit
                    visible: false
                }
                
                ColorOverlay {
                    anchors.fill: powerIcon
                    source: powerIcon
                    color: "#D2495B"
                }
            }
            
            MouseArea {
                id: powerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                pressAndHoldInterval: 0
                onReleased: {
                    dialogText.text = "Shut down the system?"
                    confirmDialog.actionFunction = function() {
                        sddm.powerOff()
                    }
                    confirmDialog.visible = true
                }
            }
        }
    }
}
