local MakePlayerCharacter = require "prefabs/player_common"

local assets = {

        Asset( "ANIM", "anim/player_basic.zip" ),
        Asset( "ANIM", "anim/player_idles_shiver.zip" ),
        Asset( "ANIM", "anim/player_actions.zip" ),
        Asset( "ANIM", "anim/player_actions_axe.zip" ),
        Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
        Asset( "ANIM", "anim/player_actions_shovel.zip" ),
        Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
        Asset( "ANIM", "anim/player_actions_eat.zip" ),
        Asset( "ANIM", "anim/player_actions_item.zip" ),
        Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
        Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
        Asset( "ANIM", "anim/player_actions_fishing.zip" ),
        Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
        Asset( "ANIM", "anim/player_bush_hat.zip" ),
        Asset( "ANIM", "anim/player_attacks.zip" ),
        Asset( "ANIM", "anim/player_idles.zip" ),
        Asset( "ANIM", "anim/player_rebirth.zip" ),
        Asset( "ANIM", "anim/player_jump.zip" ),
        Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
        Asset( "ANIM", "anim/player_teleport.zip" ),
        Asset( "ANIM", "anim/wilson_fx.zip" ),
        Asset( "ANIM", "anim/player_one_man_band.zip" ),
        Asset( "ANIM", "anim/shadow_hands.zip" ),
        Asset( "SOUND", "sound/sfx.fsb" ),
        Asset( "SOUND", "sound/wilson.fsb" ),
        Asset( "ANIM", "anim/beard.zip" ),

        Asset( "ANIM", "anim/esctemplate.zip" ),
		Asset( "ANIM", "anim/wharangW.zip" ),

		Asset( "IMAGE", "images/map_icons/wharang_evil.tex" ),
		Asset( "ATLAS", "images/map_icons/wharang_evil.xml" ),
}
local prefabs = {}

-- Custom starting items
local start_inv = {
	"yukarihat",
	"eardress",
	"mihobell"
}

local function applyUpgrades(inst)

	local max_upgrades = 10
	if inst.level > max_upgrades then
    	inst.level = max_upgrades
	else
		local upgrades = math.min(inst.level, max_upgrades)
		local hunger_percent = inst.components.hunger:GetPercent()
		local health_percent = inst.components.health:GetPercent()
		local sanity_percent = inst.components.sanity:GetPercent()

		inst.components.hunger.max = math.ceil (150 + upgrades * 5)
		inst.components.sanity.max = math.ceil (200 + upgrades * 5)
		inst.components.health.maxhealth = math.ceil (150 + upgrades * 5)

		inst.components.talker:Say("Level Up! : ".. (inst.level))

		inst.components.hunger:SetPercent(hunger_percent)
		inst.components.health:SetPercent(health_percent)
		inst.components.sanity:SetPercent(sanity_percent)
	end

end

local function onEat(inst, food)
	local summonchance1 = 0.8	
    if math.random() < summonchance1 and food and food.components.edible.foodtype == "MEAT" then
		inst.level = inst.level + 1
		applyUpgrades(inst)	
		-- inst.components.sanity:DoDelta(inst.components.sanity.max*0.05)
		-- inst.components.health:DoDelta(inst.components.health.maxhealth*0.05)
		-- inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
		inst.HUD.controls.status.heart:PulseGreen()
		inst.HUD.controls.status.stomach:PulseGreen()
		inst.HUD.controls.status.brain:PulseGreen()
		
		inst.HUD.controls.status.brain:ScaleTo(1.3,1,.7)
		inst.HUD.controls.status.heart:ScaleTo(1.3,1,.7)
		inst.HUD.controls.status.stomach:ScaleTo(1.3,1,.7)
	end
end

local function onKill(inst,data)
	if math.random() < 0.9 and data.inst:HasTag("monster") then
		inst.level = inst.level + 1
		applyUpgrades(inst)
	end
end

local function updatestats(inst)
	if GetClock():IsDay() and not GetWorld():IsCave() then
		inst.components.combat.damagemultiplier = 1
		inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED
		inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
		inst.Light:Enable(false)
		inst.AnimState:SetBuild("esctemplate")
		inst.MiniMapEntity:SetIcon("esctemplate.tex")
 	elseif GetClock():IsDusk() and not GetWorld():IsCave() then
		inst.components.combat.damagemultiplier = 1.1
		inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED * 1.1
		inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 1.1
	elseif GetClock():IsNight() and not GetWorld():IsCave() then
		inst.components.combat.damagemultiplier = 1.2
		inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED * 1.2
		inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 1.2
		inst.Light:Enable(true)
		if GetClock():GetMoonPhase() == "full" then
			inst.components.talker:Say("Full Moon")
			inst.AnimState:SetBuild("wharangW")
			inst.MiniMapEntity:SetIcon("wharang_evil.tex")
		end
	end
end

local fn = function(inst)
	-- choose which sounds this character will play
	inst.soundsname = "willow"
	inst.MiniMapEntity:SetIcon( "esctemplate.tex" )
	
    inst.level = 0;
	-- Stats	
	inst.components.hunger:SetMax(150)
	inst.components.sanity:SetMax(200)
	inst.components.health:SetMaxHealth(150)
	
	inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE * 1
	-- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 1

	-- inst.components.walkspeed=4
	
	inst.entity:AddLight()
	inst.Light:SetRadius(9)
	inst.Light:SetFalloff(1)
	inst.Light:SetIntensity(.5)
	inst.Light:SetColour(128/255,128/255,255/255)
	inst.Light:Enable(false)

    inst.components.eater:SetOnEatFn(onEat)

    TheInput:AddKeyUpHandler(KEY_L, function()
		inst.components.talker:Say("Level : ".. (inst.level))
	end)

	--KILL!
	-- inst:ListenForEvent("killed", onkill)
	inst:ListenForEvent( "entity_death", function(wrld, data) onKill(inst, data) end, GetWorld())
	inst:ListenForEvent( "dusktime", function() updatestats(inst) end , GetWorld())
	inst:ListenForEvent( "daytime", function() updatestats(inst) end , GetWorld())
	inst:ListenForEvent( "nighttime", function() updatestats(inst) end , GetWorld())
	updatestats(inst)

	inst.components.talker:Say("I'm liyitong")

end

return MakePlayerCharacter("esctemplate", prefabs, assets, fn, start_inv)
