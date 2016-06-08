--
-- Author: Your Name
-- Date: 2015-11-02 10:40:51
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local MobileBindWidget = class("MobileBindWidget", XWWidgetBase)

MobileBindWidget.MOBILE_BIND = 1
MobileBindWidget.MOBILE_GET_CODE = 2

function MobileBindWidget:ctor(parentNode,callBack)
	MobileBindWidget.super.ctor(self)

	self.callBack = callBack
    self.MissionType = self.MOBILE_GET_CODE
    self.bGetedVeriCode = false

	self:addTo(parentNode)
end

function MobileBindWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	MobileBindWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_MOBILE_BIND_CSB_FILE)
    if not node then
        return
    end

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local panelNotBind = cc.uiloader:seekNodeByName(node, "Panel_NotBind")
    local panelBinded = cc.uiloader:seekNodeByName(node, "Panel_Binded")
    -- 未绑定
    if GlobalUserInfo.cbMoorPhone == 0 then
        panelNotBind:setVisible(true)
        panelBinded:setVisible(false)

        local okBtn = cc.uiloader:seekNodeByName(panelNotBind, "Button_Ok")
        local cancelBtn = cc.uiloader:seekNodeByName(panelNotBind, "Button_Cancel")
        local getVeriBtn = cc.uiloader:seekNodeByName(panelNotBind, "Button_GetVeriCode")
        local imgVerCodeBg = cc.uiloader:seekNodeByName(node, "Image_VeriCodeBg")
        local imgPhoneBg = cc.uiloader:seekNodeByName(node, "Image_PhoneBg")

        if okBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(okBtn)
            okBtn:onButtonClicked(function ()
                self:onOkBtnClicked()
            end) 
        end
        if cancelBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(cancelBtn)
            cancelBtn:onButtonClicked(function ()
                self.callBack()
                self:removeFromParent()
            end)            
        end
        if getVeriBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(getVeriBtn)
            getVeriBtn:onButtonClicked(function ()
                self:onGetVeriCodeBtnClicked()
            end)
        end
        if imgPhoneBg then
            self.PhoneEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                                x=imgPhoneBg:getContentSize().width/2,
                                y=imgPhoneBg:getContentSize().height/2,
                                size=imgPhoneBg:getContentSize() })
            self.PhoneEdit:setInputMode(3)
            self.PhoneEdit:setFontColor(cc.c3b(83,75,68))
            self.PhoneEdit:setFontSize(28)
            self.PhoneEdit:setFontName("微软雅黑")
            self.PhoneEdit:setPlaceHolder("点击输入绑定手机号")
            self.PhoneEdit:setPlaceholderFont("微软雅黑",28)
            self.PhoneEdit:setMaxLength(11)
            imgPhoneBg:addChild(self.PhoneEdit)
        end
        if imgVerCodeBg then
            self.VeriEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                                x=imgVerCodeBg:getContentSize().width/2,
                                y=imgVerCodeBg:getContentSize().height/2,
                                size=imgVerCodeBg:getContentSize() })
            self.VeriEdit:setInputMode(3)
            self.VeriEdit:setFontColor(cc.c3b(83,75,68))
            self.VeriEdit:setFontSize(28)
            self.VeriEdit:setFontName("微软雅黑")
            self.VeriEdit:setPlaceHolder("点击输入验证码")
            self.VeriEdit:setPlaceholderFont("微软雅黑",28)
            self.VeriEdit:setMaxLength(8)
            imgVerCodeBg:addChild(self.VeriEdit)
        end
    else -- 已绑定
        panelNotBind:setVisible(false)
        panelBinded:setVisible(true)
    end

    local closeBtn = cc.uiloader:seekNodeByName(panelBinded, "Button_Close")
    local LabelPhoneNumber = cc.uiloader:seekNodeByName(panelBinded, "Label_PhoneNumber")
    if closeBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
        closeBtn:onButtonClicked(function ()
            self.callBack()
            self:removeFromParent()
        end)            
    end
    if LabelPhoneNumber then
        LabelPhoneNumber:setString(GlobalUserInfo.szMobilePhone)
    end
    -- 保存变量，方便绑定成功后，切换切面
    self.panelNotBind = panelNotBind
    self.panelBinded = panelBinded
    self.LabelPhoneNumber = LabelPhoneNumber

    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function MobileBindWidget:onCleanup()
	MobileBindWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function MobileBindWidget:onGetVeriCodeBtnClicked()
    local strPhoneNumber = self.PhoneEdit:getText()
    if string.len(strPhoneNumber) ~= 11 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="请先输入11位手机号，再进行操作！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    if string.len(strPhoneNumber) ~= 11 
        or not tonumber(strPhoneNumber) 
        or string.find(strPhoneNumber,"1") ~= 1 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="输入手机号码有误，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end

    self:connectLoginServer(self.MOBILE_GET_CODE)
    self.strPhoneNumber = strPhoneNumber
end

function MobileBindWidget:onOkBtnClicked()
    if not self.bGetedVeriCode then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="请先点击‘获取验证码’按钮进行获取验证码操作！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    local strVeriCode = self.VeriEdit:getText()
    if string.len(strVeriCode) < 6 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="验证码长度不足，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    if not tonumber(strVeriCode) then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="验证码输入不正确，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    self:connectLoginServer(self.MOBILE_BIND)
    self.strVeriCode = strVeriCode
end

function MobileBindWidget:connectLoginServer(missionType)
    self.MissionType = missionType

    if not self.missionItem then
        self.missionItem = require("plazacenter.controllers.MissionItem").new(CLIENT_TYPE_LOGIN_POINT,"LoginServer_MobileBind")
        self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.receiveConnectMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.receiveShutDownMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_SUCCESS, handler(self, self.onOperateSuccessMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_FAILURE, handler(self, self.onOperateFailureMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_GET_CAPTCHA, handler(self, self.onGetCaptchaMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_SEND_CAPTCHA, handler(self, self.onSendCaptchaMessage))
    end
    if self.missionItem then
        self.missionItem.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
        self:showLoadingWidget()
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
    end
end

function MobileBindWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("MobileBindWidget bConnectSucc: 连接成功！")
        local request = {}
        if self.MissionType == self.MOBILE_GET_CODE then
            local CMD_GP_Get_Captcha = {
                dwUserID=GlobalUserInfo.dwUserID,
                szLogonPass=GlobalUserInfo.szPassword,
                szPhone=self.strPhoneNumber,
                szMachineID=GlobalPlatInfo.szMachineID,
            }
            self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_GET_CAPTCHA, CMD_GP_Get_Captcha,"CMD_GP_Get_Captcha")
        else
            local CMD_GP_Send_Captcha = {
                dwUserID=GlobalUserInfo.dwUserID,
                dwCaptcha=checknumber(self.strVeriCode)
            }
            self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_SEND_CAPTCHA, CMD_GP_Send_Captcha,"CMD_GP_Send_Captcha")
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

function MobileBindWidget:receiveShutDownMessage(Params)
   print("MobileBindWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function MobileBindWidget:onOperateSuccessMessage(Params)
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

function MobileBindWidget:onOperateFailureMessage(Params)
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

function MobileBindWidget:onGetCaptchaMessage(Params)
    self:hideLoadingWidget()

    if Params.lResultCode == 0 then
        self.bGetedVeriCode = true
    end
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

function MobileBindWidget:onSendCaptchaMessage(Params)
    self:hideLoadingWidget()

    -- 绑定成功，设置全局变量
    if Params.lResultCode == 0 then
        GlobalUserInfo.cbMoorPhone = 1
        GlobalUserInfo.szMobilePhone = string.sub(self.strPhoneNumber,1,4).."****"..string.sub(self.strPhoneNumber,9)

        self.panelNotBind:setVisible(false)
        self.panelBinded:setVisible(true)
        self.LabelPhoneNumber:setString(GlobalUserInfo.szMobilePhone)

        AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_UpdateUserInfo,
            para = {}
        })
    end

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
return MobileBindWidget