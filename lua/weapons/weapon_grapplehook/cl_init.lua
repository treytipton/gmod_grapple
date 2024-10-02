include("shared.lua")

function SWEP:DrawHUD()
    local eyeTrace = self:GetOwner():GetEyeTrace()
    local hookPos = eyeTrace.HitPos

    if eyeTrace.Hit then
        surface.SetDrawColor(255, 0, 0, 255)
        surface.DrawLine(ScrW() / 2, ScrW() / 2, hookPos.x, hookPos.y)
    end
end