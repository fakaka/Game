var StatusLayer = cc.Layer.extend({
    labelCoin: null,
    labelMeter: null,
    coins: 0,
    ctor: function () {
        this._super();
        this.init();
    },
    init: function () {
        var size = cc.director.getWinSize();

        this.labelCoin = new cc.LabelTTF("Coins : 0", "Helvetica", 20);
        this.labelCoin.setColor(cc.color.WHITE);
        this.labelCoin.setPosition(80, size.height - 20);
        this.addChild(this.labelCoin);

        this.labelMeter = new cc.LabelTTF(" 0 M", "Helvetica", 20);
        this.labelMeter.setColor(cc.color(0, 0, 0));
        this.labelMeter.setPosition(size.width - 80, size.height - 20);
        this.addChild(this.labelMeter);
    },
    updateMeter: function (px) {
        this.labelMeter.setString(parseInt(px / 10) + "M");
    },
    updateCoin: function (num) {
        this.coins += num;
        this.labelCoin.setString("Coins:" + this.coins);
    }
})
