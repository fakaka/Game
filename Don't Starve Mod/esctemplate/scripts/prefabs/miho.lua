require "prefabutil"

local WAKE_TO_FOLLOW_DISTANCE = 2
local SLEEP_NEAR_LEADER_DISTANCE = 2

local assets ={
    Asset( "ANIM", "anim/fox_miho_new.zip" ),
	Asset( "ANIM", "anim/miho.zip" ),
	Asset( "ANIM", "anim/mihoup.zip" ),
	Asset( "ANIM", "anim/ui_miho_3x4.zip"),
	Asset( "ANIM", "anim/ui_miho_4x4.zip"),
}

local prefabs ={
	"mihobell",
}

local function ShouldKeepTarget(inst, target)
    return false
end

local function OnOpen(inst)
if inst.MorphTask then
	inst.MorphTask:Cancel()
	inst.MorphTask = nil
end
	inst.sg:GoToState("open")
end 

local function OnClose(inst) 
	inst.sg:GoToState("close")
end 

local function OnStopFollowing(inst) 
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst) 
    inst:AddTag("companion")
end

local slotpos_3x4 = {}

for y = 2.5, -.5, -1 do
    for x = 0, 2 do
        table.insert(slotpos_3x4, Vector3(75*x-75*2+75, 75*y-80*2+75,0))
    end
end

local slotpos_4x4 = {}

for y = 2.5, -.5, -1 do
    for x = 0, 3 do
        table.insert(slotpos_4x4, Vector3(75*x-93*2+75, 75*y-80*2+75,0))
    end
end

local function MorphUpMiho(inst, dofx)
	inst.components.container:SetNumSlots(#slotpos_4x4)
    inst.components.container.widgetslotpos = slotpos_4x4
    inst.components.container.widgetanimbank = "ui_miho_4x4"
    inst.components.container.widgetanimbuild = "ui_miho_4x4"
    inst.components.container.widgetpos = Vector3(0,140,0)
    inst.components.container.widgetpos_controller = Vector3(0,140,0)
    inst.components.container.side_align_tip = 160
	inst.components.locomotor.walkspeed = 6.8
	inst.components.locomotor.runspeed = 9

	inst.Transform:SetScale(1.2,1.2,1.2)
    inst.MihoState = "UP"
end

local function MorphNoMiho(inst, dofx)
	inst.Transform:SetScale(1,1,1)
    inst.MihoState = "NO"
end

local function CanMorph(inst)
    local clock = GetWorld().components.clock
    if not clock:IsNight() or clock:GetMoonPhase() ~= "full" or inst.MihoState ~= "NO" then
        return false, false
    end
    local container = inst.components.container
    local canUP = true
    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if not item then
            canUP = false
            break
        end
        if item.prefab ~= "cutgrass" then
            canUP = false
		else
        end
    end
    return canUP
end

local function MorphMiho(inst)
    local clock = GetWorld().components.clock
    if not clock:IsNight() or inst.MihoState ~= "NO" or clock:GetMoonPhase() ~= "full" then
        return
    end
    local container = inst.components.container
    local canUP = inst:CanMorph()
    if canUP then
        container:ConsumeByName("cutgrass", container:GetNumSlots())
        MorphUpMiho(inst, true)
    end
end

local function CheckForMorph(inst)
    local upmiho = inst:CanMorph()
    if upmiho then
        if inst.MorphTask then
            inst.MorphTask:Cancel()
            inst.MorphTask = nil
        end
        inst.MorphTask = inst:DoTaskInTime(2, function(inst)
            inst.sg:GoToState("transition")
        end)
    end
end

local function OnSave(inst, data)
    data.MihoState = inst.MihoState
end

local function OnPreLoad(inst, data)
    if not data then return end
    if data.MihoState == "UP" then
        MorphUpMiho(inst)
    end
end

local function fn()

    local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize( 1.3, .5 )
    inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("miho.tex")
	
    inst.AnimState:SetBank("fox_miho")
    inst.AnimState:SetBuild("fox_miho")
	inst.AnimState:PlayAnimation("idle_loop")
    
    inst:AddTag("companion")
    inst:AddTag("scarytoprey")
	inst:AddTag("noauradamage")
	inst:AddTag("notraptrigger")
	inst:AddTag("character")
	inst:AddTag("fox")
    inst:AddTag("miho")
	inst:AddTag("light")
	if IsDLCEnabled(CAPY_DLC) then
		MakeAmphibiousCharacterPhysics(inst, 75, .5)
	else
		MakeCharacterPhysics(inst, 75, .5)
		inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
		inst.Physics:ClearCollisionMask()
		inst.Physics:CollidesWith(COLLISION.WORLD)
		inst.Physics:CollidesWith(COLLISION.OBSTACLES)
		inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	end
    inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
	
    inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = 8
	inst.components.locomotor.runspeed = 10
	
    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)
	
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(100)
	inst.components.health:StartRegen(1, 1)
	inst.components.health.invincible = true
	inst.components.health.fire_damage_scale = 0

    inst:AddComponent("knownlocations")
	
    inst:AddComponent("container")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container:SetNumSlots(#slotpos_3x4)
    inst.components.container.widgetslotpos = slotpos_3x4
    inst.components.container.widgetanimbank = "ui_miho_3x4"
    inst.components.container.widgetanimbuild = "ui_miho_3x4"
    inst.components.container.widgetpos = Vector3(0,140,0)
    inst.components.container.widgetpos_controller = Vector3(0,140,0)
    inst.components.container.side_align_tip = 160

    local light = inst.entity:AddLight()
    inst.Light:Enable(true)
	inst.Light:SetRadius(1)
    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.35)
    inst.Light:SetColour(150/255,150/255, 0/255)
	
	inst.MihoState = "NO"
    inst.CanMorph = CanMorph
    inst.MorphMiho = MorphMiho
    inst:ListenForEvent("nighttime", function() CheckForMorph(inst) end, GetWorld())
    inst:ListenForEvent("onclose", function() CheckForMorph(inst) end)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

	inst:SetStateGraph("SGmiho_o")
	local brain = require "brains/mihobrain"
    inst:SetBrain(brain)
	
if IsDLCEnabled(REIGN_OF_GIANTS) or IsDLCEnabled(CAPY_DLC) then
	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0.3)
end
	
	inst:DoTaskInTime(1, function(inst)
        if not TheSim:FindFirstEntityWithTag("mihobell") then
            inst:Remove()
        end
    end)
    return inst
end

return Prefab( "common/miho", fn, assets, prefabs) 