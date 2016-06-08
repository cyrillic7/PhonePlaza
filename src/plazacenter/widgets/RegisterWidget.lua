--
-- Author: SuperM
-- Date: 2015-11-16 17:09:45
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local RegisterWidget = class("RegisterWidget", XWWidgetBase)

function RegisterWidget:ctor(parentNode,callBack)
	RegisterWidget.super.ctor(self)

	self.callBack = callBack

	self:addTo(parentNode)
end

function RegisterWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	RegisterWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_REGISTER_CSB_FILE)
    if not node then
        return
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Cancel")
    local okBtn = cc.uiloader:seekNodeByName(node, "Button_Ok")

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgAccountBg = cc.uiloader:seekNodeByName(node, "Image_AccountBg")
    local imgNickBg = cc.uiloader:seekNodeByName(node, "Image_NickBg")
    local imgPwdBg = cc.uiloader:seekNodeByName(node, "Image_PwdBg")
    local imgSpreadBg = cc.uiloader:seekNodeByName(node, "Image_SpreadBg")
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
    if imgAccountBg then
        self.AccountEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgAccountBg:getContentSize().width/2,
                            y=imgAccountBg:getContentSize().height/2,
                            size=imgAccountBg:getContentSize() })
        self.AccountEdit:setFontColor(cc.c3b(83,75,68))
        self.AccountEdit:setFontSize(28)
        self.AccountEdit:setFontName("微软雅黑")
        self.AccountEdit:setPlaceHolder("点击输入6~18个字符")
        self.AccountEdit:setPlaceholderFont("微软雅黑",28)
        self.AccountEdit:setMaxLength(32)
        imgAccountBg:addChild(self.AccountEdit)
    end
    if imgNickBg then
        self.NickEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgNickBg:getContentSize().width/2,
                            y=imgNickBg:getContentSize().height/2,
                            size=imgNickBg:getContentSize() })
        self.NickEdit:setFontColor(cc.c3b(83,75,68))
        self.NickEdit:setFontSize(28)
        self.NickEdit:setFontName("微软雅黑")
        self.NickEdit:setPlaceHolder("点击输入昵称")
        self.NickEdit:setPlaceholderFont("微软雅黑",28)
        self.NickEdit:setMaxLength(32)
        imgNickBg:addChild(self.NickEdit)
    end
    if imgPwdBg then
        self.PwdEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgPwdBg:getContentSize().width/2,
                            y=imgPwdBg:getContentSize().height/2,
                            size=imgPwdBg:getContentSize() })
        self.PwdEdit:setFontColor(cc.c3b(83,75,68))
        self.PwdEdit:setFontSize(28)
        self.PwdEdit:setFontName("微软雅黑")
        self.PwdEdit:setPlaceHolder("点击输入密码")
        self.PwdEdit:setPlaceholderFont("微软雅黑",28)
        self.PwdEdit:setMaxLength(32)
        imgPwdBg:addChild(self.PwdEdit)
    end
    if imgSpreadBg then
        self.SpreadEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgNickBg:getContentSize().width/2,
                            y=imgNickBg:getContentSize().height/2,
                            size=imgNickBg:getContentSize() })
        self.SpreadEdit:setFontColor(cc.c3b(83,75,68))
        self.SpreadEdit:setFontSize(28)
        self.SpreadEdit:setFontName("微软雅黑")
        self.SpreadEdit:setPlaceHolder("点击输入邀请码(选填)")
        self.SpreadEdit:setPlaceholderFont("微软雅黑",28)
        self.SpreadEdit:setMaxLength(31)
        imgSpreadBg:addChild(self.SpreadEdit)
    end
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function RegisterWidget:onCleanup()
	RegisterWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function RegisterWidget:onOkBtnClicked()
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

    local strNickName = self.NickEdit:getText()
    if string.len(strNickName) < 4 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="昵称长度过短(最低4个字节)，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end

    local strPwd= self.PwdEdit:getText()
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
    self.strAccount = strAccount
    self.strNickName = strNickName
    self.strPwd = strPwd
    if self.callBack then
    	math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
    	for i=1,10 do
            math.random(100000)
        end
    	local cbGender = math.round(math.random(10000))%2
    	local CMD_GP_RegisterAccounts = {
			dwPlazaVersion=GlobalPlatInfo.dwPlazaVersion,
			szMachineID=GlobalPlatInfo.szMachineID,
			szLogonPass=cc.Crypto:MD5(strPwd,false),
			szInsurePass=cc.Crypto:MD5(strPwd,false),
			wFaceID=math.round(math.random(10000))%8+((cbGender==1) and 8 or 0),
			cbGender=cbGender,
			szAccounts=strAccount,
			szNickName=strNickName,
			szSpreader=self.SpreadEdit:getText() or "",
			szPassPortID="",
			szCompellation="",
			cbValidateFlags=0,
		}
    	self.callBack(CMD_GP_RegisterAccounts)
    end
    self:removeFromParent()
end

function RegisterWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("RegisterWidget bConnectSucc: 连接成功！")
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

function RegisterWidget:receiveShutDownMessage(Params)
   print("RegisterWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function RegisterWidget:onFeedBackAckMessage(Params)
   print("RegisterWidget:onFeedBackAckMessage")
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

return RegisterWidget