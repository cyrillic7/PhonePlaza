

local GameAnimation = class("GameAnimation", function()
	return display.newLayer()end) 


function  GameAnimation:ctor()
	-- body
	self:setTouchEnabled(false)
end

function GameAnimation:DoBombAni()
	--加载动画资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("errenland/ani/AnimationBomb.ExportJson")
	local ani = ccs.Armature:create("AnimationBomb")
	ani:addTo(self)
	ani:center()
	ani:getAnimation():play("Animation1",-1,0)
	ani:getAnimation():setMovementEventCallFunc(function (armature,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("errenland/ani/AnimationBomb.ExportJson")
			ani:removeFromParent()			
			display.removeSpriteFramesWithFile("errenland/ani/bomb.plist","errenland/ani/bomb.png")
		end
	end)
end

function GameAnimation:DoDoubleLine()
	--加载动画资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("errenland/ani/AnimationContinuousdouble.ExportJson")
	local ani = ccs.Armature:create("AnimationContinuousdouble")
	ani:addTo(self)
	ani:setPosition(display.cx+220,display.cy+170)
	ani:getAnimation():play("Animation1",-1,0)
	ani:getAnimation():setMovementEventCallFunc(function (armature,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("errenland/ani/AnimationContinuousdouble.ExportJson")
			ani:removeFromParent()
			display.removeSpriteFramesWithFile("errenland/ani/continuousdouble.plist","errenland/ani/continuousdouble.png")
		end
	end)
end

function GameAnimation:DoPlane()
	--加载动画资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("errenland/ani/AnimationPlane.ExportJson")
	local ani = ccs.Armature:create("AnimationPlane")
	ani:addTo(self)
	ani:setPosition(display.cx,display.cy+30)
	ani:getAnimation():play("Animation1",-1,0)
	ani:getAnimation():setMovementEventCallFunc(function (armature,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("errenland/ani/AnimationPlane.ExportJson")
			ani:removeFromParent()
			display.removeSpriteFramesWithFile("errenland/ani/plane.plist","errenland/ani/plane.png")

		end
	end)
end

function GameAnimation:DoRocket()
	--加载动画资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("errenland/ani/AnimationRocket.ExportJson")
	local ani = ccs.Armature:create("AnimationRocket")
	ani:addTo(self)
	ani:center()
	ani:getAnimation():play("Animation1",-1,0)
	ani:getAnimation():setMovementEventCallFunc(function (armature,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("errenland/ani/AnimationRocket.ExportJson")
			ani:removeFromParent()
			display.removeSpriteFramesWithFile("errenland/ani/rocket.plist","errenland/ani/rocket.png")
		end
	end)
end
function GameAnimation:DoSpring()
	--加载动画资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("errenland/ani/AnimationSpring.ExportJson")
	local ani = ccs.Armature:create("AnimationSpring")
	ani:addTo(self)
	ani:center()
	ani:getAnimation():play("Animation1",-1,0)
	ani:getAnimation():setMovementEventCallFunc(function (armature,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("errenland/ani/AnimationSpring.ExportJson")
			ani:removeFromParent()
			display.removeSpriteFramesWithFile("errenland/ani/spring.plist","errenland/ani/springs.png")
		end
	end)
end

function GameAnimation:DoCardLine()
	--加载动画资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("errenland/ani/AnimationStraight.ExportJson")
	local ani = ccs.Armature:create("AnimationStraight")
	ani:addTo(self)
	--ani:center()
	ani:setPosition(display.cx-270,display.cy+50)
	ani:getAnimation():play("Animation1",-1,0)
	ani:getAnimation():setMovementEventCallFunc(function (armature,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("errenland/ani/AnimationStraight.ExportJson")
			ani:removeFromParent()
			display.removeSpriteFramesWithFile("errenland/ani/straight.plist","errenland/ani/straight.png")
		end
	end)
end

return GameAnimation