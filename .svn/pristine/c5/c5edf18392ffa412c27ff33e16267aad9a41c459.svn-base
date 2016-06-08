--
-- Author: SuperM
-- Date: 2015-12-11 22:13:36
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local SetBankPwdWidget = class("SetBankPwdWidget", XWWidgetBase)

function SetBankPwdWidget:ctor(parentNode)
	SetBankPwdWidget.super.ctor(self)

	self:addTo(parentNode)
end

function SetBankPwdWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	SetBankPwdWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_BANK_SET_PWD_CSB_FILE)
    if not node then
        return
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Cancel")
    local okBtn = cc.uiloader:seekNodeByName(node, "Button_Ok")
    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgPwdBg = cc.uiloader:seekNodeByName(node, "Image_InputBg")
    local imgPwdBg2 = cc.uiloader:seekNodeByName(node, "Image_InputBg2")
    
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
    if imgPwdBg then
    	local sizeBg = imgPwdBg:getContentSize()
        self.PwdEditPwd = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_null.png",
                            x=sizeBg.width/2,
                            y=sizeBg.height/2,
                            size=cc.size(sizeBg.width*0.95,sizeBg.height*0.85) })
        self.PwdEditPwd:setInputFlag(0)
        self.PwdEditPwd:setFontColor(cc.c3b(83,75,68))
        self.PwdEditPwd:setFontSize(28)
        self.PwdEditPwd:setFontName("微软雅黑")
        self.PwdEditPwd:setPlaceHolder("点击输入设置的密码")
        self.PwdEditPwd:setPlaceholderFont("微软雅黑",28)
        self.PwdEditPwd:setMaxLength(32)
        imgPwdBg:addChild(self.PwdEditPwd)
    end
    if imgPwdBg2 then
    	local sizeBg = imgPwdBg2:getContentSize()
        self.PwdEditPwd2 = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_null.png",
                            x=sizeBg.width/2,
                            y=sizeBg.height/2,
                            size=cc.size(sizeBg.width*0.95,sizeBg.height*0.85) })
        self.PwdEditPwd2:setInputFlag(0)
        self.PwdEditPwd2:setFontColor(cc.c3b(83,75,68))
        self.PwdEditPwd2:setFontSize(28)
        self.PwdEditPwd2:setFontName("微软雅黑")
        self.PwdEditPwd2:setPlaceHolder("点击输入确认密码")
        self.PwdEditPwd2:setPlaceholderFont("微软雅黑",28)
        self.PwdEditPwd2:setMaxLength(32)
        imgPwdBg2:addChild(self.PwdEditPwd2)
    end
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function SetBankPwdWidget:onCleanup()
	SetBankPwdWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function SetBankPwdWidget:onOkBtnClicked()
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
	if tonumber(strPwd) ~= nil then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="密码不可以为纯数字，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    local strPwd2 = self.PwdEditPwd2:getText()
    if strPwd2 ~= strPwd then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="新密码与确认密码输入不一致，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end

    self.strDesPwd = strPwd

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

function SetBankPwdWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("SetBankPwdWidget bConnectSucc: 连接成功！")
        local CMD_GP_ModifyInsurePass = {
				dwUserID=GlobalUserInfo.dwUserID,
				szDesPassword=cc.Crypto:MD5(self.strDesPwd,false),
				szScrPassword=GlobalUserInfo.szPassword,
			}
			self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_MODIFY_INSURE_PASS, 
            	CMD_GP_ModifyInsurePass,"CMD_GP_ModifyInsurePass")
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

function SetBankPwdWidget:receiveShutDownMessage(Params)
   print("SetBankPwdWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function SetBankPwdWidget:onOperateSuccessMessage(Params)
    self:hideLoadingWidget()

    if self.missionItem then
        self.missionItem:onDisconnectSocket()
    end

    GlobalUserInfo.cbInsurePwd = 1
    if string.len(Params.szDescribeString) > 0 then
    	local strBankPwd = self.strDesPwd
    	local dataMsgBox = {
	        nodeParent=self:getParent(),
	        msgboxType=MSGBOX_TYPE_OK,
	        msgInfo=Params.szDescribeString,
	        callBack=function ()
	        	-- 进入银行
			    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
			            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_ShowBankWidget,
			            para = cc.Crypto:MD5(strBankPwd,false)
			        })
	        end
	    }
	    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    end
    
    -- 退出登录
    self:removeFromParent()
end

function SetBankPwdWidget:onOperateFailureMessage(Params)
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

return SetBankPwdWidget