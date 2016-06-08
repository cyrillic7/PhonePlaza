--
-- Author: Your Name
-- Date: 2015-10-26 17:29:17
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local HallSetWidget = class("HallSetWidget", XWWidgetBase)

function HallSetWidget:ctor(parentNode,callBack)
	HallSetWidget.super.ctor(self)

	self.callBack = callBack
    self.widgetType = "HallSetWidget"

	self:addTo(parentNode)
end

function HallSetWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	HallSetWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_HALL_SET_CSB_FILE)
    if not node then
        return
    end

    node:setTouchEnabled(false)

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Close")
    local modifyPwdBtn = cc.uiloader:seekNodeByName(node, "Button_ModifyPwd")
    local changeAcountBtn = cc.uiloader:seekNodeByName(node, "Button_ChangeAcount")
    local feedBackBtn = cc.uiloader:seekNodeByName(node, "Button_FeedBack")
    local aboutBtn = cc.uiloader:seekNodeByName(node, "Button_About")
    local changeSkinBtn = cc.uiloader:seekNodeByName(node, "Button_ChangeSkin")

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgFace = cc.uiloader:seekNodeByName(node, "Image_Face")
    local labelNick = cc.uiloader:seekNodeByName(node, "Label_Nick")
    self.imgSkinBg = cc.uiloader:seekNodeByName(node, "Image_SkinBg")
    local checkMusicBg = cc.uiloader:seekNodeByName(node, "CheckBox_Music")
    local checkSoundBg = cc.uiloader:seekNodeByName(node, "CheckBox_Sound")
    if checkMusicBg then
        checkMusicBg:setButtonSelected(SessionManager:sharedManager():getMusicOn())
    	checkMusicBg:setButtonImage(checkMusicBg.ON, "#pic/plazacenter/Set/u_set_btn_on.png", true)
    	checkMusicBg:setButtonImage(checkMusicBg.ON_PRESSED, "#pic/plazacenter/Set/u_set_btn_off.png", true)
    	checkMusicBg:onButtonStateChanged(function (event)
    		if event.state == "on" then
    			SessionManager:sharedManager():setMusicOn(true)
                SessionManager:sharedManager():flush()
    		elseif event.state == "off" then
                SessionManager:sharedManager():setMusicOn(false)
                SessionManager:sharedManager():flush()
    		end
    	end)
    end
    if checkSoundBg then
        checkSoundBg:setButtonSelected(SessionManager:sharedManager():getEffectOn())
    	checkSoundBg:setButtonImage(checkSoundBg.ON, "#pic/plazacenter/Set/u_set_btn_on.png", true)
    	checkSoundBg:setButtonImage(checkSoundBg.ON_PRESSED, "#pic/plazacenter/Set/u_set_btn_off.png", true)
    	checkSoundBg:onButtonStateChanged(function (event)
    		if event.state == "on" then
    			SessionManager:sharedManager():setEffectOn(true)
                SessionManager:sharedManager():flush()
    		elseif event.state == "off" then
    			SessionManager:sharedManager():setEffectOn(false)
                SessionManager:sharedManager():flush()
    		end
    	end)
    end

    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
    		self.callBack()
    		self:removeFromParent()
    	end)
    	
    end

    if modifyPwdBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(modifyPwdBtn)
        modifyPwdBtn:onButtonClicked(function ()
            self:onModifyPwdBtnClicked()
        end)
    end

    if changeAcountBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(changeAcountBtn)
        changeAcountBtn:onButtonClicked(function ()
            self:onChangeAcountBtnClicked()
        end)
    end

    if feedBackBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(feedBackBtn)
        feedBackBtn:onButtonClicked(function ()
            self:onFeedBackBtnClicked()
        end)
    end

    if aboutBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(aboutBtn)
        aboutBtn:onButtonClicked(function ()
            self:onAboutBtnClicked()
        end)
    end

    if changeSkinBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(changeSkinBtn)
        changeSkinBtn:onButtonClicked(function ()
            self:onChangeSkinBtnClicked()
        end)
    end

    if imgFace then
        imgFace:setSpriteFrame("pic/face/"..GlobalUserInfo.wFaceID..".png")
    end
    if labelNick then
        labelNick:setString(GlobalUserInfo.szNickName)
    end
    if self.imgSkinBg then
        self:setSkinBgImg("pic/plazacenter/u_bg"..SessionManager:sharedManager():getSkinID()..".png")
    end

    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function HallSetWidget:onExit()
	HallSetWidget.super.onExit(self)
end

function HallSetWidget:cleanPlistRes()
	print("HallSetWidget:cleanPlistRes")
    display.removeSpriteFramesWithFile("UIHallSet.plist", "UIHallSet.png")
end

function HallSetWidget:setSkinBgImg(skinBgImg)
    if not self.imgSkinBg then
        return
    end
    if not self.imgSkinBg.orgSize then
        self.imgSkinBg.orgSize = self.imgSkinBg:getContentSize()
    end
    
    self.imgSkinBg:setTexture(skinBgImg)

    local newSize = self.imgSkinBg:getContentSize()
    local imgSize = self.imgSkinBg.orgSize
    self.imgSkinBg:setScaleX(imgSize.width/newSize.width)
    self.imgSkinBg:setScaleY(imgSize.height/newSize.height)
end

function HallSetWidget:onModifyPwdBtnClicked()
    self:setVisible(false)
    require("plazacenter.widgets.ModifyPwdWidget").new(self:getParent(),function ()
            self:setVisible(true)
        end)
end

function HallSetWidget:onChangeAcountBtnClicked()
    -- 清空资源
    local sharedTextureCache     = cc.Director:getInstance():getTextureCache()
    local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
    sharedSpriteFrameCache:removeSpriteFrames()
    sharedTextureCache:removeAllTextures()

    -- 进入登录界面
    require("plazacenter.MyApp").new("plazacenter","plazacenter"):run()
end

function HallSetWidget:onFeedBackBtnClicked()
    self:setVisible(false)
    require("plazacenter.widgets.FeedBackWidget").new(self:getParent(),function ()
            self:setVisible(true)
        end)
end

function HallSetWidget:onAboutBtnClicked()
    self:setVisible(false)
    require("plazacenter.widgets.AboutWidget").new(self:getParent(),function ()
            self:setVisible(true)
        end)
end

function HallSetWidget:onChangeSkinBtnClicked()
    local dwCurSkinID = SessionManager:sharedManager():getSkinID()
    display.removeSpriteFrameByImageName("pic/plazacenter/u_bg"..dwCurSkinID..".png")
    dwCurSkinID = dwCurSkinID + 1
    dwCurSkinID = math.mod(dwCurSkinID,3)
    SessionManager:sharedManager():setSkinID(dwCurSkinID)
    self:setSkinBgImg("pic/plazacenter/u_bg"..dwCurSkinID..".png")

    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_ChangeSkinBg,
            para = "pic/plazacenter/u_bg"..dwCurSkinID..".png"
        })
end

return HallSetWidget

