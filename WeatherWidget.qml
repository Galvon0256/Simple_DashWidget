import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 8

    property string temperature: "--"
    property string weatherCode: "--"
    property string windspeed:   "--"
    property string feelsLike:   "--"

    property real lat: 28.5833
    property real lon: 77.3000

    RowLayout {
        spacing: 12

        Text {
            text: weatherIcon(weatherCode)
            font.pixelSize: 36
        }

        ColumnLayout {
            spacing: 0
            Text {
                text: temperature !== "--" ? temperature + "°C" : "Loading..."
                font.pixelSize: 26
                font.weight: Font.Medium
                color: "#c0c8f0"
            }
            Text {
                text: "Feels like " + feelsLike + "°C"
                font.pixelSize: 12
                color: "#6b7399"
            }
        }
    }

    RowLayout {
        spacing: 6
        Text { text: "💨 " + windspeed + " km/h"; font.pixelSize: 12; color: "#6b7399" }
        Text { text: "·"; font.pixelSize: 12; color: "#6b7399" }
        Text { text: wmoDescription(weatherCode); font.pixelSize: 12; color: "#6b7399"; elide: Text.ElideRight }
        Text { text: "·"; font.pixelSize: 12; color: "#6b7399" }
        Text { text: "Dadri, UP"; font.pixelSize: 12; color: "#6b7399" }
    }

    Process {
        id: weatherProc
        command: [
            "curl", "-s",
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=" + lat +
            "&longitude=" + lon +
            "&current=temperature_2m,apparent_temperature,weathercode,windspeed_10m" +
            "&timezone=auto"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text)
                    var cur = data.current
                    temperature  = Math.round(cur.temperature_2m).toString()
                    feelsLike    = Math.round(cur.apparent_temperature).toString()
                    weatherCode  = cur.weathercode.toString()
                    windspeed    = Math.round(cur.windspeed_10m).toString()
                } catch(e) { temperature = "Err" }
            }
        }
    }

    Timer {
        interval: 600000
        running: true
        repeat: true
        onTriggered: weatherProc.running = true
    }

    function weatherIcon(code) {
        var c = parseInt(code)
        if (c === 0)  return "☀️"
        if (c <= 2)   return "🌤️"
        if (c === 3)  return "☁️"
        if (c <= 49)  return "🌫️"
        if (c <= 59)  return "🌦️"
        if (c <= 69)  return "🌧️"
        if (c <= 79)  return "🌨️"
        if (c <= 84)  return "🌧️"
        if (c <= 99)  return "⛈️"
        return "🌡️"
    }

    function wmoDescription(code) {
        var c = parseInt(code)
        if (c === 0)  return "Clear sky"
        if (c === 1)  return "Mainly clear"
        if (c === 2)  return "Partly cloudy"
        if (c === 3)  return "Overcast"
        if (c <= 49)  return "Foggy"
        if (c <= 59)  return "Drizzle"
        if (c <= 69)  return "Rain"
        if (c <= 79)  return "Snow"
        if (c <= 84)  return "Rain showers"
        if (c <= 99)  return "Thunderstorm"
        return "Unknown"
    }
}