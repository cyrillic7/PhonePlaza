--
-- Author: Your Name
-- Date: 2015-10-28 18:04:07
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local ModifyPwdWidget = class("ModifyPwdWidget", XWWidgetBase)

function ModifyPwdWidget:ctor(parentNode,callBack,bSafePwd)
	ModifyPwdWidget.super.ctor(self)

	self.callBack = callBack
    self.bSafePwd = bSafePwd

	self:addTo(parentNode)
end

function ModifyPwdWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	ModifyPwdWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_MODIFY_PWD_CSB_FILE)
    if not node then
        return
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Close")
    local okBtn = cc.uiloader:seekNodeByName(node, "Button_OK")
    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgOrgPwdBg = cc.uiloader:seekNodeByName(node, "Image_OrgPwdBg")
    local imgNewPwd1Bg = cc.uiloader:seekNodeByName(node, "Image_NewPwd1Bg")
    local imgNewPwd2Bg = cc.uiloader:seekNodeByName(node, "Image_NewPwd2Bg")

    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
    		self.callBack()
    		self:removeFromParent()
    	end)    	
    end
    if okBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(okBtn)
    	okBtn:onButtonClicked(function ()
    		self:onOkBtnClicked()
    	end) 
    end
    if imgOrgPwdBg then
        self.OrgPwdEditPwd = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgOrgPwdBg:getContentSize().width/2,
                            y=imgOrgPwdBg:getContentSize().height/2,
                            size=imgOrgPwdBg:getContentSize() })
        self.OrgPwdEditPwd:setInputFlag(0)
        self.OrgPwdEditPwd:setFontColor(cc.c3b(83,75,68))
        self.OrgPwdEditPwd:setFontSize(28)
        self.OrgPwdEditPwd:setFontName("微软雅黑")
        self.OrgPwdEditPwd:setPlaceHolder("点击输入旧密码")
        self.OrgPwdEditPwd:setPlaceholderFont("微软雅黑",28)
        self.OrgPwdEditPwd:setMaxLength(32)
        imgOrgPwdBg:addChild(self.OrgPwdEditPwd)
    end
    if imgNewPwd1Bg then
        self.NewPwd1EditPwd = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgNewPwd1Bg:getContentSize().width/2,
                            y=imgNewPwd1Bg:getContentSize().height/2,
                            size=imgNewPwd1Bg:getContentSize() })
        self.NewPwd1EditPwd:setInputFlag(0)
        self.NewPwd1EditPwd:setFontColor(cc.c3b(83,75,68))
        self.NewPwd1EditPwd:setFontSize(28)
        self.NewPwd1EditPwd:setFontName("微软雅黑")
        self.NewPwd1EditPwd:setPlaceHolder("点击输入新密码")
        self.NewPwd1EditPwd:setPlaceholderFont("微软雅黑",28)
        self.NewPwd1EditPwd:setMaxLength(32)
        imgNewPwd1Bg:addChild(self.NewPwd1EditPwd)
    end
    if imgNewPwd2Bg then
        self.NewPwd2EditPwd = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgNewPwd2Bg:getContentSize().width/2,
                            y=imgNewPwd2Bg:getContentSize().height/2,
                            size=imgNewPwd2Bg:getContentSize() })
        self.NewPwd2EditPwd:setInputFlag(0)
        self.NewPwd2EditPwd:setFontColor(cc.c3b(83,75,68))
        self.NewPwd2EditPwd:setFontSize(28)
        self.NewPwd2EditPwd:setFontName("微软雅黑")
        self.NewPwd2EditPwd:setPlaceHolder("点击输入确认密码")
        self.NewPwd2EditPwd:setPlaceholderFont("微软雅黑",28)
        self.NewPwd2EditPwd:setMaxLength(32)
        imgNewPwd2Bg:addChild(self.NewPwd2EditPwd)
    end
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function ModifyPwdWidget:onCleanup()
	ModifyPwdWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function ModifyPwdWidget:onOkBtnClicked()
    local strOrgPwd = self.OrgPwdEditPwd:getText()
	if string.len(strOrgPwd) < 8 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="旧密码长度过短(最低8位)，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
		return
	end

    local strNewPwd1 = self.NewPwd1EditPwd:getText()
    if string.len(strNewPwd1) < 8 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="新密码长度过短(最低8位)，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    if tonumber(strNewPwd1) ~= nil then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="密码不可以为纯数字，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end

    local strNewPwd2 = self.NewPwd2EditPwd:getText()
    if string.len(strNewPwd2) < 8 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="确认密码长度过短(最低8位)，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    if strNewPwd2 ~= strNewPwd1 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="新密码与确认密码输入不一致，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    if cc.Crypto:MD5(strOrgPwd,false) ~= GlobalUserInfo.szPassword then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="旧密码错误，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    if strOrgPwd == strNewPwd1 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="您所输入的新密码与原密码一致，请重新输入新密码！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    self.strOrgPwd = strOrgPwd
    self.strDesPwd = strNewPwd1

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

function ModifyPwdWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("ModifyPwdWidget bConnectSucc: 连接成功！")
        local modifyPassWord = {
            dwUserID=GlobalUserInfo.dwUserID,
            szDesPassword=cc.Crypto:MD5(self.strDesPwd,false),
            szScrPassword=cc.Crypto:MD5(self.strOrgPwd,false),
        }
        local subCmdID = SUB_GP_MODIFY_LOGON_PASS
        if self.bSafePwd then
            subCmdID = SUB_GP_MODIFY_INSURE_PASS
        end
        self.missionItem:requestCommand(MDM_GP_USER_SERVICE, subCmdID, modifyPassWord)
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

function ModifyPwdWidget:receiveShutDownMessage(Params)
   print("ModifyPwdWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function ModifyPwdWidget:onOperateSuccessMessage(Params)
    self:hideLoadingWidget()

    self.OrgPwdEditPwd:setText("")
    self.NewPwd1EditPwd:setText("")
    self.NewPwd2EditPwd:setText("")
    if not self.bSafePwd then
        GlobalUserInfo.szPassword = cc.Crypto:MD5(self.strDesPwd,false)
        SessionManager:sharedManager():setLastAcount({acount=GlobalUserInfo.szAccounts,password=GlobalUserInfo.szPassword})
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

function ModifyPwdWidget:onOperateFailureMessage(Params)
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

return ModifyPwdWidget