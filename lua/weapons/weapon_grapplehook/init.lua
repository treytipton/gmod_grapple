AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

resource.AddFile("addons/basic_grapple/lua/weapons/weapon_grapplehook/init.lua")

function SWEP:Initialize()
    self:SetHoldType("crossbow")
    self.Rope = nil -- Track rope constraint to prevent multiple ropes and so we can clear it.
    self.HookEntity = nil -- Track hook entity as well.
end

function SWEP:PrimaryAttack()
    if SERVER and not self.Rope then
        local owner = self:GetOwner()
        local eyeTrace = owner:GetEyeTrace()    //!< Find where player is looking.

        if eyeTrace.Hit then
            local hookPos = eyeTrace.HitPos

            local distance = (hookPos - owner:GetPos()):Length()
            if distance > 2000 then return end-- Limit grapple hook hit range.
        
            local ropeLength = distance

            self.hookEntity = ents.Create("prop_physics")
            self.hookEntity:SetPos(hookPos)
            self.hookEntity:SetModel("models/props_junk/PopCan01a.mdl")
            self.hookEntity:SetNoDraw(true)
            self.hookEntity:Spawn()
            self.hookEntity:Activate()

            self.Rope = constraint.Rope(owner, hookEntity, 0, 0, Vector(0, 0), Vector(0, 0), ropeLength, 0, 0, 1, "cable/cable2", false)

            -- Pull player toward hook point.
            local phys = owner:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(hookPos - owner:GetPos():GetNormalized() * 3000) -- Pull the player toward the hook point
            end
        end
    end

-- TODO: Use this to let the player swing and not pull towards the hook point.
function SWEP:SecondaryAttack()

end
