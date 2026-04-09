import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 2

    property string currentTime: "00:00"
    property string currentDay: "Monday"
    property string currentDate: "Jan 1, 2026"

    Text {
        text: currentTime
        font.pixelSize: 52
        font.weight: Font.Medium
        color: "#c0c8f0"
        font.letterSpacing: -1
        lineHeight: 1
    }

    Text {
        text: currentDay
        font.pixelSize: 15
        font.weight: Font.Medium
        color: "#7aa2f7"
        topPadding: 4
    }

    Text {
        text: currentDate
        font.pixelSize: 13
        color: "#6b7399"
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            var h = now.getHours().toString().padStart(2, "0")
            var m = now.getMinutes().toString().padStart(2, "0")
            currentTime = h + ":" + m

            var days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
            var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
            currentDay = days[now.getDay()]
            currentDate = months[now.getMonth()] + " " + now.getDate() + ", " + now.getFullYear()
        }
    }
}