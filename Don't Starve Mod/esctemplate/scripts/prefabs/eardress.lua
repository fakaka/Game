local assets=
{
	Asset("ANIM", "anim/eardress.zip"),
	Asset("IMAGE", "images/inventoryimages/eardress.tex"),
	Asset("ATLAS", "images/inventoryimages/eardress.xml"),
}
local prefabs = {}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "eardress", "swap_body")
	owner.components.inventory:SetOverflow(inst)
    inst.components.fueled:StartConsuming()
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
	owner.components.inventory:SetOverflow(nil)
    inst.components.fueled:StopConsuming()
    inst.components.container:Close(owner)
end

local slotpos = {}

for y = 0, 2 do
    table.insert(slotpos, Vector3(-162, (1 - y) * 75,0))
	table.insert(slotpos, Vector3(-162 + 75, (1 - y) * 75,0))
end

local function onfinish(inst)
	inst.components.container:DropEverything()
    inst.components.container:Close()
	inst:Remove()
end


local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("krampus_sack.png")
    
    inst.AnimState:SetBuild("eardress")
    inst.AnimState:SetBank("torso_rain")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddTag("fridge")
    inst:AddTag("lowcool")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/eardress.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.insulated = true
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(4800)
	inst.components.fueled:SetDepletedFn(onfinish)

	
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_icepack_2x3"
    inst.components.container.widgetanimbuild = "ui_icepack_2x3"
    inst.components.container.widgetpos = Vector3(-5,-70,0)
    inst.components.container.side_widget = true
    inst.components.container.type = "pack"
    
    return inst
end

return Prefab( "common/inventory/eardress", fn, assets , prefabs) 
