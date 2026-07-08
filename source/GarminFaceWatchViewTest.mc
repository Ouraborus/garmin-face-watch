using Toybox.Test;
using Toybox.Graphics as Gfx;

(:test)
function testHeartRateZoneNoData(logger) {
    var view = new GarminFaceWatchView();
    return view.getHeartRateZoneColor(null) == Gfx.COLOR_LT_GRAY;
}

(:test)
function testHeartRateZoneBlue(logger) {
    var view = new GarminFaceWatchView();
    return view.getHeartRateZoneColor(0) == Gfx.COLOR_BLUE
        && view.getHeartRateZoneColor(99) == Gfx.COLOR_BLUE;
}

(:test)
function testHeartRateZoneGreen(logger) {
    var view = new GarminFaceWatchView();
    return view.getHeartRateZoneColor(100) == Gfx.COLOR_GREEN
        && view.getHeartRateZoneColor(119) == Gfx.COLOR_GREEN;
}

(:test)
function testHeartRateZoneYellow(logger) {
    var view = new GarminFaceWatchView();
    return view.getHeartRateZoneColor(120) == Gfx.COLOR_YELLOW
        && view.getHeartRateZoneColor(149) == Gfx.COLOR_YELLOW;
}

(:test)
function testHeartRateZoneRed(logger) {
    var view = new GarminFaceWatchView();
    return view.getHeartRateZoneColor(150) == Gfx.COLOR_RED
        && view.getHeartRateZoneColor(220) == Gfx.COLOR_RED;
}

(:test)
function testBatterySweepEmpty(logger) {
    var view = new GarminFaceWatchView();
    return view.getBatterySweepDegrees(0) == 0.0;
}

(:test)
function testBatterySweepHalf(logger) {
    var view = new GarminFaceWatchView();
    return view.getBatterySweepDegrees(50) == 180.0;
}

(:test)
function testBatterySweepFull(logger) {
    var view = new GarminFaceWatchView();
    return view.getBatterySweepDegrees(100) == 360.0;
}

(:test)
function testBatterySweepClampsAboveHundred(logger) {
    var view = new GarminFaceWatchView();
    return view.getBatterySweepDegrees(150) == 360.0;
}

(:test)
function testBatterySweepClampsBelowZero(logger) {
    var view = new GarminFaceWatchView();
    return view.getBatterySweepDegrees(-10) == 0.0;
}
