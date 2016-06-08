--
-- Author: SuperM
-- Date: 2015-11-05 17:34:31
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local ForgetBankPwdWidget = class("ForgetBankPwdWidget", XWWidgetBase)

ForgetBankPwdWidget.INSURE_PWD_GET_CODE = 1
ForgetBankPwdWidget.INSURE_PWD_SET_NEWPWD = 2

function ForgetBankPwdWidget:ctor(parentNode,callBack)
	ForgetBankPwdWidget.super.ctor(self)

	self.callBack = callBack
    self.MissionType = self.INSURE_PWD_GET_CODE
    self.bGetedVeriCode = false

	self:addTo(parentNode)
end

function ForgetBankPwdWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	ForgetBankPwdWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_FORGET_BANK_PWD_CSB_FILE)
    if not node then
        return
    end

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgMain = cc.uiloader:seekNodeByName(node, "Image_Main")

    local okBtn = cc.uiloader:seekNodeByName(imgMain, "Button_Ok")
    local cancelBtn = cc.uiloader:seekNodeByName(imgMain, "Button_Cancel")
    local getVeriBtn = cc.uiloader:seekNodeByName(imgMain, "Button_GetVeriCode")
    local imgVerCodeBg = cc.uiloader:seekNodeByName(imgMain, "Image_VeriCodeBg")
    local imgNewPwdBg = cc.uiloader:seekNodeByName(imgMain, "Image_NewPwdBg")
    local LabelPhoneNumber = cc.uiloader:seekNodeByName(imgMain, "Label_PhoneNumber")

    if okBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(okBtn)
        okBtn:onButtonClicked(function ()
            self:onOkBtnClicked()
        end) 
    end
    if cancelBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(cancelBtn)
        cancelBtn:onButtonClicked(function ()
            self:onQuitWidget()
        end)            
    end
    if getVeriBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(getVeriBtn)
        getVeriBtn:onButtonClicked(function ()
            self:onGetVeriCodeBtnClicked()
        end)
    end
    if imgNewPwdBg then
        self.NewPwdEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgNewPwdBg:getContentSize().width/2,
                            y=imgNewPwdBg:getContentSize().height/2,
                            size=imgNewPwdBg:getContentSize() })
        --self.NewPwdEdit:setInputMode(3)
        self.NewPwdEdit:setFontColor(cc.c3b(83,75,68))
        self.NewPwdEdit:setFontSize(28)
        self.NewPwdEdit:setFontName("微软雅黑")
        self.NewPwdEdit:setPlaceHolder("点击输入新密码")
        self.NewPwdEdit:setPlaceholderFont("微软雅黑",28)
        self.NewPwdEdit:setMaxLength(32)
        imgNewPwdBg:addChild(self.NewPwdEdit)
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
    if LabelPhoneNumber then
    	LabelPhoneNumber:setString(GlobalUserInfo.szMobilePhone)
    end

    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function ForgetBankPwdWidget:onCleanup()
	ForgetBankPwdWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function ForgetBankPwdWidget:onQuitWidget()
	self.callBack()
    self:removeFromParent()
end

function ForgetBankPwdWidget:onGetVeriCodeBtnClicked()
    self:connectLoginServer(self.INSURE_PWD_GET_CODE)
end

function ForgetBankPwdWidget:onOkBtnClicked()
	local strNewPwd = self.NewPwdEdit:getText()
	if string.len(strNewPwd) < 8 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="新密码长度过短(最低8位)，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    if tonumber(strNewPwd) ~= nil then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="密码不可以为纯数字，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
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
    self:connectLoginServer(self.INSURE_PWD_SET_NEWPWD)
    self.strVeriCode = strVeriCode
    self.strNewPwd = strNewPwd
end

function ForgetBankPwdWidget:connectLoginServer(missionType)
    self.MissionType = missionType

    if not self.missionItem then
        self.missionItem = require("plazacenter.controllers.MissionItem").new(CLIENT_TYPE_LOGIN_POINT,"LoginServer_ForgetInsurePwd")
        self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.receiveConnectMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.receiveShutDownMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_SUCCESS, handler(self, self.onOperateSuccessMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_FAILURE, handler(self, self.onOperateFailureMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_SET_INSUREPASS_GET_CAPTCHA, handler(self, self.onGetCaptchaMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_SET_INSUREPASS_SEND_CAPTCHA, handler(self, self.onSendCaptchaMessage))
    end
    if self.missionItem then
        self.missionItem.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
        self:showLoadingWidget()
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
    end
end

function ForgetBankPwdWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("ForgetBankPwdWidget bConnectSucc: 连接成功！")
        local request = {}
        if self.MissionType == self.INSURE_PWD_GET_CODE then
        	local CMD_GP_SetInsurePassGetCaptcha = {
				dwUserID=GlobalUserInfo.dwUserID,
				szLogonPass=GlobalUserInfo.szPassword,
				szMachineID=GlobalPlatInfo.szMachineID,
			}
            self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_SET_INSUREPASS_GET_CAPTCHA, 
            	CMD_GP_SetInsurePassGetCaptcha,"CMD_GP_SetInsurePassGetCaptcha")
        else
        	local CMD_GP_SetPass = {
				dwUserID=GlobalUserInfo.dwUserID,
				dwCaptcha=checknumber(self.strVeriCode),
				szPass=cc.Crypto:MD5(self.strNewPwd,false)
			}
            self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_SET_INSUREPASS_SEND_CAPTCHA, 
            	CMD_GP_SetPass,"CMD_GP_SetPass")
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

function ForgetBankPwdWidget:receiveShutDownMessage(Params)
   print("ForgetBankPwdWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function ForgetBankPwdWidget:onOperateSuccessMessage(Params)
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

function ForgetBankPwdWidget:onOperateFailureMessage(Params)
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

function ForgetBankPwdWidget:onGetCaptchaMessage(Params)
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

function ForgetBankPwdWidget:onSendCaptchaMessage(Params)
    self:hideLoadingWidget()

    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString,
        callBack=function ()
        	if Params.lResultCode == 0 then
        		self:onQuitWidget()
        	end
        end
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    if self.missionItem then
        self.missionItem:onDisconnectSocket()
    end
end

return ForgetBankPwdWidget