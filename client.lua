local BONES = {
	--[[SKEL_R_Hand]][57005] = true,
	--[[SKEL_R_Finger00]][58866] = true,
	--[[SKEL_R_Finger01]][64016] = true,
	--[[SKEL_R_Finger02]][64017] = true,
	--[[SKEL_R_Finger10]][58867] = true,
	--[[SKEL_R_Finger11]][64096] = true,
	--[[SKEL_R_Finger12]][64097] = true,
	--[[SKEL_R_Finger20]][58868] = true,
	--[[SKEL_R_Finger21]][64112] = true,
	--[[SKEL_R_Finger22]][64113] = true,
	--[[SKEL_R_Finger30]][58869] = true,
	--[[SKEL_R_Finger31]][64064] = true,
	--[[SKEL_R_Finger32]][64065] = true,
	--[[SKEL_R_Finger40]][58870] = true,
	--[[SKEL_R_Finger41]][64080] = true,
	--[[SKEL_R_Finger42]][64081] = true,
	--[[PH_R_Hand]][28422] = true,
	--[[IK_R_Hand]][6286] = true
}

function Bool (num) return num == 1 or num == true end

-- WEAPON DROP OFFSETS
local function GetDisarmOffsetsForPed (ped)
	local v

	if IsPedWalking(ped) then v = { 0.6, 4.7, -0.1 }
	elseif IsPedSprinting(ped) then v = { 0.6, 5.7, -0.1 }
	elseif IsPedRunning(ped) then v = { 0.6, 4.7, -0.1 }
	else v = { 0.4, 4.7, -0.1 } end

	return v
end

function Disarm (ped)
	if IsEntityDead(ped) then return false end

	local boneCoords
	local hit, bone = GetPedLastDamageBone(ped)

	hit = Bool(hit)

	if hit and IsPedArmed(ped, 7) then
		if BONES[bone] then
			weapon = GetSelectedPedWeapon(ped)

			boneCoords = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(ped, bone))

			PlayAmbientSpeech2(ped, "GENERIC_CURSE_MED", "SPEECH_PARAMS_FORCE")

			StopPedWeaponFiringWhenDropped(ped)

			SetPedDropsInventoryWeapon(
			ped,
			weapon,
			table.unpack(GetDisarmOffsetsForPed(ped)),
			GetAmmoInClip(ped, weapon)
		)

			SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), false)

			return true
		end
	end

	return false
end

-- PLAYER CAN BE DISARMED
Citizen.CreateThread(function ()
	local ped

	while true do
		ped = PlayerPedId()

		if Disarm(ped) then
			-- player disarmed
		end

		Wait(0)
	end
end)

-- PEDS CAN BE DISARMED
Citizen.CreateThread(function ()
	local targeted, entity
	local playerPed

	while true do
		playerPed = PlayerPedId()
		targeted, entity = GetEntityPlayerIsFreeAimingAt(GetPlayerIndex(), 0)

		if targeted and HasEntityBeenDamagedByEntity(entity, playerPed, 1) and Disarm(entity) then
			-- ped disarmed
		end

		Wait(0)
	end
end)
