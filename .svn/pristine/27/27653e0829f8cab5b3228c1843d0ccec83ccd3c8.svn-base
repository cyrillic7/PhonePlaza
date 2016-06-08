--
-- Author: Your Name
-- Date: 2015-11-03 11:44:09
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local UserInfoWidget = class("UserInfoWidget", XWWidgetBase)

UserInfoWidget.LIST_TYPE = 1
UserInfoWidget.TABLE_TYPE = 2
UserInfoWidget.NICK_MAX_LEN = 6*3

function UserInfoWidget:ctor(parentNode,userInfoType,userInfo)
	UserInfoWidget.super.ctor(self)

	self.userInfo = userInfo
	self.userInfoType = userInfoType

	self:addTo(parentNode)
end
function UserInfoWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	UserInfoWidget.super.onEnter(self)

	local csbFilePath = WIDGET_USERINFO_LIST_CSB_FILE
	if self.userInfoType == self.TABLE_TYPE then
		csbFilePath = WIDGET_USERINFO_TABLE_CSB_FILE
	end
    local node, width, height = cc.uiloader:load(csbFilePath)
    if not node then
        return
    end

     local baseNode = ccui.Widget:create()
    baseNode:addChild(node)
    baseNode:setTouchEnabled(true)
    baseNode:setSwallowTouches(false)
    baseNode:setContentSize(display.width,display.height)
    baseNode:setPosition(display.cx,display.cy)
    baseNode:addTouchEventListener(function (sender,eventType)
    	if eventType == 0 then
            self:showUserInfo(false)
        end
    end)

    self.bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    self.imgGender = cc.uiloader:seekNodeByName(node, "Image_Gender")
    self.labelNick = cc.uiloader:seekNodeByName(node, "Label_Nick")
    self.imgVip = cc.uiloader:seekNodeByName(node, "Image_Vip")
    self.labelVipLv = cc.uiloader:seekNodeByName(node, "AtlasLabel_VipLv")
    self.labelGold = cc.uiloader:seekNodeByName(node, "Label_Gold")
    self.labelExpLv = cc.uiloader:seekNodeByName(node, "AtlasLabel_ExpLv")

    self.labelUserID = cc.uiloader:seekNodeByName(node, "Label_UserID")
    self.labelUnderWrite = cc.uiloader:seekNodeByName(node, "Label_UnderWrite")
    local copyIDBtn = cc.uiloader:seekNodeByName(node, "Button_CopyID")
    if copyIDBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(copyIDBtn)
    	copyIDBtn:onButtonClicked(function ()
    		self:showUserInfo(false)
    		if self.userInfo then
    			if device.platform == "android" then
		            luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "copyTextToClipboard", 
    				{tostring(self.userInfo.dwGameID)}, "(Ljava/lang/String;)V")
		        elseif device.platform == "ios" then
		            luaoc.callStaticMethod("LuaCallObjcFuncs", "copyTextToClipboard",{text=tostring(self.userInfo.dwGameID)})
		        end
    		end
    	end)
    	G_uiWidgetVirtualBtn(copyIDBtn,cc.size(73,32))
    end
    self:addChild(baseNode)

    self:updateUserInfo(self.userInfo)
    --G_ShowNodeWithBackout(bgnode)
end

function UserInfoWidget:updateUserInfo(userInfo,positionX,positionY)
	self.userInfo = userInfo
	-- 调整位置
	if self.bgnode then
		local bgSize = self.bgnode:getContentSize()
		if positionX then
			if positionX+(bgSize.width+5) > display.width then
				positionX = display.width-(bgSize.width+5)
			end
			self.bgnode:setPositionX(positionX)
		end
		if positionY then
			if positionY<(bgSize.height+5) then
				positionY = bgSize.height+5
			end
			self.bgnode:setPositionY(positionY)
		end
	end
	if not userInfo then
		return
	end
	-- 设置数据
	if self.imgGender then
		if userInfo.cbGender ~= GENDER_FEMALE then
			self.imgGender:setSpriteFrame("pic/plazacenter/Sundry/u_per_icon_nan.png")
		else
			self.imgGender:setSpriteFrame("pic/plazacenter/Sundry/u_per_icon_nv.png")
		end
	end
	if self.labelNick then
		self.labelNick:setString(G_TruncationString(userInfo.szNickName,self.NICK_MAX_LEN))
	end
	if self.imgVip then
		if userInfo.cbMemberOrder > 0 then
			self.imgVip:setSpriteFrame("pic/plazacenter/TableFrame/u_text_vip.png")
		else
			self.imgVip:setSpriteFrame("pic/plazacenter/TableFrame/u_text_vip2.png")
		end
	end
	if self.labelVipLv then
		self.labelVipLv:setString(tostring(userInfo.cbMemberOrder))
	end
	if self.labelGold then
		self.labelGold:setString(tostring(userInfo.lScore))
	end
	if self.labelExpLv then
		local level,leftExp,percent = G_GetUserLevel(userInfo.dwExperience)
		self.labelExpLv:setString(tostring(level))
	end
	if self.labelUserID then
		self.labelUserID:setString(tostring(userInfo.dwGameID))
	end
	if self.labelUnderWrite then
		local strUnderWrite = userInfo.szUnderWrite or ""
		self.labelUnderWrite:setString("签名:"..strUnderWrite)
	end
end

function UserInfoWidget:showUserInfo(bShow)
	local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	if bShow then
		self:setVisible(true)

		if self.scripthandle then
			scheduler.unscheduleGlobal(self.scripthandle)
		end
		self.scripthandle = scheduler.performWithDelayGlobal(function ()
				self:setVisible(false)
                self.scripthandle = nil
            end, 5)
	else
		self:setVisible(false)

		if self.scripthandle then
			scheduler.unscheduleGlobal(self.scripthandle)
			self.scripthandle = nil
		end
	end
end
return UserInfoWidget