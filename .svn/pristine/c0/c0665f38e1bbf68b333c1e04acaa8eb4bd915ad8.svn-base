local CompanyLogoScene = class("CompanyLogoScene", function()
    return display.newScene("CompanyLogoScene")
end)

function CompanyLogoScene:ctor()        
end

function CompanyLogoScene:onEnter()
    cc.LayerColor:create(cc.c4b(255,255,255,255))
            :addTo(self)
    -- add logo animation
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo(ANIMATION_COMPANY_LOGO_CSB_FILE)
    self.armature = ccs.Armature:create("AnimationCompanyLogo")
    self.armature:align(display.CENTER, display.cx-220, display.cy+30)
    self:addChild(self.armature)
    self.armature:getAnimation():setMovementEventCallFunc(function(armature,movementType,movementID)
        if movementType == ccs.MovementEventType.complete then
            --AppBaseInstanse.PLAZACENTER_APP:enterScene("LoginScene","","crossFade",0.2)
            AppBaseInstanse.PLAZACENTER_APP:enterScene("LoginScene","","fade", 1, cc.c3b(255, 255, 255))
            --local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
            --scheduler.performWithDelayGlobal(function ()
            --    AppBaseInstanse.PLAZACENTER_APP:enterScene("LoginScene")
            --end, 1)
        end
    end)
    self.armature:getAnimation():play("Animation1")
end

function CompanyLogoScene:onExit()
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo(ANIMATION_COMPANY_LOGO_CSB_FILE)
end

return CompanyLogoScene
