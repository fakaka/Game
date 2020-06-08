local assets={
    Asset("ATLAS", "images/inventoryimages/mihobell.xml"),
    Asset("ANIM", "anim/mihobell.zip"),
}

local SPAWN_DIST = 30

local trace = function() end
--------------------------------------------------------------
local function RebuildTile(inst)
    if inst.components.inventoryitem:IsHeld() then
        local owner = inst.components.inventoryitem.owner
        inst.components.inventoryitem:RemoveFromOwner(true)
        if owner.components.container then
            owner.components.container:GiveItem(inst)
        elseif owner.components.inventory then
            owner.components.inventory:GiveItem(inst)
        end
    end
end
--------------------------------------------------------------
local function MorphUpBell(inst)
    inst.BellState = "UP"
    RebuildTile(inst)
	
    miho = miho or TheSim:FindFirstEntityWithTag("miho")
    if miho then
        if miho.components.follower.leader ~= inst then
            miho.components.follower:SetLeader(inst)
        end
	end
end
local function MorphNormalBell(inst)
    inst.BellState = "NOM"
    RebuildTile(inst)
end
--------------------------------------------------------------
local function GetSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = SPAWN_DIST
	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		return pt+offset
	end
end

local function SpawnMiho(inst)
    trace("mihobell - SpawnMiho")
    local pt = Vector3(inst.Transform:GetWorldPosition())
    trace("    near", pt)
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt then
        trace("    at", spawn_pt)
        local miho = SpawnPrefab("miho")
        if miho then
            miho.Physics:Teleport(spawn_pt:Get())
            miho:FacePoint(pt.x, pt.y, pt.z)
            return miho
        end
    else
        trace("mihobell - SpawnMiho: Couldn't find a suitable spawn point for miho")
    end
end

local function StopRespawn(inst)
    trace("mihobell - StopRespawn")
    if inst.respawntask then
        inst.respawntask:Cancel()
        inst.respawntask = nil
        inst.respawntime = nil
    end
end

local function RebindMiho(inst, miho)
    miho = miho or TheSim:FindFirstEntityWithTag("miho")
    if miho then
        inst.AnimState:PlayAnimation("idle", true)
        inst:ListenForEvent("death", function() inst:OnMihoDeath() end, miho)
        if miho.components.follower.leader ~= inst then
            miho.components.follower:SetLeader(inst)
        end
        return true
    end
end

local function RespawnMiho(inst)
    trace("mihobell - Respawnmiho")
    StopRespawn(inst)
    local miho = TheSim:FindFirstEntityWithTag("miho")
    if not miho then
        miho = SpawnMiho(inst)
    end
    RebindMiho(inst, miho)
end

local function StartRespawn(inst, time)
    StopRespawn(inst)
    local respawntime = time or 0
    if respawntime then
        inst.respawntask = inst:DoTaskInTime(respawntime, function() RespawnMiho(inst) end)
        inst.respawntime = GetTime() + respawntime
        inst.AnimState:PlayAnimation("dead", true)
    end
end

local function OnMihoDeath(inst)
    StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME)
end

local function FixMiho(inst)
	inst.fixtask = nil
	if not RebindMiho(inst) then
        inst.AnimState:PlayAnimation("dead", true)
        inst.components.inventoryitem:ChangeImageName(inst.closedEye)
		if inst.components.inventoryitem.owner then
			local time_remaining = 0
			local time = GetTime()
			if inst.respawntime and inst.respawntime > time then
				time_remaining = inst.respawntime - time		
			end
			StartRespawn(inst, time_remaining)
		end
	end
end

local function OnPutInInventory(inst)
	if not inst.fixtask then
		inst.fixtask = inst:DoTaskInTime(1, function() FixMiho(inst) end)	
	end
end

local function OnSave(inst, data)
    trace("mihobell - OnSave")
    data.BellState = inst.BellState
    local time = GetTime()
    if inst.respawntime and inst.respawntime > time then
        data.respawntimeremaining = inst.respawntime - time
    end
end

local function OnLoad(inst, data)
    if data and data.BellState then
        if data.BellState == "UP" then
            inst:MorphUpBell()
        end
    end
    if data and data.respawntimeremaining then
		inst.respawntime = data.respawntimeremaining + GetTime()
	end
end
local function GetStatus(inst)
    trace("smallbird - GetStatus")
    if inst.respawntask then
        return "WAITING"
    end
end


local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("mihobell.tex")
	
	inst.entity:AddSoundEmitter()

    inst:AddTag("mihobell")
    inst:AddTag("irreplaceable")
	inst:AddTag("nonpotatable")

    MakeInventoryPhysics(inst)
	
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize( 1, .5 )
    
    inst.AnimState:SetBank("mihobell")
    inst.AnimState:SetBuild("mihobell")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mihobell.xml"
	inst.BellState = "NOM"

	
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

    inst:AddComponent("leader")
    inst.MorphNormalBell = MorphNormalBell
    inst.MorphUpBell = MorphUpBell

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.OnMihoDeath = OnMihoDeath

	inst.fixtask = inst:DoTaskInTime(1, function() FixMiho(inst) end)

    return inst
end

STRINGS.NAMES.MIHOBELL = "Fox Bell"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MIHOBELL = {	
	"Mysterious Bells. Where is Miho?",
	"Come on, Miho! Come on!",
	"Cute bell sounds.",
}

return Prefab( "common/inventory/mihobell", fn, assets)