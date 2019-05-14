import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

ScrollView {

    readonly property int dynamicWidth: 864
    readonly property int dynamicMargin: 32

    id: settingsPanel
    objectName: 'settingsView'
    contentWidth: app.width

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical: ScrollBar {
        interactive: true
        width: 5
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }

    property int expandedHeight: 0

    function isKeyAvailable() {
        return !!yubiKey.currentDevice
    }

    function deviceInfo() {
        if (isKeyAvailable()) {
            return qsTr("%1 (#%2)").arg(yubiKey.currentDevice.name).arg(
                        yubiKey.currentDevice.serial)
        } else {
            return "Device"
        }
    }

    function clearPasswordFields() {
        currentPasswordField.text = ""
        newPasswordField.text = ""
        confirmPasswordField.text = ""
    }

    function submitPassword() {
        if (yubiKey.currentDeviceHasPassword) {
            changePassword()
        } else {
            setPassword()
        }
    }

    function changePassword() {
        yubiKey.validate(currentPasswordField.text, false, function (resp) {
            if (resp.success) {
                setPassword()
            } else {
                navigator.snackBarError(getErrorMessage(resp.error_id))
                console.log(resp.error_id)
            }
            clearPasswordFields()
        })
    }

    function setPassword() {
        yubiKey.setPassword(newPasswordField.text, false, function (resp) {
            if (resp.success) {
                navigator.snackBar("Password set")
                yubiKey.currentDeviceHasPassword = true
                passwordManagementPanel.isExpanded = false
            } else {
                navigator.snackBarError(getErrorMessage(resp.error_id))
                console.log(resp.error_id)
            }
            clearPasswordFields()
        })
    }

    property string title: "Settings"

    ListModel {
        id: themes

        ListElement {
            text: "System Default"
            value: Material.System
        }
        ListElement {
            text: "Light Mode"
            value: Material.Light
        }
        ListElement {
            text: "Dark Mode"
            value: Material.Dark
        }
    }

    ListModel {
        id: slotModeDigits

        ListElement {
            text: "Off"
            value: 0
        }
        ListElement {
            text: "6"
            value: 6
        }
        ListElement {
            text: "7"
            value: 7
        }
        ListElement {
            text: "8"
            value: 8
        }
    }

    spacing: 8
    padding: 0

    ColumnLayout {
        id: content
        anchors.fill: parent
        Layout.fillHeight: true
        Layout.fillWidth: true

        Pane {
            id: appPane
            Layout.alignment: Qt.AlignCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.maximumWidth: dynamicWidth + dynamicMargin
            Layout.bottomMargin: 16
            background: Rectangle {
                color: isDark() ? defaultDarkLighter : defaultLightDarker
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 4
                    samples: radius * 2
                    verticalOffset: 2
                    horizontalOffset: 2
                    color: formDropShdaow
                    transparentBorder: true
                }
            }

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                width: app.width - dynamicMargin
                       < dynamicWidth ? app.width - dynamicMargin : dynamicWidth
                spacing: 8

                RowLayout {
                    Label {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        text: "Application"
                        color: yubicoGreen
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        topPadding: 8
                        bottomPadding: 8
                        Layout.fillWidth: true
                        background: Item {
                            implicitWidth: parent.width
                            implicitHeight: 40
                            Rectangle {
                                color: formTitleUnderline
                                height: 1
                                width: parent.width
                                y: 31
                            }
                        }
                    }
                }

                StyledExpansionPanel {
                    label: "Appearance"
                    description: "Change the theme and appearance of the application."
                    motherView: settingsPanel

                    ColumnLayout {
                        visible: parent.isExpanded
                        Layout.alignment: Qt.AlignRight | Qt.AlignTop
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        Layout.bottomMargin: 8

                        RowLayout {
                            Layout.fillWidth: true
                            StyledComboBox {
                                id: themeComboBox
                                label: "Appearance"
                                comboBox.textRole: "text"
                                model: themes
                                onCurrentIndexChanged: {
                                    settings.theme = themes.get(
                                                currentIndex).value
                                }
                                currentIndex: {
                                    switch (settings.theme) {
                                    case Material.System:
                                        return 0
                                    case Material.Light:
                                        return 1
                                    case Material.Dark:
                                        return 2
                                    default:
                                        return 0
                                    }
                                }
                            }
                        }
                    }
                }

                StyledExpansionPanel {
                    label: "Authenticator Mode"
                    description: "Configure which mode the YubiKey will operate in."
                    motherView: settingsPanel

                    ColumnLayout {
                        visible: parent.isExpanded
                        Layout.alignment: Qt.AlignRight | Qt.AlignTop
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        Layout.bottomMargin: 8

                        RowLayout {
                            Layout.fillWidth: true
                            StyledComboBox {
                                id: authenticatorModeCombobox
                                label: "Authenticator Mode"
                                model: ["CCID (Default)", "OTP"]
                                currentIndex: settings.otpMode ? 1 : 0
                                onCurrentIndexChanged: {
                                    if (currentIndex === 1) {
                                        settings.otpMode = true
                                    } else {
                                        settings.otpMode = false
                                    }
                                }
                            }
                        }

                        RowLayout {
                            visible: authenticatorModeCombobox.currentText.indexOf(
                                         "OTP") > -1
                            Label {
                                Layout.fillWidth: true
                                font.pixelSize: 11
                                color: formLabel
                                text: "Using the OTP slots on the YubiKey should be considered for special usecases only and is not recommended for normal use."
                                wrapMode: Text.WordWrap
                                Layout.rowSpan: 1
                                bottomPadding: 8
                            }
                        }

                        RowLayout {
                            visible: authenticatorModeCombobox.currentText.indexOf(
                                         "OTP") > -1

                            StyledComboBox {
                                enabled: settings.otpMode
                                label: "Slot 1 Digits"
                                comboBox.textRole: "text"
                                model: slotModeDigits
                                onCurrentIndexChanged: {
                                    settings.slot1digits = slotModeDigits.get(
                                                currentIndex).value
                                }
                                currentIndex: {
                                    switch (settings.slot1digits) {
                                    case 0:
                                        return 0
                                    case 6:
                                        return 1
                                    case 7:
                                        return 2
                                    case 8:
                                        return 3
                                    default:
                                        return 0
                                    }
                                }
                            }

                            Item {
                                width: 16
                            }

                            StyledComboBox {
                                enabled: settings.otpMode
                                label: "Slot 2 Digits"
                                comboBox.textRole: "text"
                                model: slotModeDigits
                                onCurrentIndexChanged: {
                                    settings.slot2digits = slotModeDigits.get(
                                                currentIndex).value
                                }
                                currentIndex: {
                                    switch (settings.slot2digits) {
                                    case 0:
                                        return 0
                                    case 6:
                                        return 1
                                    case 7:
                                        return 2
                                    case 8:
                                        return 3
                                    default:
                                        return 0
                                    }
                                }
                            }
                        }
                    }
                }

                StyledExpansionPanel {
                    label: Qt.platform.os === "osx" ? "Menu Bar" : "System Tray"
                    description: "Configure where and how the application is visible."
                    motherView: settingsPanel

                    ColumnLayout {
                        visible: parent.isExpanded
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        Layout.bottomMargin: 8

                        CheckBox {
                            id: sysTrayCheckbox
                            checked: settings.closeToTray
                            text: Qt.platform.os
                                  === "osx" ? "Show in menu bar" : "Show in system tray"
                            padding: 0
                            indicator.width: 16
                            indicator.height: 16
                            onCheckStateChanged: settings.closeToTray = checked
                            Material.foreground: formText
                        }

                        CheckBox {
                            enabled: sysTrayCheckbox.checked
                            checked: settings.hideOnLaunch
                            text: "Hide on launch"
                            padding: 0
                            indicator.width: 16
                            indicator.height: 16
                            onCheckStateChanged: settings.hideOnLaunch = checked
                            Material.foreground: formText
                        }
                    }
                }
            }
        }

        Pane {
            visible: isKeyAvailable()
            id: keyPane
            Layout.alignment: Qt.AlignCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.maximumWidth: dynamicWidth + dynamicMargin
            Layout.topMargin: 8
            Layout.bottomMargin: 8

            background: Rectangle {
                color: isDark() ? defaultDarkLighter : defaultLightDarker
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 4
                    samples: radius * 2
                    verticalOffset: 2
                    horizontalOffset: 2
                    color: formDropShdaow
                    transparentBorder: true
                }
            }

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                width: app.width - dynamicMargin
                       < dynamicWidth ? app.width - dynamicMargin : dynamicWidth
                spacing: 16

                RowLayout {
                    Label {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        text: deviceInfo()
                        color: yubicoGreen
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        topPadding: 8
                        bottomPadding: 8
                        Layout.fillWidth: true
                        background: Item {
                            implicitWidth: parent.width
                            implicitHeight: 40
                            Rectangle {
                                color: formTitleUnderline
                                height: 1
                                width: parent.width
                                y: 31
                            }
                        }
                    }
                }

                StyledExpansionPanel {
                    id: passwordManagementPanel
                    label: yubiKey.currentDeviceHasPassword ? "Change Password" : "Set Password"
                    description: "For additional security and to prevent unauthorized access the YubiKey may be protected with a password."
                    motherView: settingsPanel

                    ColumnLayout {
                        visible: parent.isExpanded
                        Layout.alignment: Qt.AlignRight | Qt.AlignTop
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        Layout.bottomMargin: 8

                        StyledTextField {
                            id: currentPasswordField
                            visible: yubiKey.currentDeviceHasPassword ? true : false
                            labelText: qsTr("Current Password")
                            echoMode: TextInput.Password
                            Keys.onEnterPressed: submitPassword()
                            Keys.onReturnPressed: submitPassword()
                        }
                        StyledTextField {
                            id: newPasswordField
                            labelText: qsTr("New Password")
                            echoMode: TextInput.Password
                            Keys.onEnterPressed: submitPassword()
                            Keys.onReturnPressed: submitPassword()
                        }
                        StyledTextField {
                            id: confirmPasswordField
                            labelText: qsTr("Confirm Password")
                            echoMode: TextInput.Password
                            Keys.onEnterPressed: submitPassword()
                            Keys.onReturnPressed: submitPassword()
                        }
                        StyledButton {
                            Layout.alignment: Qt.AlignRight | Qt.AlignTop
                            text: yubiKey.currentDeviceHasPassword ? "Change Password" : "Set Password"
                            flat: true
                            enabled: {
                                if (yubiKey.currentDeviceValidated) {
                                    if (yubiKey.currentDeviceHasPassword
                                            && currentPasswordField.text.length == 0) {
                                        return false
                                    }
                                    if (newPasswordField.text.length > 0
                                            && (newPasswordField.text
                                                === confirmPasswordField.text)) {
                                        return true
                                    }
                                }
                                return false
                            }
                            onClicked: submitPassword()
                        }
                    }
                }

                StyledExpansionPanel {
                    label: "Reset"
                    description: "Warning: Resetting the OATH application will delete all credentials and restore factory defaults."
                    isEnabled: false
                    toolButtonIcon: "../images/reset.svg"
                    toolButtonToolTip: "Reset OATH Application"
                    toolButton.onClicked: navigator.confirm(
                                              "Are you sure?",
                                              "Are you sure you want to reset the OATH application? This will delete all credentials and restore factory defaults.",
                                              function () {
                                                  navigator.goToLoading()
                                                  yubiKey.reset(
                                                              function (resp) {
                                                                  navigator.goToSettings()
                                                                  if (resp.success) {
                                                                      entries.clear()
                                                                      navigator.snackBar(
                                                                                  "Reset completed")
                                                                      yubiKey.currentDeviceValidated = true
                                                                      yubiKey.currentDeviceHasPassword = false
                                                                  } else {
                                                                      navigator.snackBarError(navigator.getErrorMessage(resp.error_id))
                                                                      console.log("reset failed:",
                                                                                  resp.error_id)
                                                                  }
                                                              })
                                              })
                }
            }
        }
    }
}
