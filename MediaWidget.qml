import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 10

    property string trackTitle:  "Nothing playing"
    property string trackArtist: ""
    property string playStatus:  "Stopped"
    property int    position:    0
    property int    duration:    0

    property bool isPlaying: playStatus === "Playing"

    Text {
        text: "NOW PLAYING"
        font.pixelSize: 11
        color: "#444b6a"
        font.letterSpacing: 1
    }

    RowLayout {
        spacing: 12
        Layout.fillWidth: true

        // Album icon placeholder
        Rectangle {
            width: 44
            height: 44
            radius: 8
            color: Qt.rgba(0.18, 0.2, 0.33, 1)

            Text {
                anchors.centerIn: parent
                text: "♪"
                font.pixelSize: 20
                color: "#7aa2f7"
            }
        }

        ColumnLayout {
            spacing: 2
            Layout.fillWidth: true

            Text {
                text: trackTitle
                font.pixelSize: 13
                font.weight: Font.Medium
                color: "#c0c8f0"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: trackArtist !== "" ? trackArtist : "—"
                font.pixelSize: 11
                color: "#6b7399"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    // Progress bar
    Rectangle {
        Layout.fillWidth: true
        height: 3
        radius: 2
        color: Qt.rgba(0.66, 0.69, 0.84, 0.1)
        visible: duration > 0

        Rectangle {
            width: duration > 0 ? parent.width * (position / duration) : 0
            height: parent.height
            radius: 2
            color: "#7aa2f7"
        }
    }

    // Time labels
    RowLayout {
        visible: duration > 0
        Layout.fillWidth: true

        Text {
            text: formatTime(position)
            font.pixelSize: 10
            color: "#444b6a"
        }
        Item { Layout.fillWidth: true }
        Text {
            text: formatTime(duration)
            font.pixelSize: 10
            color: "#444b6a"
        }
    }

    // Controls
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 20

        // Previous
        Text {
            text: "⏮"
            font.pixelSize: 16
            color: "#6b7399"
            MouseArea {
                anchors.fill: parent
                onClicked: prevProc.running = true
                cursorShape: Qt.PointingHandCursor
            }
        }

        // Play/Pause
        Rectangle {
            width: 34
            height: 34
            radius: 17
            color: Qt.rgba(0.48, 0.63, 0.97, 0.15)

            Text {
                anchors.centerIn: parent
                text: isPlaying ? "⏸" : "▶"
                font.pixelSize: 16
                color: "#7aa2f7"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: playPauseProc.running = true
                cursorShape: Qt.PointingHandCursor
            }
        }

        // Next
        Text {
            text: "⏭"
            font.pixelSize: 16
            color: "#6b7399"
            MouseArea {
                anchors.fill: parent
                onClicked: nextProc.running = true
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    // Fetch track metadata
    Process {
        id: metaProc
        command: ["playerctl", "metadata", "--format", "{{title}}\n{{artist}}\n{{status}}\n{{position}}\n{{mpris:length}}"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 3 && lines[0] !== "") {
                    trackTitle  = lines[0] || "Unknown"
                    trackArtist = lines[1] || ""
                    playStatus  = lines[2] || "Stopped"
                    position    = Math.round(parseInt(lines[3] || "0") / 1000000)
                    duration    = Math.round(parseInt(lines[4] || "0") / 1000000)
                } else {
                    trackTitle  = "Nothing playing"
                    trackArtist = ""
                    playStatus  = "Stopped"
                    position    = 0
                    duration    = 0
                }
            }
        }
    }

    Process { id: playPauseProc; command: ["playerctl", "play-pause"] }
    Process { id: prevProc;      command: ["playerctl", "previous"] }
    Process { id: nextProc;      command: ["playerctl", "next"] }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: metaProc.running = true
    }

    function formatTime(secs) {
        if (!secs || secs <= 0) return "0:00"
        var m = Math.floor(secs / 60)
        var s = (secs % 60).toString().padStart(2, "0")
        return m + ":" + s
    }
}