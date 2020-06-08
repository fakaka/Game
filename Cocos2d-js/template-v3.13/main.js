window.onload = function () {
    cc.game.onStart = function () {
        //load resources
        cc.LoaderScene.preload([g_resource], function () {
            cc.director.runScene(new MyScene());
        }, this);
    };
    cc.game.run("gameCanvas");
};