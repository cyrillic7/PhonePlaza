local GameAnimation = class("GameAnimation", function()
	return display.newLayer()end) 

function  GameAnimation:ctor()
	-- body
	self:setTouchEnabled(false)
end

function GameAnimation:DoAllinAni()
	--加载动画资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("showhandanex/animation/AnimationAllin.ExportJson")
	local ani = ccs.Armature:create("AnimationAllin")
	ani:addTo(self)
	ani:center()
	local posy = ani:getPositionY()
	ani:setPositionY(posy-50)
	ani:getAnimation():play("Animation1",-1,0)
	ani:getAnimation():setMovementEventCallFunc(function (armature,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("showhandanex/animation/AnimationAllin.ExportJson")
			ani:removeFromParent()			
			display.removeSpriteFramesWithFile("showhandanex/animation/AnimationAllin0.plist","showhandanex/animation/AnimationAllin0.png")
		end
	end)
end



return GameAnimation