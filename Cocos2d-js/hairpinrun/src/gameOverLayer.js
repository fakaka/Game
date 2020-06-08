var GameOverLayer = cc.LayerColor.extend({
    ctor: function () {
        this._super(cc.color(0, 0, 0, 180));
        var size = cc.director.getWinSize();
        var menuItemRestart = new cc.MenuItemSprite(
            new cc.Sprite(res.restart_n_png),
            new cc.Sprite(res.restart_s_png),
            function (sender) {
                console.log("==>restart game");
                cc.director.resume();
                cc.director.runScene(new PlayScene());
            }, this);
        var menu = new cc.Menu(menuItemRestart);
        menu.setPosition(size.width / 2, size.height / 2);
        this.addChild(menu);
    }
});
