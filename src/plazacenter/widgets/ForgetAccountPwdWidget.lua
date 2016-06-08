--
-- Author: SuperM
-- Date: 2015-11-17 11:47:33
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local ForgetAccountPwdWidget = class("ForgetAccountPwdWidget", XWWidgetBase)

ForgetAccountPwdWidget.LOGINPWD_CHECK_ACCOUNT = 0
ForgetAccountPwdWidget.LOGINPWD_GET_CODE = 1
ForgetAccountPwdWidget.LOGINPWD_SET_NEWPWD = 2

function ForgetAccountPwdWidget:ctor(parentNode,callBack)
	ForgetAccountPwdWidget.super.ctor(self)

	self.callBack = callBack
    self.MissionType = self.LOGINPWD_CHECK_ACCOUNT
    self.bGetedVeriCode = false

	self:addTo(parentNode)
end

function ForgetAccountPwdWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	ForgetAccountPwdWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_FORGET_ACCOUNT_PWD_CSB_FILE)
    if not node then
        return
    end

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgMain = cc.uiloader:seekNodeByName(node, "Image_Main")
    local panelFirst = cc.uiloader:seekNodeByName(imgMain, "Panel_First")
    local panelSecond = cc.uiloader:seekNodeByName(imgMain, "Panel_Second")

    local okBtn = cc.uiloader:seekNodeByName(imgMain, "Button_Ok")
    local cancelBtn = cc.uiloader:seekNodeByName(imgMain, "Button_Cancel")
    local getVeriBtn = cc.uiloader:seekNodeByName(panelSecond, "Button_GetVeriCode")
    local imgAccountBg = cc.uiloader:seekNodeByName(panelFirst, "Image_AccountBg")
    local imgVerCodeBg = cc.uiloader:seekNodeByName(panelSecond, "Image_VeriCodeBg")
    local imgNewPwdBg = cc.uiloader:seekNodeByName(panelSecond, "Image_NewPwdBg")
    self.LabelPhoneNumber = cc.uiloader:seekNodeByName(panelSecond, "Label_PhoneNumber")
    
    self.panelFirst = panelFirst
    self.panelSecond = panelSecond
    self:switchPanel(true)
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
    if imgAccountBg then
        self.AccountEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgAccountBg:getContentSize().width/2,
                            y=imgAccountBg:getContentSize().height/2,
                            size=imgAccountBg:getContentSize() })
        self.AccountEdit:setFontColor(cc.c3b(83,75,68))
        self.AccountEdit:setFontSize(28)
        self.AccountEdit:setFontName("微软雅黑")
        self.AccountEdit:setPlaceHolder("点击输入帐号")
        self.AccountEdit:setPlaceholderFont("微软雅黑",28)
        self.AccountEdit:setMaxLength(32)
        imgAccountBg:addChild(self.AccountEdit)
    end
    if imgNewPwdBg then
        self.NewPwdEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgNewPwdBg:getContentSize().width/2,
                            y=imgNewPwdBg:getContentSize().height/2,
                            size=imgNewPwdBg:getContentSize() })
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

    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function ForgetAccountPwdWidget:switchPanel(bToFirstPanel)
	if self.panelFirst and self.panelSecond then
		self.panelFirst:setVisible(bToFirstPanel)
		self.panelSecond:setVisible(not bToFirstPanel)
	end
end
function ForgetAccountPwdWidget:onCleanup()
	ForgetAccountPwdWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function ForgetAccountPwdWidget:onQuitWidget()
	self.callBack()
    self:removeFromParent()
end

function ForgetAccountPwdWidget:onGetVeriCodeBtnClicked()
    self:connectLoginServer(self.LOGINPWD_GET_CODE)
end

function ForgetAccountPwdWidget:onOkBtnClicked()
	if not (self.panelFirst and self.panelSecond) then
		return
	end
	-- 第一步 校验帐号
	if self.panelFirst:isVisible() then
		local strAccount = self.AccountEdit:getText()
		if string.len(strAccount) < 6 then
	        local dataMsgBox = {
	            nodeParent=self,
	            msgboxType=MSGBOX_TYPE_OK,
	            msgInfo="帐号长度过短(最短低6个字符)，请重新输入！"
	        }
	        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
			return
		end
		if tonumber(strAccount) ~= nil then
	        local dataMsgBox = {
	            nodeParent=self,
	            msgboxType=MSGBOX_TYPE_OK,
	            msgInfo="帐号不可以为纯数字，请重新输入！"
	        }
	        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
	        return
	    end
	    self.strAccount = strAccount
	    self:connectLoginServer(self.LOGINPWD_CHECK_ACCOUNT)
		return
	end
	-- 第二部 设置新密码
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
    self:connectLoginServer(self.LOGINPWD_SET_NEWPWD)
    self.strVeriCode = strVeriCode
    self.strNewPwd = strNewPwd
end

function ForgetAccountPwdWidget:connectLoginServer(missionType)
    self.MissionType = missionType

    if not self.missionItem then
        self.missionItem = require("plazacenter.controllers.MissionItem").new(CLIENT_TYPE_LOGIN_POINT,"LoginServer_ForgetAccountPwd")
        self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.receiveConnectMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.receiveShutDownMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_SUCCESS, handler(self, self.onOperateSuccessMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_FAILURE, handler(self, self.onOperateFailureMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_CHECK_ACCOUNT, handler(self, self.onGetCheckAccountMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_GET_CAPTCHA_BY_ID, handler(self, self.onGetCaptchaMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_SET_LOGIN_PASS, handler(self, self.onSendCaptchaMessage))
    end
    if self.missionItem then
        self.missionItem.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
        self:showLoadingWidget()
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
    end
end

function ForgetAccountPwdWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("ForgetAccountPwdWidget bConnectSucc: 连接成功！")
        local request = {}
        if self.MissionType == self.LOGINPWD_CHECK_ACCOUNT then
        	local CMD_GP_Accounts = {
				szAccounts=self.strAccount
			}
			self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_CHECK_ACCOUNT, 
            	CMD_GP_Accounts,"CMD_GP_Accounts")
        elseif self.MissionType == self.LOGINPWD_GET_CODE then
        	local CMD_GP_GetCaptchaByUserID = {
				dwUserID=self.dwUserID,
			}
            self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_GET_CAPTCHA_BY_ID, 
            	CMD_GP_GetCaptchaByUserID,"CMD_GP_GetCaptchaByUserID")
        else
        	local CMD_GP_SetPass = {
				dwUserID=self.dwUserID,
				dwCaptcha=checknumber(self.strVeriCode),
				szPass=cc.Crypto:MD5(self.strNewPwd,false)
			}
            self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_SET_LOGIN_PASS, 
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

function ForgetAccountPwdWidget:receiveShutDownMessage(Params)
   print("ForgetAccountPwdWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function ForgetAccountPwdWidget:onOperateSuccessMessage(Params)
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

function ForgetAccountPwdWidget:onOperateFailureMessage(Params)
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

function ForgetAccountPwdWidget:onGetCheckAccountMessage(Params)
	self:hideLoadingWidget()
	-- CMD_GP_AccountsRet
	-- 绑定了手机
	if Params.lResultCode == 0 then
		self.LabelPhoneNumber:setString(Params.szPhone)
		self.NewPwdEdit:setText("")
		self.VeriEdit:setText("")
		self.dwUserID = Params.dwUserID
		self:switchPanel(false)
	-- 未绑定手机
	--[[elseif Params.lResultCode == 2 then
		local dataMsgBox = {
	        nodeParent=self,
	        msgboxType=MSGBOX_TYPE_OK,
	        msgInfo="您的帐号暂未绑定手机，请联系在线客服进行找回！"
	    }
	    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)]]
	else -- 帐号不存在
		local dataMsgBox = {
	        nodeParent=self,
	        msgboxType=MSGBOX_TYPE_OK,
	        msgInfo=Params.szDescribeString
	    }
	    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
	end
end

function ForgetAccountPwdWidget:onGetCaptchaMessage(Params)
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

function ForgetAccountPwdWidget:onSendCaptchaMessage(Params)
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

return ForgetAccountPwdWidget