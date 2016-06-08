--
-- Author: Your Name
-- Date: 2015-11-02 15:37:08
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local RealNameAuthWidget = class("RealNameAuthWidget", XWWidgetBase)

function RealNameAuthWidget:ctor(parentNode,callBack)
	RealNameAuthWidget.super.ctor(self)

	self.callBack = callBack

	self:addTo(parentNode)
end

function RealNameAuthWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	RealNameAuthWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_REAL_NAME_AUTH_CSB_FILE)
    if not node then
        return
    end

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local panelNotBind = cc.uiloader:seekNodeByName(node, "Panel_NotBind")
    local panelBinded = cc.uiloader:seekNodeByName(node, "Panel_Binded")
    -- 未绑定
    if GlobalUserInfo.cbMoorPassPortID == 0 then
        panelNotBind:setVisible(true)
        panelBinded:setVisible(false)

        local okBtn = cc.uiloader:seekNodeByName(panelNotBind, "Button_Ok")
        local cancelBtn = cc.uiloader:seekNodeByName(panelNotBind, "Button_Cancel")
        local imgNameBg = cc.uiloader:seekNodeByName(node, "Image_NameBg")
        local imgNumberBg = cc.uiloader:seekNodeByName(node, "Image_NumberBg")

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
        if imgNumberBg then
            self.NumberEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                                x=imgNumberBg:getContentSize().width/2,
                                y=imgNumberBg:getContentSize().height/2,
                                size=imgNumberBg:getContentSize() })
            self.NumberEdit:setInputMode(3)
            self.NumberEdit:setFontColor(cc.c3b(83,75,68))
            self.NumberEdit:setFontSize(28)
            self.NumberEdit:setFontName("微软雅黑")
            self.NumberEdit:setPlaceHolder("点击输入身份证号")
            self.NumberEdit:setPlaceholderFont("微软雅黑",28)
            self.NumberEdit:setMaxLength(18)
            imgNumberBg:addChild(self.NumberEdit)
        end
        if imgNameBg then
            self.NameEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                                x=imgNameBg:getContentSize().width/2,
                                y=imgNameBg:getContentSize().height/2,
                                size=imgNameBg:getContentSize() })
            self.NameEdit:setFontColor(cc.c3b(83,75,68))
            self.NameEdit:setFontSize(28)
            self.NameEdit:setFontName("微软雅黑")
            self.NameEdit:setPlaceHolder("点击输入姓名")
            self.NameEdit:setPlaceholderFont("微软雅黑",28)
            self.NameEdit:setMaxLength(8)
            imgNameBg:addChild(self.NameEdit)
        end
    else -- 已绑定
        panelNotBind:setVisible(false)
        panelBinded:setVisible(true)
    end

    local closeBtn = cc.uiloader:seekNodeByName(panelBinded, "Button_Close")
    local LabelNumber = cc.uiloader:seekNodeByName(panelBinded, "Label_AuthNumber")
    if closeBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
        closeBtn:onButtonClicked(function ()
            self.callBack()
            self:removeFromParent()
        end)            
    end
    if LabelNumber then
        LabelNumber:setString(GlobalUserInfo.szPassPortID)
    end
    -- 保存变量，方便绑定成功后，切换切面
    self.panelNotBind = panelNotBind
    self.panelBinded = panelBinded
    self.LabelNumber = LabelNumber

    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function RealNameAuthWidget:onCleanup()
	RealNameAuthWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function RealNameAuthWidget:onOkBtnClicked()
    local strRealName = self.NameEdit:getText()
    if string.len(strRealName) < 4 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="请输入正确的真实姓名！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    local strNumber = self.NumberEdit:getText()
    local bSucc,strDesc = G_EfficacyPassPortID(strNumber)
    if not bSucc then
    	local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo=strDesc
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end

    self:connectLoginServer(self.MOBILE_BIND)
    self.strRealName = strRealName
    self.strNumber = strNumber
end

function RealNameAuthWidget:connectLoginServer(missionType)
    self.MissionType = missionType

    if not self.missionItem then
        self.missionItem = require("plazacenter.controllers.MissionItem").new(CLIENT_TYPE_LOGIN_POINT,"LoginServer_MobileBind")
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

function RealNameAuthWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("RealNameAuthWidget bConnectSucc: 连接成功！")
        local request = {}
        local CMD_GP_ModifyPassPortID = {
			cbBind=GlobalUserInfo.cbMoorPassPortID,
			dwUserID=GlobalUserInfo.dwUserID,
			szPassword=GlobalUserInfo.szPassword,
			szMachineID=GlobalPlatInfo.szMachineID,
			szName=self.strRealName,
			szPassPortID=self.strNumber
		}
		if CMD_GP_ModifyPassPortID.cbBind == 0 then
			CMD_GP_ModifyPassPortID.cbBind = 1
		else
			CMD_GP_ModifyPassPortID.cbBind = 0
		end
        
        self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_MODIFY_PASSPORT_ID, CMD_GP_ModifyPassPortID,"CMD_GP_ModifyPassPortID")
        
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

function RealNameAuthWidget:receiveShutDownMessage(Params)
   print("RealNameAuthWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function RealNameAuthWidget:onOperateSuccessMessage(Params)
    self:hideLoadingWidget()

    if string.find(Params.szDescribeString,"身份证") then
    	GlobalUserInfo.cbMoorPassPortID = 1
    	GlobalUserInfo.szPassPortID = string.sub(self.strNumber,1,6).."*******"..string.sub(self.strNumber,14)

        self.panelNotBind:setVisible(false)
        self.panelBinded:setVisible(true)
        self.LabelNumber:setString(GlobalUserInfo.szPassPortID)

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

function RealNameAuthWidget:onOperateFailureMessage(Params)
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


return RealNameAuthWidget