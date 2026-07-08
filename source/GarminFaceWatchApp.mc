using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class GarminFaceWatchApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [ new GarminFaceWatchView() ];
    }

}
