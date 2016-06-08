--
-- Author: Your Name
-- Date: 2015-10-27 15:57:58
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local FeedBackWidget = class("FeedBackWidget", XWWidgetBase)

function FeedBackWidget:ctor(parentNode,callBack)
	FeedBackWidget.super.ctor(self)

	self.callBack = callBack

	self:addTo(parentNode)
end

function FeedBackWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	FeedBackWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_HALL_FEEDBACK_CSB_FILE)
    if not node then
        return
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Close")
    local sendBtn = cc.uiloader:seekNodeByName(node, "Button_Send")

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local textAdvice = cc.uiloader:seekNodeByName(node, "TextField_Advice")
    local textEmail = cc.uiloader:seekNodeByName(node, "TextField_Email")
    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
    		self.callBack()
    		self:removeFromParent()
    	end)    	
    end
    if sendBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(sendBtn)
    	sendBtn:onButtonClicked(function ()
    		self:onSendBtnClicked()
    	end) 
    end
    if textEmail then
    	textEmail:setTextColor(cc.c4b(83,75,68,255))
    	self.textEmail = textEmail
    end
    if textAdvice then
    	textAdvice:setTextColor(cc.c4b(83,75,68,255))
    	self.textAdvice = textAdvice
    end
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function FeedBackWidget:onCleanup()
	FeedBackWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function FeedBackWidget:onSendBtnClicked()
	if string.len(self.textAdvice:getString()) < 4 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="反馈内容过短，请重新输入。谢谢您的合作！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
		return
	end
	if not self.missionItem then
		self.missionItem = require("plazacenter.controllers.MissionItem").new(CLIENT_TYPE_LOGIN_POINT,"LoginServer_FeedBack")
		self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.receiveConnectMessage))
	    self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.receiveShutDownMessage))
	    self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_FEEDBACK, handler(self, self.onFeedBackAckMessage))
	end
	if self.missionItem then
		self.missionItem.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
        self:showLoadingWidget()
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
	end
end

function FeedBackWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("FeedBackWidget bConnectSucc: 连接成功！")
        local CMD_GP_Feedback = {
			szAccounts=GlobalUserInfo.szAccounts,
			szTitle="",
			szQQ=self.textEmail:getString(),
			szContent=self.textAdvice:getString(),
		}
        self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_FEEDBACK, CMD_GP_Feedback, "CMD_GP_Feedback")

        self.textAdvice:setString("")
        self.textEmail:setString("")
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

function FeedBackWidget:receiveShutDownMessage(Params)
   print("FeedBackWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function FeedBackWidget:onFeedBackAckMessage(Params)
   print("FeedBackWidget:onFeedBackAckMessage")
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

return FeedBackWidget