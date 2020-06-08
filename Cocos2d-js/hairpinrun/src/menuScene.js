var MenuScene = cc.Scene.extend({
    ctor: function () {
        this._super();
    },
    onEnter: function () {
        this._super();
        var layer = new MenuLayer();
        layer.init();
        this.addChild(layer);
    }
});

var MenuLayer = cc.Layer.extend({
    ctor: function () {
        this._super();
    },
    init: function () {
        this._super();
        var size = cc.director.getWinSize();

        var bgSprite = new cc.Sprite(res.hello_bg_png);
        bgSprite.setPosition(size.width / 2, size.height / 2);
        this.addChild(bgSprite);

        var menuItem = new cc.MenuItemSprite(
            new cc.Sprite(res.start_n_png),
            new cc.Sprite(res.start_s_png),
            function () {
                cc.log("==>start game");
                cc.director.runScene(new PlayScene());
            }, this);
        var menu = new cc.Menu(menuItem);
        menu.setPosition(size.width / 2, size.height / 2);
        this.addChild(menu);
    }
});
