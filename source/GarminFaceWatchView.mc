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
    const BATTERY_Y_RATIO = 0.70;
    const HEART_RATE_Y_RATIO = 0.80;

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.clear();

        drawTime(dc, width, height);
        drawDate(dc, width, height);
        drawBattery(dc, width, height);
        drawHeartRate(dc, width, height);
    }

    function drawTime(dc, width, height) {
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

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText((width / 2).toNumber(), (height * TIME_Y_RATIO).toNumber(), Gfx.FONT_NUMBER_MEDIUM, timeString, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawDate(dc, width, height) {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$ $2$ $3$", [today.day_of_week, today.day, today.month]);

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText((width / 2).toNumber(), (height * DATE_Y_RATIO).toNumber(), Gfx.FONT_SMALL, dateString, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawBattery(dc, width, height) {
        var battery = Sys.getSystemStats().battery;
        var batteryString = "BATT " + battery.format("%d") + "%";

        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        dc.drawText((width / 2).toNumber(), (height * BATTERY_Y_RATIO).toNumber(), Gfx.FONT_TINY, batteryString, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawHeartRate(dc, width, height) {
        var heartRate = null;
        var activityInfo = Activity.getActivityInfo();

        if (activityInfo != null) {
            heartRate = activityInfo.currentHeartRate;
        }

        var hrString = "HR " + ((heartRate != null) ? heartRate.format("%d") : "--");

        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        dc.drawText((width / 2).toNumber(), (height * HEART_RATE_Y_RATIO).toNumber(), Gfx.FONT_TINY, hrString, Gfx.TEXT_JUSTIFY_CENTER);
    }

}
