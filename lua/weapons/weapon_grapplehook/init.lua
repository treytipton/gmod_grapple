AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

resource.AddFile("addons/basic_grapple/lua/weapons/weapon_grapplehook/init.lua")

function SWEP:Initialize()
    self:SetHoldType("crossbow")
    self.Rope = nil -- Track rope constraint to prevent multiple ropes and so we can clear it.
    self.hookEntity = nil -- Track hook entity as well.
    self.PrimaryAttackHold = false
end

function SWEP:PrimaryAttack()
    if SERVER and not self.PrimaryAttackHold then
        local owner = self:GetOwner()
        local eyeTrace = owner:GetEyeTrace() -- Find where player is looking.
        self.PrimaryAttackHold = true

        if eyeTrace.Hit then
            local hookPos = eyeTrace.HitPos
            local distance = (hookPos - owner:GetPos()):Length()

            if distance > 2000 then return end -- Limit grapple hook hit range.
        
            local ropeLength = distance

            -- Create hook entity only if it doesn't exist
            if not IsValid(self.hookEntity) then
                self.hookEntity = ents.Create("prop_physics")
                self.hookEntity:SetPos(hookPos)
                self.hookEntity:SetModel("models/props_junk/PopCan01a.mdl")
                self.hookEntity:SetNoDraw(false)
                self.hookEntity:Spawn()
                self.hookEntity:Activate()

                -- Freeze the hook entity in place so it doesn't move
                local phys = self.hookEntity:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(false) -- This will freeze the hook entity
                end
            end

            -- Create rope constraint only if it doesn't exist
            if not IsValid(self.Rope) then
                self.Rope = constraint.Rope(owner, self.hookEntity, 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), ropeLength, 0, 0, 1, "cable/cable2", false)
            end

            -- Hook for applying constant force to the player
            local weapon = self
            hook.Add("Tick", "GrapplePull" .. self:EntIndex(), function()
                if weapon.PrimaryAttackHold and IsValid(weapon.hookEntity) then
                    local direction = (hookPos - owner:GetPos()):GetNormalized()
                    local phys = owner:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:SetVelocity(direction * 1000) -- Pull the player toward the hook point
                    end
                end
            end)

            -- Remove rope and hook entity after releasing primary fire
            hook.Add("PlayerButtonUp", "GrappleRelease" .. self:EntIndex(), function(ply, releasedButton)
                if ply == weapon:GetOwner() and releasedButton == MOUSE_LEFT then
                    weapon:OnPrimaryFireReleased()
                end
            end)
        end
    end
end

-- Secondary attack function can be added later.
function SWEP:SecondaryAttack()
    self:RemoveRope() -- Properly use self here with a colon
end

function SWEP:OnPrimaryFireReleased()
    self:RemoveRope() -- Properly remove the rope and hook
end

function SWEP:RemoveRope()
    self.PrimaryAttackHold = false

    -- Remove the rope constraint if valid
    if IsValid(self.Rope) then
        self.Rope:Remove()
        self.Rope = nil
    end

    -- Remove the hook entity if valid
    if IsValid(self.hookEntity) then
        self.hookEntity:Remove()
        self.hookEntity = nil
    end

    -- Remove hooks after player has released primary fire
    hook.Remove("PlayerButtonUp", "GrappleRelease" .. self:EntIndex())
    hook.Remove("Tick", "GrapplePull" .. self:EntIndex()) -- Remove the pulling force when fire is released
end
