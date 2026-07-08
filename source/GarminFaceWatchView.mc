using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Activity as Activity;
using Toybox.Lang as Lang;

class GarminFaceWatchView extends Ui.WatchFace {

    // Vertical position of each field, as a fraction of screen height.
    const TIME_Y_RATIO = 0.34;
    const DATE_Y_RATIO = 0.56;
    const HEART_RATE_Y_RATIO = 0.70;

    // Solid backdrop drawn behind every label so it stays legible
    // regardless of the HR zone background color.
    const LABEL_PADDING_X = 8;
    const LABEL_PADDING_Y = 2;

    // HR zone upper bounds in bpm; anything above the last one is the top zone.
    const HR_ZONE_BLUE_MAX_BPM = 99;
    const HR_ZONE_GREEN_MAX_BPM = 119;
    const HR_ZONE_YELLOW_MAX_BPM = 149;

    // Battery ring: drawn at the outer edge, black track behind a white
    // progress arc so it reads clearly against any HR zone background.
    const BATTERY_RING_MARGIN = 4;
    const BATTERY_RING_TRACK_WIDTH = 8;
    const BATTERY_RING_FILL_WIDTH = 5;
    const BATTERY_RING_START_DEGREE = 90; // 12 o'clock

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc) {
        var height = dc.getHeight();
        var heartRate = getCurrentHeartRate();

        dc.setColor(Gfx.COLOR_WHITE, getHeartRateZoneColor(heartRate));
        dc.clear();

        drawBatteryRing(dc);
        drawTime(dc, height);
        drawDate(dc, height);
        drawHeartRate(dc, height, heartRate);
    }

    function getCurrentHeartRate() {
        var heartRate = null;
        var activityInfo = Activity.getActivityInfo();

        if (activityInfo != null) {
            heartRate = activityInfo.currentHeartRate;
        }

        return heartRate;
    }

    function getHeartRateZoneColor(heartRate) {
        if (heartRate == null) {
            return Gfx.COLOR_LT_GRAY;
        } else if (heartRate <= HR_ZONE_BLUE_MAX_BPM) {
            return Gfx.COLOR_BLUE;
        } else if (heartRate <= HR_ZONE_GREEN_MAX_BPM) {
            return Gfx.COLOR_GREEN;
        } else if (heartRate <= HR_ZONE_YELLOW_MAX_BPM) {
            return Gfx.COLOR_YELLOW;
        }

        return Gfx.COLOR_RED;
    }

    // Draws text on a solid black box so it reads clearly no matter what
    // color the HR zone background currently is.
    function drawLabel(dc, y, font, text, textColor) {
        var centerX = dc.getWidth() / 2;
        var dims = dc.getTextDimensions(text, font) as Lang.Array<Lang.Number>;
        var boxWidth = dims[0] + (LABEL_PADDING_X * 2);
        var boxHeight = dims[1] + (LABEL_PADDING_Y * 2);

        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(centerX - (boxWidth / 2), y - LABEL_PADDING_Y, boxWidth, boxHeight);

        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX, y, font, text, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawTime(dc, height) {
        var clockTime = Sys.getClockTime();
        var hour = clockTime.hour;

        if (!Sys.getDeviceSettings().is24Hour) {
            if (hour == 0) {
                hour = 12;
            } else if (hour > 12) {
                hour = hour - 12;
            }
        }

        var timeString = Lang.format("$1$:$2$", [hour, clockTime.min.format("%02d")]);

        drawLabel(dc, (height * TIME_Y_RATIO).toNumber(), Gfx.FONT_NUMBER_MEDIUM, timeString, Gfx.COLOR_WHITE);
    }

    function drawDate(dc, height) {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$ $2$ $3$", [today.day_of_week, today.day, today.month]);

        drawLabel(dc, (height * DATE_Y_RATIO).toNumber(), Gfx.FONT_SMALL, dateString, Gfx.COLOR_LT_GRAY);
    }

    // Clamps to [0, 100] and converts to a sweep in degrees for the battery
    // ring's progress arc. Pure/no Dc dependency so it's unit-testable.
    function getBatterySweepDegrees(batteryPercent) {
        var clamped = batteryPercent;

        if (clamped < 0) {
            clamped = 0;
        } else if (clamped > 100) {
            clamped = 100;
        }

        return (clamped / 100.0) * 360.0;
    }

    // Draws the battery level as a ring around the outer edge: a black
    // track (always a full circle, doubles as a legibility border against
    // any HR zone background) with a white progress arc on top that
    // shrinks toward nothing as the battery drains.
    function drawBatteryRing(dc) {
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var maxRadius = (dc.getWidth() < dc.getHeight() ? dc.getWidth() : dc.getHeight()) / 2;
        var radius = maxRadius - BATTERY_RING_MARGIN;
        var sweepDegrees = getBatterySweepDegrees(Sys.getSystemStats().battery);

        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(BATTERY_RING_TRACK_WIDTH);
        dc.drawCircle(centerX, centerY, radius);

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(BATTERY_RING_FILL_WIDTH);

        if (sweepDegrees >= 360.0) {
            dc.drawCircle(centerX, centerY, radius);
        } else if (sweepDegrees > 0.0) {
            var endDegree = BATTERY_RING_START_DEGREE - sweepDegrees;
            dc.drawArc(centerX, centerY, radius, Gfx.ARC_CLOCKWISE, BATTERY_RING_START_DEGREE, endDegree);
        }

        dc.setPenWidth(1);
    }

    function drawHeartRate(dc, height, heartRate) {
        var hrString = "HR " + ((heartRate != null) ? heartRate.format("%d") : "--");

        drawLabel(dc, (height * HEART_RATE_Y_RATIO).toNumber(), Gfx.FONT_TINY, hrString, Gfx.COLOR_RED);
    }

}
