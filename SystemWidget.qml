import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 14

    property int cpuPercent:  0
    property int ramPercent:  0
    property int diskPercent: 0

    Text {
        text: "SYSTEM"
        font.pixelSize: 11
        color: "#444b6a"
        font.letterSpacing: 1
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 0

        Repeater {
            model: [
                { label: "CPU",  value: cpuPercent,  color: "#7aa2f7" },
                { label: "RAM",  value: ramPercent,  color: "#e0af68" },
                { label: "Disk", value: diskPercent, color: "#9ece6a" }
            ]

            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    width: 64
                    height: 64

                    Canvas {
                        anchors.fill: parent
                        property real progress: modelData.value / 100.0
                        property color ringColor: modelData.color

                        onProgressChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            var cx = width / 2
                            var cy = height / 2
                            var r = 26
                            var start = -Math.PI / 2
                            var end = start + (2 * Math.PI * progress)

                            // Background ring
                            ctx.beginPath()
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI)
                            ctx.strokeStyle = Qt.rgba(0.66, 0.69, 0.84, 0.1)
                            ctx.lineWidth = 5
                            ctx.lineCap = "round"
                            ctx.stroke()

                            // Progress ring
                            if (progress > 0) {
                                ctx.beginPath()
                                ctx.arc(cx, cy, r, start, end)
                                ctx.strokeStyle = modelData.color
                                ctx.lineWidth = 5
                                ctx.lineCap = "round"
                                ctx.stroke()
                            }

                            // Center text
                            ctx.fillStyle = "#c0c8f0"
                            ctx.font = "500 13px sans-serif"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
                            ctx.fillText(modelData.value + "%", cx, cy)
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: modelData.label
                    font.pixelSize: 11
                    color: "#6b7399"
                }
            }
        }
    }

    // CPU via /proc/stat
    property var lastIdle: 0
    property var lastTotal: 0

    Process {
        id: cpuProc
        command: ["bash", "-c", "cat /proc/stat | head -1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(/\s+/)
                var vals = parts.slice(1).map(Number)
                var idle = vals[3]
                var total = vals.reduce(function(a, b) { return a + b }, 0)
                var diffIdle = idle - lastIdle
                var diffTotal = total - lastTotal
                if (diffTotal > 0)
                    cpuPercent = Math.round((1 - diffIdle / diffTotal) * 100)
                lastIdle = idle
                lastTotal = total
            }
        }
    }

    // RAM via /proc/meminfo
    Process {
        id: ramProc
        command: ["bash", "-c", "awk '/MemTotal|MemAvailable/{print $2}' /proc/meminfo"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 2) {
                    var total = parseInt(lines[0])
                    var avail = parseInt(lines[1])
                    ramPercent = Math.round((1 - avail / total) * 100)
                }
            }
        }
    }

    // Disk usage for /
    Process {
        id: diskProc
        command: ["bash", "-c", "df / | awk 'NR==2{print $5}' | tr -d '%'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                diskPercent = parseInt(this.text.trim()) || 0
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            diskProc.running = true
        }
    }
}