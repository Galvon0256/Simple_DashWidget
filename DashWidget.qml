import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    visible: true
    width: 260
    height: mainCol.implicitHeight + 44

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "dash-widget"

    anchors.bottom: true
    anchors.left: true
    margins.bottom: 20
    margins.left: 20

    color: "transparent"
    

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.08, 0.09, 0.14, 0.5)
        radius: 20

        ColumnLayout {
            id: mainCol
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 20
            }
            spacing: 0

            ClockWidget {}

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0.66, 0.69, 0.84, 0.1)
                Layout.topMargin: 16
                Layout.bottomMargin: 16
            }

            WeatherWidget {}

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0.66, 0.69, 0.84, 0.1)
                Layout.topMargin: 16
                Layout.bottomMargin: 16
            }

            SystemWidget {}

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0.66, 0.69, 0.84, 0.1)
                Layout.topMargin: 16
                Layout.bottomMargin: 16
            }

            MediaWidget {}

            Item { Layout.preferredHeight: 4 }
        }
    }
}