if (typeof RunnerStat == "undefined") {
    var RunnerStat = {
        running: 0,
        jumpUp: 1,
        jumpDown: 2
    }
}

var GameLayer = cc.Layer.extend({
    spriteSheet: null,
    runningAction: null,
    jumpUpAction: null,
    jumpDownAction: null,
    sprite: null,
    space: null,
    body: null,
    shape: null,
    runnerStat: null,
    ctor: function (space) {
        this._super();
        this.space = space;
        this.runnerStat = RunnerStat.running;
        this.init();
    },
    init: function () {
        var size = cc.director.getWinSize();
        // this._debugNode = new cc.PhysicsDebugNode(this.space);
        // // Parallax ratio and offset
        // this.addChild(this._debugNode, 10);

        cc.spriteFrameCache.addSpriteFrames(res.runner_plist);
        this.spriteSheet = new cc.SpriteBatchNode(res.runner_png);
        this.addChild(this.spriteSheet);
        this.createAction();

        this.sprite = new cc.PhysicsSprite("#runner0.png");
        var contentSize = this.sprite.getContentSize();
        this.body = new cp.Body(1, cp.momentForBox(1, contentSize.width, contentSize.height));
        this.body.p = cc.p(g_runnerStartX, g_groundHeight + contentSize.height / 2);
        this.body.applyImpulse(cp.v(150, 0), cp.v(0, 0));//run speed
        this.space.addBody(this.body);
        this.shape = new cp.BoxShape(this.body, contentSize.width - 14, contentSize.height);
        this.space.addShape(this.shape);
        this.sprite.setBody(this.body);

        this.sprite.runAction(this.runningAction);
        this.spriteSheet.addChild(this.sprite);
        cc.eventManager.addListener({
            event: cc.EventListener.TOUCH_ONE_BY_ONE,
            swallowTouches: true,
            onTouchBegan: function (touch, event) {
                var pos = touch.getLocation();
                // event.getCurrentTarget().recognizer.beginPoint(pos.x, pos.y);
                return true;
            },
            onTouchMoved: function (touch, event) {
                var pos = touch.getLocation();
                // event.getCurrentTarget().recognizer.movePoint(pos.x, pos.y);
            },
            onTouchEnded: function (touch, event) {
                // this.sprite.runAction(this.jumpUpAction);
                event.getCurrentTarget().jump();
            }
        }, this);

        this.scheduleUpdate();
    },
    createAction: function () {
        // runningAction
        var animFrames = [];
        for (var i = 0; i < 8; i++) {
            var str = "runner" + i + ".png";
            var frame = cc.spriteFrameCache.getSpriteFrame(str);
            animFrames.push(frame);
        }

        var animation = new cc.Animation(animFrames, 0.1);
        this.runningAction = new cc.RepeatForever(new cc.Animate(animation));
        this.runningAction.retain();


        //jumpUpAction
        animFrames = [];
        for (var i = 0; i < 4; i++) {
            var str = "runnerJumpUp" + i + ".png";
            var frame = cc.spriteFrameCache.getSpriteFrame(str);
            animFrames.push(frame);
        }
        animation = new cc.Animation(animFrames, 0.2);
        this.jumpUpAction = new cc.RepeatForever(new cc.Animate(animation));
        this.runningAction.retain();


        //jumpDownAction
        animFrames = [];
        for (var i = 0; i < 2; i++) {
            var str = "runnerJumpDown" + i + ".png";
            var frame = cc.spriteFrameCache.getSpriteFrame(str);
            animFrames.push(frame);
        }
        animation = new cc.Animation(animFrames, 0.3);
        this.jumpDownAction = new cc.RepeatForever(new cc.Animate(animation));
        this.jumpDownAction.retain();
    },
    getEyeX: function () {
        return this.sprite.getPositionX() - g_runnerStartX;
    },
    jump: function () {
        cc.log("jump");
        if (this.runnerStat == RunnerStat.running) {
            cc.audioEngine.playEffect(res.jump_mp3);
            this.body.applyImpulse(cp.v(0, 250), cp.v(0, 0));
            this.runnerStat = RunnerStat.jumpUp;
            this.sprite.stopAllActions();
            this.sprite.runAction(this.jumpUpAction);
        }
    },
    update: function () {
        var sLayer = this.getParent().getParent().getChildByTag(TagOfLayer.Status);
        sLayer.updateMeter(this.getEyeX());
        var vel = this.body.getVel();
        if (this.runnerStat == RunnerStat.jumpUp) {
            if (vel.y < 0.1) {
                this.runnerStat = RunnerStat.jumpDown;
                this.sprite.stopAllActions();
                this.sprite.runAction(this.jumpDownAction);
            }
        } else if (this.runnerStat == RunnerStat.jumpDown) {
            if (vel.y == 0) {
                this.runnerStat = RunnerStat.running;
                this.sprite.stopAllActions();
                this.sprite.runAction(this.runningAction);
            }
        }
    }
});
