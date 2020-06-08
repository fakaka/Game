var PlayScene = cc.Scene.extend({
    space: null,
    shapesToRemove: [],
    ctor: function () {
        this._super();
    },
    onEnter: function () {
        this._super();

        cc.audioEngine.playMusic(res.bgm_mp3, true);
        this.initPhysics();
        this.gameLayer = new cc.Layer();
        //add Background layer and Animation layer to gameLayer
        this.gameLayer.addChild(new BackgroundLayer(this.space), 0, TagOfLayer.Background);
        this.gameLayer.addChild(new GameLayer(this.space), 0, TagOfLayer.Game);
        this.addChild(this.gameLayer);
        this.addChild(new StatusLayer(), 0, TagOfLayer.Status);

        this.scheduleUpdate();
    },
    initPhysics: function () {
        //1. new space object
        this.space = new cp.Space();
        //2. setup the  Gravity
        this.space.gravity = cp.v(0, -350);
        // 3. set up Walls
        var wallBottom = new cp.SegmentShape(
            this.space.staticBody,
            cp.v(0, g_groundHeight),// start point
            cp.v(4294967295, g_groundHeight),// MAX INT:4294967295
            0);// thickness of wall
        this.space.addStaticShape(wallBottom);
        this.space.addCollisionHandler(SpriteTag.runner, SpriteTag.coin,
            this.collisionCoinBegin.bind(this), null, null, null);
        this.space.addCollisionHandler(SpriteTag.runner, SpriteTag.rock,
            this.collisionRockBegin.bind(this), null, null, null);
    },
    collisionCoinBegin: function (arbiter, space) {
        var shapes = arbiter.getShapes();
        this.shapesToRemove.push(shapes[1]);
        cc.audioEngine.playEffect(res.pickup_coin_mp3);
        this.getChildByTag(TagOfLayer.Status).updateCoin(1);
    },
    collisionRockBegin: function (arbiter, space) {
        cc.log("==>game over");
        cc.director.pause();
        cc.audioEngine.stopMusic();
        this.addChild(new GameOverLayer());
    },
    update: function (dt) {
        this.space.step(dt);

        var gLayer = this.gameLayer.getChildByTag(TagOfLayer.Game);
        var eyeX = gLayer.getEyeX();
        this.gameLayer.setPosition(-eyeX, 0);

        for (var i = 0; i < this.shapesToRemove.length; i++) {
            var shape = this.shapesToRemove[i];
            this.gameLayer.getChildByTag(TagOfLayer.Background).removeObjectByShape(shape);
        }
        this.shapesToRemove = [];
    }
});
