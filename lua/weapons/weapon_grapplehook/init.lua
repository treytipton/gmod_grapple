AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function SWEP:Initialize()
    self:SetHoldType("crossbow")
end

function SWEP:PrimaryAttack()
    if SERVER then
        local owner = self:GetOwner()
        local eyeTrace = owner:GetEyeTrace()    //!< Find where player is looking.

        if eyeTrace.Hit then
            local hookPos = eyeTrace.HisPos

            local distance = (hookPos - owner:GetPos()):Length()
            if distance > 2000 then return end-- Limit grapple hook hit range.
        
            local phys = owner:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(hookPos - owner:getPos():GetNormalized() * 300) -- Pull the player toward the hook point
            end
        end
    end

-- TODO: Use this to let the player swing and not pull towards the hook point.
function SWEP:SecondaryAttack()

end