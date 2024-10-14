include("shared.lua")

net.Receive("GrapplePrimaryAttackHold", function()
    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "weapon_grapplehook" then
        weapon.PrimaryAttackHold = net.ReadBool()
    end
end)


function SWEP:DrawHUD()
    local maxDistance = self.MaxGrappleDistance
    local eyeTrace = self:GetOwner():GetEyeTrace()
    local distance = eyeTrace.HitPos:Distance(self:GetOwner():GetPos())
    local isFiring = self.PrimaryAttackHold

    -- Determine the corner position for the text
    local hudX = 50 -- Horizontal offset (adjust as needed)
    local hudY = ScrH() - 135 -- Vertical offset from bottom (adjust as needed)

    -- If primary fire is held down (grapple in use), display "Grapple in use"
    if isFiring then
        draw.SimpleText("Grapple in use", "Trebuchet24", hudX, hudY, Color(255, 165, 0), TEXT_ALIGN_LEFT)
    else
        -- Show "Grapple Ready" or "Out of Range" based on the distance
        if eyeTrace.Hit and distance <= maxDistance then
            draw.SimpleText("Grapple Ready", "Trebuchet24", hudX, hudY, Color(0, 255, 0), TEXT_ALIGN_LEFT)
        else
            draw.SimpleText("Out of Range", "Trebuchet24", hudX, hudY, Color(255, 0, 0), TEXT_ALIGN_LEFT)
        end
    end
end


