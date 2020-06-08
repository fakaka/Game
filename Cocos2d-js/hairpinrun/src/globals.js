/**
 * Created by mj on 2016/12/22.
 */
var g_groundHeight = 57;
var g_runnerStartX = 80;

if (typeof TagOfLayer == "undefined") {
    var TagOfLayer = {
        Background: 0,
        Game: 1,
        Status: 2
    };
}

if (typeof SpriteTag == "undefined") {
    var SpriteTag = {
        runner: 0,
        coin: 1,
        rock: 2
    };
}
