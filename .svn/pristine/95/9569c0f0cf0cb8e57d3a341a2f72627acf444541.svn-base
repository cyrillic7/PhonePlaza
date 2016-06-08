--
-- Author: Your Name
-- Date: 2015-10-29 16:57:10
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local PersonalCenterWidget = class("PersonalCenterWidget", XWWidgetBase)

PersonalCenterWidget.GETLOTTERY_TYPE = 1
PersonalCenterWidget.USERMODIFY_TYPE = 2

function PersonalCenterWidget:ctor(parentNode,callBack)
	PersonalCenterWidget.super.ctor(self)

	self.callBack = callBack
    self.widgetType = "PersonalCenterWidget"
    self.MissionType = self.GETLOTTERY_TYPE

	self:addTo(parentNode)
end

function PersonalCenterWidget:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.Ctrl_UpdateUserInfo] = handler(self, self.receiveUpdateUserInfoMessage)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function PersonalCenterWidget:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function PersonalCenterWidget:connectLoginServer(missionType)
    self.MissionType = missionType

    if not self.missionItem then
        self.missionItem = require("plazacenter.controllers.MissionItem").new(CLIENT_TYPE_LOGIN_POINT,"LoginServer_GetLotteryAndModify")
            self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.receiveConnectMessage))
            self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.receiveShutDownMessage))
            self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_TREASURE, handler(self, self.onGetUserTreasureMessage))
            self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_FAILURE, handler(self, self.onOperateFailureMessage))
            self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_SUCCESS, handler(self, self.onOperateSuccessMessage))
    end
    if self.missionItem then
        self.missionItem.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
        self:showLoadingWidget()
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
    end
end

function PersonalCenterWidget:getLotteryData()
    self:connectLoginServer(self.GETLOTTERY_TYPE)
end

function PersonalCenterWidget:modifyUserData(cbGender,nFaceID)
    self.m_cbGender = cbGender
    self.m_nChangeFaceID = nFaceID
    self:connectLoginServer(self.USERMODIFY_TYPE)
end

function PersonalCenterWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	PersonalCenterWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_PERSONAL_CENTER_CSB_FILE)
    if not node then
        return
    end
    node:setTouchEnabled(false)
    self.mainNode = node

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Close")
    local mobileBindBtn = cc.uiloader:seekNodeByName(node, "Button_MobileBind")
    local realNameAuthBtn = cc.uiloader:seekNodeByName(node, "Button_RealNameAuth")
    local openVipBtn = cc.uiloader:seekNodeByName(node, "Button_OpenVip")
    local addGlodBtn = cc.uiloader:seekNodeByName(node, "Button_AddGlod")
    local addWingBtn = cc.uiloader:seekNodeByName(node, "Button_AddWing")
    local exchangeBtn = cc.uiloader:seekNodeByName(node, "Button_Exchange")
    local copyNickIDBtn = cc.uiloader:seekNodeByName(node, "Button_CopyNickID")

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgFace = cc.uiloader:seekNodeByName(node, "Image_Face")
    local labelNick = cc.uiloader:seekNodeByName(node, "Label_Nick")
    local labelUserID = cc.uiloader:seekNodeByName(node, "Label_UserID")
    local labelLevel = cc.uiloader:seekNodeByName(node, "AtlasLabel_Level")
    local imgLevelBg = cc.uiloader:seekNodeByName(node, "Image_LevelBg")
    local labelCurExp = cc.uiloader:seekNodeByName(node, "Label_CurExp")
    local labelLeftExp = cc.uiloader:seekNodeByName(node, "Label_LeftExp")
    local labelGold = cc.uiloader:seekNodeByName(node, "AtlasLabel_Gold")
    local labelWing = cc.uiloader:seekNodeByName(node, "AtlasLabel_Wing")
    self.labelLottery = cc.uiloader:seekNodeByName(node, "AtlasLabel_Lottery")
    local imgVipLevel = cc.uiloader:seekNodeByName(node, "Image_VipLevel")
    local imgTips = cc.uiloader:seekNodeByName(node, "Image_Tips")
    self.manCheckBox = cc.uiloader:seekNodeByName(node, "CheckBox_SexM")
    self.womanCheckBox = cc.uiloader:seekNodeByName(node, "CheckBox_SexW")

    self.currentSelectedIndex_ = GlobalUserInfo.cbGender ~= GENDER_FEMALE and 0 or 1
    if self.manCheckBox then
        self.manCheckBox:setButtonSelected(GlobalUserInfo.cbGender ~= GENDER_FEMALE)
        self.manCheckBox:onButtonClicked(handler(self, self.onButtonStateChanged_))
        self.manCheckBox:onButtonStateChanged(handler(self, self.onButtonStateChanged_))
    end
    if self.womanCheckBox then
        self.womanCheckBox:setButtonSelected(GlobalUserInfo.cbGender == GENDER_FEMALE)
        self.womanCheckBox:onButtonClicked(handler(self, self.onButtonStateChanged_))
        self.womanCheckBox:onButtonStateChanged(handler(self, self.onButtonStateChanged_))
    end

    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
    		self.callBack()
    		self:removeFromParent()
    	end)
    	
    end

    if mobileBindBtn then
        if GlobalUserInfo.cbMoorPhone == 0 then
            mobileBindBtn:setButtonImage("normal", "#pic/plazacenter/PersonalCenter/u_per_btn_bind.png")
            mobileBindBtn:setButtonImage("pressed", "#pic/plazacenter/PersonalCenter/u_per_btn_bind.png")
            imgTips:setVisible(true)
            local sequence = transition.sequence({
                cc.MoveBy:create(0.5, cc.p(0, 5)),
                --cc.FadeOut:create(0.2),
                cc.MoveBy:create(0.5, cc.p(0, -5)),
                --cc.FadeIn:create(0.2),
            })
            imgTips:runAction(cc.RepeatForever:create(sequence))
        else
            mobileBindBtn:setButtonImage("normal", "#pic/plazacenter/PersonalCenter/u_per_btn_bind_press.png")
            mobileBindBtn:setButtonImage("pressed", "#pic/plazacenter/PersonalCenter/u_per_btn_bind_press.png")
            imgTips:setVisible(false)
            transition.stopTarget(imgTips)
        end
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(mobileBindBtn)
        mobileBindBtn:onButtonClicked(function ()
            self:onMobileBindBtnClicked()
        end)
    end

    if realNameAuthBtn then
        if GlobalUserInfo.cbMoorPassPortID == 0 then
            realNameAuthBtn:setButtonImage("normal", "#pic/plazacenter/PersonalCenter/u_per_btn_realname.png")
            realNameAuthBtn:setButtonImage("pressed", "#pic/plazacenter/PersonalCenter/u_per_btn_realname.png")
        else
            realNameAuthBtn:setButtonImage("normal", "#pic/plazacenter/PersonalCenter/u_per_btn_realname_press.png")
            realNameAuthBtn:setButtonImage("pressed", "#pic/plazacenter/PersonalCenter/u_per_btn_realname_press.png")
        end
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(realNameAuthBtn)
        realNameAuthBtn:onButtonClicked(function ()
            self:onRealNameAuthBtnClicked()
        end)
    end

    if openVipBtn then
        if GlobalUserInfo.cbMemberOrder > 0 then
            openVipBtn:setVisible(false)
        else
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(openVipBtn)
            openVipBtn:onButtonClicked(function ()
                self:onOpenVipBtnClicked()
            end)
        end
    end

    if addGlodBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(addGlodBtn)
        addGlodBtn:onButtonClicked(function ()
            self:onAddGlodBtnClicked()
        end)
    end

    if addWingBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(addWingBtn)
        addWingBtn:onButtonClicked(function ()
            self:onAddWingBtnClicked()
        end)
    end

    if exchangeBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(exchangeBtn)
        exchangeBtn:onButtonClicked(function ()
            self:onExchangeBtnClicked()
        end)
    end

    if copyNickIDBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(copyNickIDBtn)
        copyNickIDBtn:onButtonClicked(function ()
            self:onCopyNickIDBtnClicked()
        end)
    end

    if imgFace then
        imgFace:setSpriteFrame("pic/face/"..GlobalUserInfo.wFaceID..".png")
    end
    if labelNick then
        labelNick:setString(GlobalUserInfo.szNickName)
    end
    if labelUserID then
        labelUserID:setString(tostring(GlobalUserInfo.dwGameID))
    end
    local level,leftExp,percent = G_GetUserLevel(GlobalUserInfo.dwExperience)
    if labelLevel then
        labelLevel:setString(tostring(level))
    end
    if imgLevelBg then
        local imgLvProgress = display.newScale9Sprite("#pic/plazacenter/Sundry/u_lv_bar.png", 0, 0, imgLevelBg:getContentSize())
        imgLvProgress:align(display.LEFT_BOTTOM, 0, 0)
        imgLevelBg.imgLvProgress = imgLvProgress
        imgLvProgress:addTo(imgLevelBg)
        while true do
            local newWidth = imgLevelBg:getContentSize().width*percent
            if newWidth >= 1 and newWidth < 20  then
                newWidth = 20
            elseif newWidth < 1 then
                imgLvProgress:setVisible(false)
                break
            end
            imgLvProgress:setVisible(true)
            imgLvProgress:setContentSize(newWidth,imgLevelBg:getContentSize().height)
            break
        end             
    end
    if labelCurExp then
        labelCurExp:setString(tostring(GlobalUserInfo.dwExperience))
    end
    if labelLeftExp then
        labelLeftExp:setString(tostring(leftExp))
    end
    if labelGold then
        labelGold:setString(tostring(GlobalUserInfo.lUserScore))
    end
    if labelWing then
        labelWing:setString(tostring(GlobalUserInfo.lIngotScore))
    end
    if self.labelLottery then
        self.labelLottery:setString(tostring(GlobalUserInfo.lLottery))
        -- 审核版本，隐藏奖券
        if GlobalPlatInfo.isInReview then
            self.labelLottery:getParent():hide()
            local label_7 = cc.uiloader:seekNodeByName(node, "Label_7")
            if label_7 then
                label_7:hide()
            end
        end
    end
    if imgVipLevel then
        imgVipLevel:setSpriteFrame("pic/plazacenter/Sundry/u_icon_vip"..GlobalUserInfo.cbMemberOrder..".png")
    end

    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)

    self:registerEvents()
    self:getLotteryData()
end

function PersonalCenterWidget:onCleanup()
	PersonalCenterWidget.super.onCleanup(self)
    self:unregisterEvents()
    if self.missionItem then
        self.missionItem:removeServiceClient()
        self.missionItem = nil
    end
end

function PersonalCenterWidget:cleanPlistRes()
	print("PersonalCenterWidget:cleanPlistRes")
    display.removeSpriteFramesWithFile("UIPersonalCenter.plist", "UIPersonalCenter.png")
end

function PersonalCenterWidget:onMobileBindBtnClicked()
    --self:setVisible(false)
    require("plazacenter.widgets.MobileBindWidget").new(self:getParent(),function ()
    --        self:setVisible(true)
        end)
end

function PersonalCenterWidget:onRealNameAuthBtnClicked()
    --self:setVisible(false)
    require("plazacenter.widgets.RealNameAuthWidget").new(self:getParent(),function ()
    --        self:setVisible(true)
        end)
end

function PersonalCenterWidget:onOpenVipBtnClicked()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_OpenTopupWidget,
            para = 1,
        })
end

function PersonalCenterWidget:onAddGlodBtnClicked()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_OpenTopupWidget,
            para = 0,
        })
end

function PersonalCenterWidget:onAddWingBtnClicked()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_OpenTopupWidget,
            para = 1,
        })
end

function PersonalCenterWidget:onExchangeBtnClicked()
    
end

function PersonalCenterWidget:onCopyNickIDBtnClicked()
    local copyTxt = GlobalUserInfo.szNickName.." "..GlobalUserInfo.dwGameID
    if device.platform == "android" then
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "copyTextToClipboard", 
        {copyTxt}, "(Ljava/lang/String;)V")
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("LuaCallObjcFuncs", "copyTextToClipboard",{text=copyTxt})
    end
    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo="成功复制“"..copyTxt.."”到剪切板中！"
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function PersonalCenterWidget:onButtonStateChanged_(event)
    if not self.manCheckBox or not self.womanCheckBox then
        return
    end

    if event.name == event.target.STATE_CHANGED_EVENT and event.target:isButtonSelected() == false then
        return
    end
    
    self:updateButtonState_(event.target)
end

function PersonalCenterWidget:updateButtonState_(clickedButton)
    local currentSelectedIndex = 0
    if self.manCheckBox == clickedButton then
        currentSelectedIndex = 0
        if not self.manCheckBox:isButtonSelected() then
            self.manCheckBox:setButtonSelected(true)
        end
        self.womanCheckBox:setButtonSelected(false)
    else
        currentSelectedIndex = 1
        if not self.womanCheckBox:isButtonSelected() then
            self.womanCheckBox:setButtonSelected(true)
        end
        self.manCheckBox:setButtonSelected(false)
    end
    
    if self.currentSelectedIndex_ ~= currentSelectedIndex then
        self.currentSelectedIndex_ = currentSelectedIndex
        local cbGender = currentSelectedIndex == 0 and GENDER_MANKIND or GENDER_FEMALE
        math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
        for i=1,10 do
            math.random(100000)
        end
        self:modifyUserData(cbGender, math.round(math.random(10000))%8+((cbGender==1) and 8 or 0))
    end
end

function PersonalCenterWidget:receiveUpdateUserInfoMessage(event)
    if self.mainNode then
        local node = self.mainNode
        local mobileBindBtn = cc.uiloader:seekNodeByName(node, "Button_MobileBind")
        local realNameAuthBtn = cc.uiloader:seekNodeByName(node, "Button_RealNameAuth")
        local openVipBtn = cc.uiloader:seekNodeByName(node, "Button_OpenVip")

        local imgFace = cc.uiloader:seekNodeByName(node, "Image_Face")
        local labelNick = cc.uiloader:seekNodeByName(node, "Label_Nick")
        local labelUserID = cc.uiloader:seekNodeByName(node, "Label_UserID")
        local labelLevel = cc.uiloader:seekNodeByName(node, "AtlasLabel_Level")
        local imgLevelBg = cc.uiloader:seekNodeByName(node, "Image_LevelBg")
        local labelCurExp = cc.uiloader:seekNodeByName(node, "Label_CurExp")
        local labelLeftExp = cc.uiloader:seekNodeByName(node, "Label_LeftExp")
        local labelGold = cc.uiloader:seekNodeByName(node, "AtlasLabel_Gold")
        local labelWing = cc.uiloader:seekNodeByName(node, "AtlasLabel_Wing")
        local labelLottery = cc.uiloader:seekNodeByName(node, "AtlasLabel_Lottery")
        local imgVipLevel = cc.uiloader:seekNodeByName(node, "Image_VipLevel")
        local imgTips = cc.uiloader:seekNodeByName(node, "Image_Tips")
        --local manCheckBox = cc.uiloader:seekNodeByName(node, "CheckBox_SexM")
        --local womanCheckBox = cc.uiloader:seekNodeByName(node, "CheckBox_SexW")
        --if manCheckBox then
        --    manCheckBox:setButtonSelected(GlobalUserInfo.cbGender ~= GENDER_FEMALE)
        --    manCheckBox:setTouchEnabled(false)
        --end
        --if womanCheckBox then
        --    womanCheckBox:setButtonSelected(GlobalUserInfo.cbGender == GENDER_FEMALE)
        --    womanCheckBox:setTouchEnabled(false)
        --end

        if mobileBindBtn then
            if GlobalUserInfo.cbMoorPhone == 0 then
                mobileBindBtn:setButtonImage("normal", "#pic/plazacenter/PersonalCenter/u_per_btn_bind.png")
                mobileBindBtn:setButtonImage("pressed", "#pic/plazacenter/PersonalCenter/u_per_btn_bind.png")
                imgTips:setVisible(true)
                local sequence = transition.sequence({
                    cc.MoveBy:create(0.2, cc.p(0, 30)),
                    cc.FadeOut:create(0.2),
                    cc.MoveBy:create(0.2, cc.p(0, -30)),
                    cc.FadeIn:create(0.2),
                })
                mobileBindBtn:runAction(sequence)
            else
                mobileBindBtn:setButtonImage("normal", "#pic/plazacenter/PersonalCenter/u_per_btn_bind_press.png")
                mobileBindBtn:setButtonImage("pressed", "#pic/plazacenter/PersonalCenter/u_per_btn_bind_press.png")
                imgTips:setVisible(false)
                transition.stopTarget(imgTips)
            end
        end

        if realNameAuthBtn then
            if GlobalUserInfo.cbMoorPassPortID == 0 then
                realNameAuthBtn:setButtonImage("normal", "#pic/plazacenter/PersonalCenter/u_per_btn_realname.png")
                realNameAuthBtn:setButtonImage("pressed", "#pic/plazacenter/PersonalCenter/u_per_btn_realname.png")
            else
                realNameAuthBtn:setButtonImage("normal", "#pic/plazacenter/PersonalCenter/u_per_btn_realname_press.png")
                realNameAuthBtn:setButtonImage("pressed", "#pic/plazacenter/PersonalCenter/u_per_btn_realname_press.png")
            end
        end

        if openVipBtn then
            if GlobalUserInfo.cbMemberOrder > 0 then
                openVipBtn:setVisible(false)
            else
                openVipBtn:setVisible(true)
            end
        end

        if imgFace then
            imgFace:setSpriteFrame("pic/face/"..GlobalUserInfo.wFaceID..".png")
        end
        if labelNick then
            labelNick:setString(GlobalUserInfo.szNickName)
        end
        if labelUserID then
            labelUserID:setString(tostring(GlobalUserInfo.dwGameID))
        end
        local level,leftExp,percent = G_GetUserLevel(GlobalUserInfo.dwExperience)
        if labelLevel then
            labelLevel:setString(tostring(level))
        end
        if imgLevelBg then
            local imgLvProgress = imgLevelBg.imgLvProgress
            while true do
                local newWidth = imgLevelBg:getContentSize().width*percent
                if newWidth >= 1 and newWidth < 20  then
                    newWidth = 20
                elseif newWidth < 1 then
                    imgLvProgress:setVisible(false)
                    break
                end
                imgLvProgress:setVisible(true)
                imgLvProgress:setContentSize(newWidth,imgLevelBg:getContentSize().height)
                break
            end             
        end
        if labelCurExp then
            labelCurExp:setString(tostring(GlobalUserInfo.dwExperience))
        end
        if labelLeftExp then
            labelLeftExp:setString(tostring(leftExp))
        end
        if labelGold then
            labelGold:setString(tostring(GlobalUserInfo.lUserScore))
        end
        if labelWing then
            labelWing:setString(tostring(GlobalUserInfo.lIngotScore))
        end
        if labelLottery then
            labelLottery:setString(tostring(GlobalUserInfo.lLottery))
        end
        if imgVipLevel then
            imgVipLevel:setSpriteFrame("pic/plazacenter/Sundry/u_icon_vip"..GlobalUserInfo.cbMemberOrder..".png")
        end
    end
end
function PersonalCenterWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        if self.MissionType == self.GETLOTTERY_TYPE then
            local CMD_GP_UserID = {
                dwUserID=GlobalUserInfo.dwUserID,
                szPassword=GlobalUserInfo.szPassword,
            }
            self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_TREASURE, CMD_GP_UserID, "CMD_GP_UserID")
        else
            local CMD_GP_ModifyIndividual_wAndf = {
                cbGender=self.m_cbGender,
                dwUserID=GlobalUserInfo.dwUserID,
                szPassword=GlobalUserInfo.szPassword,
                writeDes={
                    wDataSize=32,
                    wDataDescribe=DTP_GP_UI_UNDER_WRITE
                    },
                m_szUnderWrite=GlobalUserInfo.szUnderWrite,
                faceDes={
                    wDataSize=4,
                    wDataDescribe=DTP_GP_UI_USER_FACE
                    },
                m_nChangeFaceID=self.m_nChangeFaceID,
            }
            self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_MODIFY_INDIVIDUAL, CMD_GP_ModifyIndividual_wAndf, "CMD_GP_ModifyIndividual_wAndf")
        end        
        self:updateStatusLabel("发送请求中")
    else
        self:hideLoadingWidget()
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="连接服务器失败，请稍后重试！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
end

function PersonalCenterWidget:receiveShutDownMessage(Params)
   print("PersonalCenterWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function PersonalCenterWidget:onGetUserTreasureMessage(Params)
   print("PersonalCenterWidget onGetUserTreasureMessage")
   self:hideLoadingWidget()

   GlobalUserInfo.lLottery = Params.lLottery
   if self.labelLottery then
       self.labelLottery:setString(tostring(Params.lLottery))
   end
   if self.missionItem then
        self.missionItem:onDisconnectSocket()
    end
end

function PersonalCenterWidget:onOperateSuccessMessage(Params)
    self:hideLoadingWidget()

    -- 更新数据
    GlobalUserInfo.cbGender = self.m_cbGender
    GlobalUserInfo.wFaceID = self.m_nChangeFaceID

    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_UpdateUserInfo,
            para = {}
        })

    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    if self.missionItem then
        self.missionItem:onDisconnectSocket()
    end
end

function PersonalCenterWidget:onOperateFailureMessage(Params)
    self:hideLoadingWidget()

   local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    if self.missionItem then
        self.missionItem:onDisconnectSocket()
    end
end

return PersonalCenterWidget

