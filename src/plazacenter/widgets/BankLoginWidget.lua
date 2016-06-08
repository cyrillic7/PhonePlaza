--
-- Author: SuperM
-- Date: 2015-11-05 16:03:02
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local BankLoginWidget = class("BankLoginWidget", XWWidgetBase)

function BankLoginWidget:ctor(parentNode)
	BankLoginWidget.super.ctor(self)

	self:addTo(parentNode)
end

function BankLoginWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	BankLoginWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_BANK_LOGIN_CSB_FILE)
    if not node then
        return
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Cancel")
    local okBtn = cc.uiloader:seekNodeByName(node, "Button_Ok")
    local forgetPwdBtn = cc.uiloader:seekNodeByName(node, "Button_ForgetPwd")
    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgPwdBg = cc.uiloader:seekNodeByName(node, "Image_InputBg")
    
    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
    		self:removeFromParent()
            display.removeSpriteFramesWithFile("UIHallBank.plist", "UIHallBank.png")
    	end)    	
    end
    if okBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(okBtn)
    	okBtn:onButtonClicked(function ()
    		self:onOkBtnClicked()
    	end) 
    end
    if forgetPwdBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(forgetPwdBtn)
    	forgetPwdBtn:onButtonClicked(function ()
    		self:onForgetPwdBtnClicked()
    	end) 
    end
    if imgPwdBg then
        self.PwdEditPwd = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgPwdBg:getContentSize().width/2,
                            y=imgPwdBg:getContentSize().height/2,
                            size=imgPwdBg:getContentSize() })
        self.PwdEditPwd:setInputFlag(0)
        self.PwdEditPwd:setFontColor(cc.c3b(83,75,68))
        self.PwdEditPwd:setFontSize(28)
        self.PwdEditPwd:setFontName("微软雅黑")
        self.PwdEditPwd:setPlaceHolder("点击输入保险柜密码")
        self.PwdEditPwd:setPlaceholderFont("微软雅黑",28)
        self.PwdEditPwd:setMaxLength(32)
        imgPwdBg:addChild(self.PwdEditPwd)
    end

    if self:checkBankPwdIsOnWork() then
        self.strPwd = GlobalUserInfo.szBankPassword
        --self:connectLoginServer()
        -- 进入银行
        AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
                name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_ShowBankWidget,
                para = self.strPwd
            })
        return
    end
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function BankLoginWidget:onCleanup()
	BankLoginWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function BankLoginWidget:checkBankPwdIsOnWork()
    if string.len(GlobalUserInfo.szBankPassword) == 32 and 
        (os.time() - GlobalUserInfo.lPreBankTimeTick) < 10*60*60 then
        return true
    else
        GlobalUserInfo.szBankPassword = ""
        GlobalUserInfo.lPreBankTimeTick = 0
        return false
    end
end

function BankLoginWidget:updateBankPassword(bClear)
    if bClear then
        GlobalUserInfo.szBankPassword = ""
        GlobalUserInfo.lPreBankTimeTick = 0
    else
        GlobalUserInfo.szBankPassword = self.strPwd or ""
        GlobalUserInfo.lPreBankTimeTick = os.time()
    end
end

function BankLoginWidget:connectLoginServer()
    if not self.missionItem then
        self.missionItem = require("plazacenter.controllers.MissionItem").new(CLIENT_TYPE_LOGIN_POINT,"LoginServer_ModifyPwd")
        self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.receiveConnectMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.receiveShutDownMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_SUCCESS, handler(self, self.onOperateSuccessMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_FAILURE, handler(self, self.onOperateFailureMessage))
    end
    if self.missionItem then
        self.missionItem.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
        self:showLoadingWidget()
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
    end
end

function BankLoginWidget:onOkBtnClicked()
    local strPwd = self.PwdEditPwd:getText()
	if string.len(strPwd) < 8 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="密码长度过短(最低8位)，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
		return
	end

    self.strPwd = cc.Crypto:MD5(strPwd,false)

    self:connectLoginServer()
end

function BankLoginWidget:onForgetPwdBtnClicked()
	-- 未绑定手机，提示联系客服
	if GlobalUserInfo.cbMoorPhone == 0 then
		local dataMsgBox = {
	        nodeParent=self,
	        msgboxType=MSGBOX_TYPE_OK,
	        msgInfo="您的账号尚未绑定手机,请联系在线客服解决。"
	    }
	    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
	    return
	end
	self:setVisible(false)
    require("plazacenter.widgets.ForgetBankPwdWidget").new(self:getParent(),function ()
            self:setVisible(true)
        end)
end

function BankLoginWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("BankLoginWidget bConnectSucc: 连接成功！")
        local CMD_GP_VERIFY_INSUREPASS = {
			dwUserID=GlobalUserInfo.dwUserID,
            szInsurePass=self.strPwd,
			szMachineID=GlobalPlatInfo.szMachineID,
		}
        self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_VERIFY_INSURE_PASS, CMD_GP_VERIFY_INSUREPASS)
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

function BankLoginWidget:receiveShutDownMessage(Params)
   print("BankLoginWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function BankLoginWidget:onOperateSuccessMessage(Params)
    self:hideLoadingWidget()

    self:updateBankPassword(false)

    if self.missionItem then
        self.missionItem:onDisconnectSocket()
    end

    -- 进入银行
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_ShowBankWidget,
            para = self.strPwd
        })
    -- 退出登录
    self:removeFromParent()
end

function BankLoginWidget:onOperateFailureMessage(Params)
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

    self:updateBankPassword(true)
end

return BankLoginWidget