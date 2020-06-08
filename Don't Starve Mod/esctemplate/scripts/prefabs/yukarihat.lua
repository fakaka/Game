local assets=
{   
	Asset("ANIM", "anim/yukarihat.zip"),    
	Asset("ANIM", "anim/yukarihat_swap.zip"),    
	Asset("ATLAS", "images/inventoryimages/yukarihat.xml"),    
}

prefabs = {}

local function onequiphat(inst, owner)
	owner.AnimState:OverrideSymbol("swap_hat", "yukarihat_swap", "swap_hat")
	owner.AnimState:Show("HAT")
	owner.AnimState:Show("HAT_HAIR")
	owner.AnimState:Hide("HAIR_NOHAT")
	owner.AnimState:Hide("HAIR") 
end

local function onunequiphat(inst, owner)
	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR") 
end

local function fn()

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim  = inst.entity:AddAnimState()
	
	MakeInventoryPhysics(inst)
	if IsDLCEnabled(CAPY_DLC) then
		MakeInventoryFloatable(inst, "idle", "idle")
	end	
		
	anim:SetBuild("yukarihat")
	anim:SetBank("yukarihat")
	anim:PlayAnimation("idle")

	inst:AddComponent("inspectable")        
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "yukarihat"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/yukarihat.xml"
	
	inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("yukarihat.tex")
	
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip(onequiphat)
    inst.components.equippable:SetOnUnequip(onunequiphat)
	
	return inst
end
	
return Prefab("yukarihat", fn, assets, prefabs)