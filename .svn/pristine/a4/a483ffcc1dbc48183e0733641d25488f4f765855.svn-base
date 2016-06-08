local GameFrameTopController = class("GameFrameTopController")

function GameFrameTopController:ctor(frameScene)
	self.frameScene = frameScene
end

function GameFrameTopController:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.Ctrl_UpdateUserInfo] = handler(self, self.receiveUpdateUserInfoMessage)
    eventListeners[appBase.Message.LP_LoginSuccess] = handler(self, self.receiveUpdateUserInfoMessage)
    eventListeners[appBase.Message.Ctrl_HasFinishedTask] = handler(self, self.receiveHasFinishedTaskMessage)

    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function GameFrameTopController:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function GameFrameTopController:receiveUpdateUserInfoMessage(event)
    self:updateUserInfo()
end

function GameFrameTopController:receiveHasFinishedTaskMessage(event)
    dump(event.para)
    if self.frameScene.imgTaskTip then
    	self.frameScene.imgTaskTip:setVisible(event.para.bShow)
    end
end

function GameFrameTopController:updateUserInfo()
	if self.frameScene ~= nil then
		-- 头像
		if self.frameScene.imgUserFace ~= nil then
			local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
			local frame = sharedSpriteFrameCache:getSpriteFrame("pic/face/"..GlobalUserInfo.wFaceID..".png")
		    if frame then
				self.frameScene.imgUserFace:setSpriteFrame(frame)
			end
		end
		-- 级别
		if self.frameScene.labelExpLevel ~= nil then
			local lv,percent = self:getUserLevel(GlobalUserInfo.dwExperience)
			self.frameScene.labelExpLevel:setString(lv)
			local imgLvProgress = self.frameScene.imgLvProgress
			if imgLvProgress then
				while true do
					local newWidth = imgLvProgress.maxWidth*percent
					if newWidth >= 1 and newWidth < 20  then
						newWidth = 20
					elseif newWidth < 1 then
						imgLvProgress:setVisible(false)
						break
					end
					imgLvProgress:setVisible(true)
					imgLvProgress:setContentSize(newWidth,imgLvProgress.height)
					break
				end				
			end
		end
		-- vip
		if self.frameScene.imgVipLevel ~= nil then
			self.frameScene.imgVipLevel:setSpriteFrame("pic/plazacenter/Sundry/u_icon_vip"..GlobalUserInfo.cbMemberOrder..".png")
		end
		-- 昵称
		if self.frameScene.labelNickName ~= nil then
			print("labelNickName ", GlobalUserInfo.szNickName)
			self.frameScene.labelNickName:setString(GlobalUserInfo.szNickName)
		end

		local changeNumberAction = function (labelCtrl,beginNumber,endNumber)
			if labelCtrl then
				local addOrSubScore = math.round((endNumber-beginNumber)/5)
				local sequence = transition.sequence({
					cc.DelayTime:create(0.06),
				    cc.CallFunc:create(function ()
				    	labelCtrl:setString(tostring(beginNumber+addOrSubScore*1))
				    end),
					cc.DelayTime:create(0.06),
				    cc.CallFunc:create(function ()
				    	labelCtrl:setString(tostring(beginNumber+addOrSubScore*2))
				    end),
					cc.DelayTime:create(0.06),
				    cc.CallFunc:create(function ()
				    	labelCtrl:setString(tostring(beginNumber+addOrSubScore*3))
				    end),
					cc.DelayTime:create(0.06),
				    cc.CallFunc:create(function ()
				    	labelCtrl:setString(tostring(beginNumber+addOrSubScore*4))
				    end),
					cc.DelayTime:create(0.06),
				    cc.CallFunc:create(function ()
				    	labelCtrl:setString(tostring(endNumber))
				    end),
				})
				labelCtrl:runAction(sequence)
			end
		end
		-- 元宝
		if self.frameScene.labelIngot ~= nil then
			print("labelIngot ", GlobalUserInfo.lIngotScore)
			local preScore = tonumber(self.frameScene.labelIngot:getString())
			changeNumberAction(self.frameScene.labelIngot,preScore,GlobalUserInfo.lIngotScore)
		end
		-- 金币
		if self.frameScene.labelCoin ~= nil then
			print("labelCoin ", GlobalUserInfo.lUserScore)
			local preScore = tonumber(self.frameScene.labelCoin:getString())
			changeNumberAction(self.frameScene.labelCoin,preScore,GlobalUserInfo.lUserScore)
		end
		-- 银行self.labelBank
		if self.frameScene.labelBank ~= nil then
			print("labelBank ", GlobalUserInfo.lUserInsure)
			local preScore = tonumber(self.frameScene.labelBank:getString())
			changeNumberAction(self.frameScene.labelBank,preScore,GlobalUserInfo.lUserInsure)
		end
	end
end

function GameFrameTopController:getUserLevel(experience)
	local levelExperGroup={
		0,
		500,1500,3500,6500,11500,
		17500,24500,34500,45500,57500,
		68000,98000,138000,188000,248000,
		318000,428000,578000,768000,998000,
		1298000,1648000,2048000,2498000,2998000,
		3798000,4898000,6298000,7998000,9998000,
		12998000,16498000,19998000,23998000,29998000,
		39998000,54998000,69998000,84998000,99998000,
		129998000,179998000,249998000,349998000,499998000
	}

	for i,v in ipairs(levelExperGroup) do
		if experience < v then
			return i-2,(experience-levelExperGroup[i-1])/(v-levelExperGroup[i-1])
		end
	end
	
	return (#levelExperGroup-1),0
end

function GameFrameTopController:onTouchImgUserFace(imgUserFace)
	if imgUserFace then
		imgUserFace:setTouchEnabled(true)
		imgUserFace:addNodeEventListener(cc.NODE_TOUCH_EVENT,function (event)
		    if "began" == event.name then
			    --content:scaleTo(0.1,0.9)
		    elseif "ended" == event.name then
		    	if  AppBaseInstanse.PLAZACENTER_APP:getLastPopWidgetType() == "PersonalCenterWidget" then
					return
				end
				
			    self.frameScene:setMainFrameVisible(false) 
			    AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(require("plazacenter.widgets.PersonalCenterWidget").new(self.frameScene,function ()
			    	self.frameScene:setMainFrameVisible(true)
			    	AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(nil)
			    end) )
		    end
		    return true
    	end)
	end
end

function GameFrameTopController:onTouchImgVipLevel(imgVipLevel)
	if imgVipLevel then
		imgVipLevel:setTouchEnabled(true)
		imgVipLevel:addNodeEventListener(cc.NODE_TOUCH_EVENT,function (event)
		    if "began" == event.name then
			    imgVipLevel:scaleTo(0,imgVipLevel:getScale()*0.9)
		    elseif "ended" == event.name then
		    	imgVipLevel:scaleTo(0,imgVipLevel:getScale()/0.9)
		    	if  AppBaseInstanse.PLAZACENTER_APP:getLastPopWidgetType() == "VipCenterWidget" then
					return
				end
				
			    self.frameScene:setMainFrameVisible(false) 
			    AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(require("plazacenter.widgets.VipCenterWidget").new(self.frameScene,function ()
			    	self.frameScene:setMainFrameVisible(true)
			    	AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(nil)
			    end) )
		    end
		    return true
    	end)
	end
end

function GameFrameTopController:onAddGoldButtonClicked()
	if  AppBaseInstanse.PLAZACENTER_APP:getLastPopWidgetType() == "HallTopupWidget" then
		local lastWidget = AppBaseInstanse.PLAZACENTER_APP:getLastPopWidget()
		if lastWidget and lastWidget.setSelectedID then
			lastWidget:setSelectedID(0)
		end
        return
    end
    self.frameScene:setMainFrameVisible(false) 
    AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(
        require("plazacenter.widgets.HallTopupWidget").new(self.frameScene,function ()
        self.frameScene:setMainFrameVisible(true)
        AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(nil)
    end,0) )
end

function GameFrameTopController:onAddWingButtonClicked()
	if  AppBaseInstanse.PLAZACENTER_APP:getLastPopWidgetType() == "HallTopupWidget" then
		local lastWidget = AppBaseInstanse.PLAZACENTER_APP:getLastPopWidget()
		if lastWidget and lastWidget.setSelectedID then
			lastWidget:setSelectedID(1)
		end
        return
    end
    self.frameScene:setMainFrameVisible(false) 
    AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(
        require("plazacenter.widgets.HallTopupWidget").new(self.frameScene,function ()
        self.frameScene:setMainFrameVisible(true)
        AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(nil)
    end,1) )
end

function GameFrameTopController:onTaskButtonClicked()
	if  AppBaseInstanse.PLAZACENTER_APP:getLastPopWidgetType() == "HallTaskWidget" then
		return
	end
	self.frameScene:setMainFrameVisible(false)
    AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(require("plazacenter.widgets.HallTaskWidget").new(self.frameScene,function ()
    	self.frameScene:setMainFrameVisible(true)
    	AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(nil)
    end) )

    if self.frameScene.imgTaskTip then
    	self.frameScene.imgTaskTip:setVisible(false)
    end
end

function GameFrameTopController:onMsgButtonClicked()
	local dataMsgBox = {
        nodeParent=self.frameScene,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo="该功能暂未实现，敬请期待！"
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function GameFrameTopController:onSettingButtonClicked()
	if  AppBaseInstanse.PLAZACENTER_APP:getLastPopWidgetType() == "HallSetWidget" then
		return
	end
	self.frameScene:setMainFrameVisible(false)
    AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(require("plazacenter.widgets.HallSetWidget").new(self.frameScene,function ()
    	self.frameScene:setMainFrameVisible(true)
    	AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(nil)
    end) )
end

function GameFrameTopController:onNoticeButtonClicked()
	if device.platform == "android" then
        local params = {"http://ggapp.719you.com/",
            function (...)
                dump(...)
            end}
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "openWebview", params, "(Ljava/lang/String;I)V")
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("LuaCallObjcFuncs", "openWebview", 
            {url="http://ggapp.719you.com/"})

    end
end

return GameFrameTopController