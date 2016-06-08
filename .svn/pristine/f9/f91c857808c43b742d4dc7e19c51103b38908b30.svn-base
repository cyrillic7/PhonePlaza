--
-- Author: SuperM
-- Date: 2016-01-18 11:38:58
--

local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local CDKExchangeWidget = class("CDKExchangeWidget", XWWidgetBase)

function CDKExchangeWidget:ctor(parentNode)
    CDKExchangeWidget.super.ctor(self)

    self:addTo(parentNode)
end

function CDKExchangeWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
    CDKExchangeWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_CDK_EXCHANGE_CSB_FILE)
    if not node then
        return
    end

    local inputBg = cc.uiloader:seekNodeByName(node, "Image_InputBg")
    local buttonOK = cc.uiloader:seekNodeByName(node, "Button_Ok")
    local buttonCancel = cc.uiloader:seekNodeByName(node, "Button_Cancel")
    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")

    -- 创建输入框
    if inputBg then
        self.EditCDK = cc.ui.UIInput.new({
                image="#pic/plazacenter/Sundry/u_input_bg.png",
                x=inputBg:getContentSize().width/2,
                y=inputBg:getContentSize().height/2,
                size=inputBg:getContentSize() })
        self.EditCDK:setFontColor(cc.c3b(112,55,10))
        self.EditCDK:setFontSize(28)
        self.EditCDK:setFontName("微软雅黑")
        self.EditCDK:setPlaceHolder("点击输入兑换码")
        self.EditCDK:setPlaceholderFont("微软雅黑",28)
        self.EditCDK:setMaxLength(31) 
        inputBg:addChild(self.EditCDK)
    end

    self:buttonTouchEvent(buttonOK)
    buttonOK:onButtonClicked(function ()
        if string.len(self.EditCDK:getText())<1 then
            return
        end
        self.strCDK = self.EditCDK:getText()
        if not self.missionItem then
            self.missionItem = require("plazacenter.controllers.MissionItem").new(CLIENT_TYPE_LOGIN_POINT,"LoginServer_FeedBack")
            self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.receiveConnectMessage))
            self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.receiveShutDownMessage))
            self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_FRIEND_GIFT_CHANGE, handler(self, self.onFriendExchangeMessage))
        end
        if self.missionItem then
            self.missionItem.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
            self:showLoadingWidget()
            self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
        end
    end)
    self:buttonTouchEvent(buttonCancel)
    buttonCancel:onButtonClicked(function ()
        node:removeFromParent()
    end)

    self:addChild(node)
    G_ShowNodeWithBackout(bgnode)
end

function CDKExchangeWidget:onCleanup()
    CDKExchangeWidget.super.onCleanup(self)

    if self.missionItem then
        self.missionItem:removeServiceClient()
        self.missionItem = nil
    end
end

function CDKExchangeWidget:buttonTouchEvent(btn)
    if btn then
        btn:onButtonPressed(function ()
            btn:scaleTo(0.1,0.9)
        end)
        btn:onButtonRelease(function ()
            btn:scaleTo(0.1,1)
        end)
    end
end

function CDKExchangeWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("CDKExchangeWidget bConnectSucc: 连接成功！")
        local CMD_GP_FriendGiftChange = {
            dwUserID=GlobalUserInfo.dwUserID,
            szLogonPass=GlobalUserInfo.szPassword,
            szGiftChangeOrder=self.strCDK,
            dwOpTerminal=GlobalPlatInfo.dwTerminal,
        }
        self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_FRIEND_GIFT_CHANGE, CMD_GP_FriendGiftChange, "CMD_GP_FriendGiftChange")

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

function CDKExchangeWidget:receiveShutDownMessage(Params)
   print("CDKExchangeWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function CDKExchangeWidget:onFriendExchangeMessage(Params)
   print("CDKExchangeWidget:onFriendExchangeMessage")
   self:hideLoadingWidget()
   --local CMD_GP_FriendGiftChangeRet = {
   --     dwRet= ,
   --     szDescribeString="",
   -- }
   local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString,
        callBack=function ()
            -- 未绑定手机
            if Params.dwRet == 1 then
                require("plazacenter.widgets.MobileBindWidget").new(self:getParent(),function ()
            --        self:setVisible(true)
                end)
            end
            self:removeFromParent()
        end
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    if self.missionItem then
    	self.missionItem:onDisconnectSocket()
    end
end

return CDKExchangeWidget