AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

resource.AddFile("addons/basic_grapple/lua/weapons/weapon_grapplehook/init.lua")

util.AddNetworkString("GrapplePrimaryAttackHold")

function SWEP:Initialize()
    self:SetHoldType("crossbow")
    self.Rope = nil
    self.hookEntity = nil
    self.PrimaryAttackHold = false
end

function SWEP:PrimaryAttack()
    if SERVER and not self.PrimaryAttackHold then
        local owner = self:GetOwner()
        local eyeTrace = owner:GetEyeTrace() -- Find where player is looking.
        local maxDistance = self.MaxGrappleDistance

        if eyeTrace.Hit then
            local hookPos = eyeTrace.HitPos
            local distance = (hookPos - owner:GetPos()):Length()

            if distance > maxDistance then -- TODO: Rope to max range and then retract it back to player.
                self:RemoveRope()
                return -- Out of range, reset fields.
            end 

            local ropeLength = distance
            self:SetPrimaryAttackHold(true)
            
            -- Create hook entity only if it doesn't exist
            if not IsValid(self.hookEntity) then
                self.hookEntity = ents.Create("prop_physics")
                self.hookEntity:SetPos(hookPos)
                self.hookEntity:SetModel("models/props_junk/PopCan01a.mdl")
                self.hookEntity:SetNoDraw(true)
                self.hookEntity:Spawn()
                self.hookEntity:Activate()

                -- Freeze the hook entity in place
                local phys = self.hookEntity:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(false)
                end
            end

            -- Create rope constraint
            if not IsValid(self.Rope) then
                self.Rope = constraint.Rope(owner, self.hookEntity, 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), ropeLength, 0, 0, 1, "cable/cable2", false)
            end

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

            -- Detect when player releases primary fire
            hook.Add("PlayerButtonUp", "GrappleRelease" .. self:EntIndex(), function(ply, releasedButton)
                if ply == weapon:GetOwner() and releasedButton == MOUSE_LEFT then
                    weapon:OnPrimaryFireReleased()
                end
            end)
        end
    end
end

function SWEP:SecondaryAttack()
    if(self.PrimaryAttackHold == true) then return end  //!< Already using primary fire, don't do anything.
    self:RemoveRope()
end

function SWEP:SetPrimaryAttackHold(state)
    self.PrimaryAttackHold = state

    -- Send the state to the client
    net.Start("GrapplePrimaryAttackHold")
    net.WriteBool(state)
    net.Send(self:GetOwner())
end


function SWEP:OnPrimaryFireReleased()
    self:RemoveRope() -- Properly remove the rope and hook
    self:SetPrimaryAttackHold(false)
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
