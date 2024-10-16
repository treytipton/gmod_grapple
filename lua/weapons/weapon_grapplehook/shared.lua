SWEP.PrintName = "Grapple Hook"
SWEP.Author = "Trey"
SWEP.Instructions = "Left click to grapple to where you are aiming."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ClassName = "weapon_grapplehook"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/v_crossbow.mdl"
SWEP.WorldModel = "models/weapons/w_crossbow.mdl"

SWEP.MaxGrappleDistance = 2000
SWEP.PrimaryAttackHold = false

function SWEP:Initialize()
    self:SetHoldType("crossbow")
end

function SWEP:Deploy()
    return true
end
