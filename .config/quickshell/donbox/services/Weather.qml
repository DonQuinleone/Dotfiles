pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int refreshMs: 900000
    readonly property int timeoutSeconds: 15
    readonly property int firstDay: 0

    // Opening the pane is not news about the weather, so a
    // reading this fresh is shown again rather than asked for
    // again.
    readonly property int freshMs: 600000

    readonly property string api:
        "https://api.open-meteo.com/v1/forecast"

    readonly property string windUnit: "mph"
    readonly property string degrees: "°"

    // The codes are the World Meteorological Organization's,
    // which Open-Meteo reports rather than words of its own.
    readonly property var conditions: ({
        0:  { label: "Clear",             glyph: "󰖙", dark: "󰖔" },
        1:  { label: "Mainly clear",      glyph: "󰖙", dark: "󰖔" },
        2:  { label: "Partly cloudy",     glyph: "󰖕", dark: "󰼱" },
        3:  { label: "Overcast",          glyph: "󰖐" },
        45: { label: "Fog",               glyph: "󰖑" },
        48: { label: "Freezing fog",      glyph: "󰖑" },
        51: { label: "Light drizzle",     glyph: "󰖗" },
        53: { label: "Drizzle",           glyph: "󰖗" },
        55: { label: "Heavy drizzle",     glyph: "󰖗" },
        56: { label: "Freezing drizzle",  glyph: "󰙿" },
        57: { label: "Freezing drizzle",  glyph: "󰙿" },
        61: { label: "Light rain",        glyph: "󰖗" },
        63: { label: "Rain",              glyph: "󰖖" },
        65: { label: "Heavy rain",        glyph: "󰖖" },
        66: { label: "Freezing rain",     glyph: "󰙿" },
        67: { label: "Freezing rain",     glyph: "󰙿" },
        71: { label: "Light snow",        glyph: "󰖘" },
        73: { label: "Snow",              glyph: "󰖘" },
        75: { label: "Heavy snow",        glyph: "󰖘" },
        77: { label: "Snow grains",       glyph: "󰖘" },
        80: { label: "Light showers",     glyph: "󰖗" },
        81: { label: "Showers",           glyph: "󰖖" },
        82: { label: "Heavy showers",     glyph: "󰖖" },
        85: { label: "Snow showers",      glyph: "󰖘" },
        86: { label: "Snow showers",      glyph: "󰖘" },
        95: { label: "Thunderstorm",      glyph: "󰖓" },
        96: { label: "Thunder and hail",  glyph: "󰖒" },
        99: { label: "Thunder and hail",  glyph: "󰖒" }
    })

    readonly property var unknownCondition: ({
        label: "Unknown", glyph: "󰖐", dark: "󰖐"
    })

    // What a reading looks like before there is one, so the
    // card can lay itself out against something.
    readonly property var blank: ({
        temperature: null,
        apparent: null,
        code: 0,
        wind: 0,
        daylight: true,
        high: null,
        low: null,
        sunrise: "",
        sunset: ""
    })

    property bool watching: false
    property var reading: null
    property bool fetching: false
    property bool failed: false
    property real fetchedAtMs: 0

    readonly property bool ready: root.watching && Location.known

    readonly property var condition: root.reading
        ? root.faceOf(root.reading.code, root.reading.daylight)
        : root.unknownCondition

    function faceOf(code: int, daylight: bool): var {
        const found = root.conditions[code] ?? root.unknownCondition;
        const glyph = daylight
            ? found.glyph
            : (found.dark ?? found.glyph);
        return { label: found.label, glyph: glyph };
    }

    function rounded(value: var): string {
        if (value === undefined || value === null) return "";
        return `${Math.round(value)}${root.degrees}`;
    }

    function query(): string {
        const place = Location.place;
        return `${root.api}?latitude=${place.latitude}`
            + `&longitude=${place.longitude}`
            + "&current=temperature_2m,apparent_temperature"
            + ",weather_code,wind_speed_10m,is_day"
            + "&daily=temperature_2m_max,temperature_2m_min"
            + ",sunrise,sunset"
            + `&wind_speed_unit=${root.windUnit}`
            + "&timezone=auto&forecast_days=1";
    }

    function refresh(): void {
        if (!root.ready || reader.running) return;
        reader.command = ["curl", "-fsS", "--max-time",
            `${root.timeoutSeconds}`, root.query()];
        root.fetching = true;
        reader.running = true;
    }

    // Open-Meteo gives the sun's times as local stamps without
    // a zone, which is exactly the reading wanted, so the clock
    // is taken from the text rather than parsed into a date and
    // shifted back out of it.
    function clockOf(stamp: var): string {
        const written = `${stamp ?? ""}`;
        const mark = written.indexOf("T");
        return mark < 0 ? "" : written.slice(mark + 1);
    }

    function absorb(payload: string): void {
        root.fetching = false;
        try {
            const data = JSON.parse(payload);
            const now = data.current;
            const day = data.daily;
            root.reading = {
                temperature: now.temperature_2m,
                apparent: now.apparent_temperature,
                code: now.weather_code,
                wind: now.wind_speed_10m,
                daylight: now.is_day === 1,
                high: day.temperature_2m_max[root.firstDay],
                low: day.temperature_2m_min[root.firstDay],
                sunrise: root.clockOf(day.sunrise[root.firstDay]),
                sunset: root.clockOf(day.sunset[root.firstDay])
            };
            root.fetchedAtMs = Date.now();
            root.failed = false;
        } catch (error) {
            root.failed = true;
        }
    }

    function stale(): bool {
        return Date.now() - root.fetchedAtMs > root.freshMs;
    }

    onReadyChanged: if (root.ready && root.stale()) root.refresh()

    // A reading belongs to the place it was taken at.
    Connections {
        target: Location

        function onPlaceChanged(): void {
            root.reading = null;
            root.fetchedAtMs = 0;
            root.refresh();
        }
    }

    Timer {
        running: root.ready
        repeat: true
        interval: root.refreshMs

        onTriggered: root.refresh()
    }

    Process {
        id: reader

        stdout: StdioCollector {
            onStreamFinished: root.absorb(this.text)
        }

        onExited: exitCode => {
            root.fetching = false;
            if (exitCode !== 0) root.failed = true;
        }
    }
}
