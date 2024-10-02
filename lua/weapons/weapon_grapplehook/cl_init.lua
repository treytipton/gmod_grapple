include("shared.lua")

function SWEP:DrawHUD()
    local eyeTrace = self:GetOwner():GetEyeTrace()
    local hookPos = tr.HitPos

    if eyeTrace.Hit then
        surface.SetDrawColor(255, 0, 0, 255)
        surface.DrawLine(SrcW() / 2, SrcW() / 2, hookPos.x, hookPos.y)
    end
end