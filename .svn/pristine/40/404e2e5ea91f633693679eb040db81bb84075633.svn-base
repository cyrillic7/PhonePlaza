--
-- Author: SuperM
-- Date: 2016-02-19 15:03:55
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local ServerBankWidget = class("ServerBankWidget", XWWidgetBase)

ServerBankWidget.BANKTELLER = 1
ServerBankWidget.BANKSAVE = 2
ServerBankWidget.BANKTRANSFER = 3
ServerBankWidget.BANKINSUREPWD = 4
ServerBankWidget.BANKTRANLOG = 5
ServerBankWidget.BANKQUERYINSURE = 6

-- option type
ServerBankWidget.OptType={
	{index="Stroe",picName="deposit"},
	{index="TakeOut",picName="takeout"},
	{index="Transfer",picName="giving"},
	{index="ModifyPwd",picName="amend"},
}

function ServerBankWidget:ctor(parentNode,szInsureOrgPwd,callBack,missionItem)
	ServerBankWidget.super.ctor(self)

	self.szInsureOrgPwd = szInsureOrgPwd
	self.callBack = callBack
    self.MissionType = self.BANKQUERYINSURE
    self.widgetType = "HallBankWidget"
    self.missionItem = missionItem

    self.InsureInfo = {
    	wRevenueTake=0,			--税收比例
		wRevenueTransfer=0,		--税收比例
		wServerID=0,			--房间标识
		lUserScore=0,			--用户游戏币
		lUserInsure=0,			--银行游戏币
		lTransferPrerequisite=0,--转账条件
		lIngotScore=0,          --用户元宝
		lUserLoveliness=0,      --用户魅力  
	}

	self:addTo(parentNode)
end

function ServerBankWidget:registerResponseHandlers()
	if self.missionItem then
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GR_INSURE, SUB_GR_USER_INSURE_INFO, handler(self, self.onGetInsureInfoMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GR_INSURE, SUB_GR_USER_INSURE_SUCCESS, handler(self, self.onGetInsureSuccessMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GR_INSURE, SUB_GR_USER_INSURE_FAILURE, handler(self, self.onGetInsureFailureMessage))
        self.missionItem.scriptHandler:registerResponseHandler(MDM_GR_INSURE, SUB_GR_USER_TRANSFER_USER_INFO, handler(self, self.onGetUserInfoResultMessage))
	end
end

function ServerBankWidget:unRegisterResponseHandlers()
	if self.missionItem then
        self.missionItem.scriptHandler:unregisterResponseHandler(MDM_GR_INSURE, SUB_GR_USER_INSURE_INFO)
        self.missionItem.scriptHandler:unregisterResponseHandler(MDM_GR_INSURE, SUB_GR_USER_INSURE_SUCCESS)
        self.missionItem.scriptHandler:unregisterResponseHandler(MDM_GR_INSURE, SUB_GR_USER_INSURE_FAILURE)
        self.missionItem.scriptHandler:unregisterResponseHandler(MDM_GR_INSURE, SUB_GR_USER_TRANSFER_USER_INFO)
	end
end

function ServerBankWidget:onEnter()
	self:registerResponseHandlers()
    if not self.bFirstEnter then
        return
    end
	ServerBankWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_HALL_BANK_CSB_FILE)
    if not node then
        return
    end
    node:setTouchEnabled(false)

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgLeftArea = cc.uiloader:seekNodeByName(node, "Image_Left")
    local panelStoreOrOut = cc.uiloader:seekNodeByName(node, "Panel_StoreOrTakeOut")
    local panelTransfer = cc.uiloader:seekNodeByName(node, "Panel_Transfer")
    local panelModifyPwd = cc.uiloader:seekNodeByName(node, "Panel_ModifyPwd")

    local closeBtn = cc.uiloader:seekNodeByName(bgnode, "Button_Close")
    self:initStoreOrTakeOut(panelStoreOrOut)
    self:initTransfer(panelTransfer)
    self:initModifyPwd(panelModifyPwd)
    self:initMainOptions(imgLeftArea)

    if closeBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
        closeBtn:onButtonClicked(function ()
            self.callBack()
            self:removeFromParent()
        end) 
    end

    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)

    self:PerformQueryInfo()
end

function ServerBankWidget:onExit()
	ServerBankWidget.super.onExit(self)

	self:unRegisterResponseHandlers()
end
function ServerBankWidget:onCleanup()
	ServerBankWidget.super.onCleanup(self)
end

function ServerBankWidget:cleanPlistRes()
	print("ServerBankWidget:cleanPlistRes")
    display.removeSpriteFramesWithFile("UIHallBank.plist", "UIHallBank.png")
end

function ServerBankWidget:getFormatNumberStr(number)
	local strNumber = string.gsub(string.formatnumberthousands(number), ",", ":")
	return strNumber
end
function ServerBankWidget:SwitchScoreString(lScore)
	local pszNumber = {"零","壹","贰","叁","肆","伍","陆","柒","捌","玖"}
	local pszWeiName = {"拾","佰","仟","万","拾","佰","仟","亿","拾","佰","仟","万"}
	local szSwitchScore = checknumber(lScore)
	local bNeedFill = false
	local bNeedZero = false
	local uSwitchLength = string.len(szSwitchScore)
	local szReturn = ""
	for i=1,uSwitchLength do
		local wNumberIndex = string.byte(szSwitchScore,i) - string.byte("0")
		-- 补零操作
		if bNeedZero and wNumberIndex ~= 0 then
			bNeedZero=false
			szReturn = szReturn..pszNumber[1]
		end
		-- 拷贝数字
		if wNumberIndex ~= 0 then
			szReturn = szReturn..pszNumber[wNumberIndex+1]
		end
		-- 拷贝位名
		if wNumberIndex ~= 0 and uSwitchLength-i > 0 then
			bNeedZero=false
			szReturn = szReturn..pszWeiName[uSwitchLength-i]
		end
		-- 补零判断
		if not bNeedZero and wNumberIndex == 0 then
			bNeedZero=true
		end

		-- 补位判断
		if not bNeedFill and wNumberIndex ~= 0 then
			bNeedFill=true
		end

		-- 填补位名
		if (uSwitchLength-i) == 4 or (uSwitchLength-i)==8 then
			-- 拷贝位名
			if bNeedFill and wNumberIndex == 0 then
				szReturn = szReturn..pszWeiName[uSwitchLength-i]
			end

			--设置变量
			bNeedZero = false
			bNeedFill = false
		end
	end

	return szReturn
end
function ServerBankWidget:updateGoldEditAndUpperCase(edit,labUppser,number)
	if not edit or not labUppser then
		return
	end
	number = number or 0
	if number < 1 then
		edit:setText("")
		labUppser:setString("")
	else
		edit:setText(string.formatnumberthousands(number))
		labUppser:setString(self:SwitchScoreString(number))	
	end
	edit.number = number > 0 and number or nil
end

function ServerBankWidget:updateStorePanel()
	if self.st_labelGoldName then
		self.st_labelGoldName:setString("账户金币：")
	end
	if self.st_labelDirectName then
		self.st_labelDirectName:setString("存入金币：")
	end
	if self.st_labelHaveGold then
		self.st_labelHaveGold:setString(self:getFormatNumberStr(GlobalUserInfo.lUserScore))
	end
	if self.imgStoreOrOutText then
		self.imgStoreOrOutText:setSpriteFrame("pic/plazacenter/Bank/u_safe_text_cr.png")
	end
	self:updateGoldEditAndUpperCase(self.st_GoldEdit,self.st_labelUpperCase,0)
end

function ServerBankWidget:updateTakeOutPanel()
	if self.st_labelGoldName then
		self.st_labelGoldName:setString("银行存款：")
	end
	if self.st_labelDirectName then
		self.st_labelDirectName:setString("取出金额：")
	end
	if self.st_labelHaveGold then
		self.st_labelHaveGold:setString(self:getFormatNumberStr(GlobalUserInfo.lUserInsure))
	end
	if self.imgStoreOrOutText then
		self.imgStoreOrOutText:setSpriteFrame("pic/plazacenter/Bank/u_safe_text_qc.png")
	end
	self:updateGoldEditAndUpperCase(self.st_GoldEdit,self.st_labelUpperCase,0)
end

function ServerBankWidget:updateTransferPanel()
	if self.tr_labelBankGold then
		self.tr_labelBankGold:setString(self:getFormatNumberStr(GlobalUserInfo.lUserInsure))
	end
	self:updateGoldEditAndUpperCase(self.tr_GoldEdit,self.tr_labelUpperCase,0)
end

function ServerBankWidget:updateModifyPanel()
	-- body
end

function ServerBankWidget:updateWidgetData()
	if self.group and self.group.currentSelectedIndex_ > 0 then
		local selectedIndex = self.group.currentSelectedIndex_
		
		if selectedIndex == 1 then -- 存入金币
			self:updateStorePanel()
		elseif selectedIndex == 2 then -- 取出金币
			self:updateTakeOutPanel()
		elseif selectedIndex == 3 then -- 赠送
			self:updateTransferPanel()
		elseif selectedIndex == 4 then -- 修改密码
			self:updateModifyPanel()
		end
	end
end

function ServerBankWidget:onOptionsSelectChanged(event)
	local index = event.selected
	if self._storeOrOutPanel then
		self._storeOrOutPanel:setVisible(index == 1 or index == 2)
	end
	if self._transferPanel then
		self._transferPanel:setVisible(index == 3)
	end
	if self._modifyPwdPanel then
		self._modifyPwdPanel:setVisible(index == 4)
		if index == 4 then
			local dataMsgBox = {
	            nodeParent=self,
	            msgboxType=MSGBOX_TYPE_OK,
	            msgInfo="在游戏房间禁止密码修改操作，请退出游戏房间后再进行操作！"
	        }
	        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
			return
		end
	end
	self:updateWidgetData()
end

function ServerBankWidget:onEdit(event, editbox)
    if event == "changed" then
    	
    elseif event == "began" then
    	if editbox.number then
    		editbox:setText(tostring(editbox.number))
    	end
    elseif event == "ended" then
    	local gold = checknumber(editbox:getText())
    	-- 赠送输入金币变化
    	if editbox == self.tr_GoldEdit then    		
    		if gold > GlobalUserInfo.lUserInsure then
    			gold = GlobalUserInfo.lUserInsure
    		end
    		self:updateGoldEditAndUpperCase(editbox,self.tr_labelUpperCase,gold)
    	-- 存入取出金币变化
    	elseif editbox == self.st_GoldEdit then
    		-- 存入
    		if self.group.currentSelectedIndex_ == 1 then
    			if gold > GlobalUserInfo.lUserScore then
    				gold = GlobalUserInfo.lUserScore
    			end
    		-- 取出
    		elseif self.group.currentSelectedIndex_ == 2 then
    			if gold > GlobalUserInfo.lUserInsure then
	    			gold = GlobalUserInfo.lUserInsure
	    		end
    		end
    		self:updateGoldEditAndUpperCase(editbox,self.st_labelUpperCase,gold)
    	end
    	if editbox.number then
    		editbox:setText(string.formatnumberthousands(editbox.number))
    	end
    end
end

function ServerBankWidget:createMainOption(optType)
	local images={
		off={"#pic/plazacenter/Bank/u_safe_paging_btn.png",
			 "#pic/plazacenter/Bank/u_safe_text_"..optType.picName.."2.png"},
		off_pressed={"#pic/plazacenter/Bank/u_safe_paging_btn_press.png",
			 "#pic/plazacenter/Bank/u_safe_text_"..optType.picName..".png"},
		on={"#pic/plazacenter/Bank/u_safe_paging_btn_press.png",
			 "#pic/plazacenter/Bank/u_safe_text_"..optType.picName..".png"},
	}
	local gameTypeOption = cc.ui.UICheckBoxButton.new(images)
	gameTypeOption.optType = optType
	return gameTypeOption
end
function ServerBankWidget:initMainOptions(parentNode)
	if parentNode then
		-- 创建CheckBoxGroup
		local optionSize = parentNode:getContentSize()
		self.group = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        self.group:align(display.LEFT_TOP, 0, optionSize.height)
		self.group:onButtonSelectChanged(handler(self, self.onOptionsSelectChanged))
		for k,v in pairs(self.OptType) do
			self.group:addButton(self:createMainOption(v))
		end
        self.group:setContentSize(optionSize)
        self.group:setLayoutSize(optionSize.width,optionSize.height)
		self.group:setButtonsLayoutMargin(0,0,36,0)
        self.group:getButtonAtIndex(1):setButtonSelected(true)
        parentNode:addChild(self.group)
        -- 禁用修改密码
        --self.group:getButtonAtIndex(4):setButtonEnabled(false)
        self.group:getButtonAtIndex(4):setColor(cc.c3b(166, 166, 166))
	end
end

function ServerBankWidget:initStoreOrTakeOut(parentNode)
	if parentNode then
		self._storeOrOutPanel = parentNode
		self.st_labelGoldName = cc.uiloader:seekNodeByName(parentNode, "Label_GoldName")
		self.st_labelDirectName = cc.uiloader:seekNodeByName(parentNode, "Label_DirectName")
		self.st_labelUpperCase = cc.uiloader:seekNodeByName(parentNode, "Label_UpperCase")
		self.st_labelHaveGold = cc.uiloader:seekNodeByName(parentNode, "AtlasLabel_HaveGold")
		self.imgStoreOrOutText = cc.uiloader:seekNodeByName(parentNode, "Image_StoreOrOut")

		local imgGoldEditBg = cc.uiloader:seekNodeByName(parentNode, "Image_GoldEditBg")
		local allGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_AllGold")
		local _100WGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_100WGold")
		local _500WGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_500WGold")
		local _1000WGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_1000WGold")
		local _5000WGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_5000WGold")
		local _1WWGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_1WWGold")
		local storeOrOutBtn = cc.uiloader:seekNodeByName(parentNode, "Button_OK_StoreOrOut")
		if imgGoldEditBg then
			self.st_GoldEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                                x=imgGoldEditBg:getContentSize().width/2,
                                y=imgGoldEditBg:getContentSize().height/2,
                                size=imgGoldEditBg:getContentSize(),
                                listener=handler(self, self.onEdit)})
            self.st_GoldEdit:setInputMode(3)
            self.st_GoldEdit:setFontColor(cc.c3b(83,75,68))
            self.st_GoldEdit:setFontSize(28)
            self.st_GoldEdit:setFontName("微软雅黑")
            self.st_GoldEdit:setPlaceHolder("点击输入金币")
        	self.st_GoldEdit:setPlaceholderFont("微软雅黑",28)
            --self.st_GoldEdit:setMaxLength(11)
            imgGoldEditBg:addChild(self.st_GoldEdit)
		end
		if allGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(allGoldBtn)
	    	allGoldBtn:onButtonClicked(function ()
	    		self:onStoreOrOutGoldQuickBtnClicked(-1)
	    	end)
		end
		if _100WGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(_100WGoldBtn)
	    	_100WGoldBtn:onButtonClicked(function ()
	    		self:onStoreOrOutGoldQuickBtnClicked(1000000)
	    	end)
		end
		if _500WGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(_500WGoldBtn)
	    	_500WGoldBtn:onButtonClicked(function ()
	    		self:onStoreOrOutGoldQuickBtnClicked(5000000)
	    	end)
		end
		if _1000WGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(_1000WGoldBtn)
	    	_1000WGoldBtn:onButtonClicked(function ()
	    		self:onStoreOrOutGoldQuickBtnClicked(10000000)
	    	end)
		end
		if _5000WGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(_5000WGoldBtn)
	    	_5000WGoldBtn:onButtonClicked(function ()
	    		self:onStoreOrOutGoldQuickBtnClicked(50000000)
	    	end)
		end
		if _1WWGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(_1WWGoldBtn)
	    	_1WWGoldBtn:onButtonClicked(function ()
	    		self:onStoreOrOutGoldQuickBtnClicked(100000000)
	    	end)
		end
		if storeOrOutBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(storeOrOutBtn)
	    	storeOrOutBtn:onButtonClicked(function ()
	    		self:onStoreOrTakeOutBtnClicked()
	    	end)
		end
	end
end

function ServerBankWidget:initTransfer(parentNode)
	if parentNode then
		self._transferPanel = parentNode
		self.tr_labelBankGold = cc.uiloader:seekNodeByName(parentNode, "AtlasLabel_BankGold")
		self.tr_labelUpperCase = cc.uiloader:seekNodeByName(parentNode, "Label_UpperCase")
		self.tr_CheckBoxID = cc.uiloader:seekNodeByName(parentNode, "CheckBox_GameID")
    	self.tr_CheckBoxNick = cc.uiloader:seekNodeByName(parentNode, "CheckBox_UserNick")
    	if self.tr_CheckBoxID then
	        self.tr_CheckBoxID:setButtonSelected(true)
	        self.tr_CheckBoxID:onButtonClicked(function ()
	        	self:onCheckBoxClicked(self.tr_CheckBoxID,self.tr_CheckBoxNick)
	        end)
	    end
	    if self.tr_CheckBoxNick then
	        self.tr_CheckBoxNick:setButtonSelected(false)
	        self.tr_CheckBoxNick:onButtonClicked(function ()
	        	self:onCheckBoxClicked(self.tr_CheckBoxNick,self.tr_CheckBoxID)
	        end)
	    end

		local imgUserEditBg = cc.uiloader:seekNodeByName(parentNode, "Image_DesUserEditBg")
		local imgGoldEditBg = cc.uiloader:seekNodeByName(parentNode, "Image_GoldEditBg")
		local allGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_AllGold")
		local _100WGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_100WGold")
		local _500WGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_500WGold")
		local _1000WGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_1000WGold")
		local _5000WGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_5000WGold")
		local _1WWGoldBtn = cc.uiloader:seekNodeByName(parentNode, "Button_1WWGold")
		local okTransferBtn = cc.uiloader:seekNodeByName(parentNode, "Button_OK_Transfer")
		if imgUserEditBg then
			self.tr_UserEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                                x=imgUserEditBg:getContentSize().width/2,
                                y=imgUserEditBg:getContentSize().height/2,
                                size=imgUserEditBg:getContentSize() })
            --self.tr_UserEdit:setInputMode(3)
            self.tr_UserEdit:setFontColor(cc.c3b(83,75,68))
            self.tr_UserEdit:setFontSize(28)
            self.tr_UserEdit:setFontName("微软雅黑")
            self.tr_UserEdit:setPlaceHolder("点击输入用户ID或昵称")
        	self.tr_UserEdit:setPlaceholderFont("微软雅黑",28)
            --self.tr_UserEdit:setMaxLength(11)
            imgUserEditBg:addChild(self.tr_UserEdit)
		end
		if imgGoldEditBg then
			self.tr_GoldEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                                x=imgGoldEditBg:getContentSize().width/2,
                                y=imgGoldEditBg:getContentSize().height/2,
                                size=imgGoldEditBg:getContentSize(),                                
                                listener=handler(self, self.onEdit)})
            self.tr_GoldEdit:setInputMode(3)
            self.tr_GoldEdit:setFontColor(cc.c3b(83,75,68))
            self.tr_GoldEdit:setFontSize(28)
            self.tr_GoldEdit:setFontName("微软雅黑")
            self.tr_GoldEdit:setPlaceHolder("点击输入金额")
        	self.tr_GoldEdit:setPlaceholderFont("微软雅黑",28)
            --self.tr_GoldEdit:setMaxLength(11)
            imgGoldEditBg:addChild(self.tr_GoldEdit)
		end
		if allGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(allGoldBtn)
	    	allGoldBtn:onButtonClicked(function ()
	    		self:onTransferGoldQuickBtnClicked(-1)
	    	end)
		end
		if _100WGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(_100WGoldBtn)
	    	_100WGoldBtn:onButtonClicked(function ()
	    		self:onTransferGoldQuickBtnClicked(1000000)
	    	end)
		end
		if _500WGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(_500WGoldBtn)
	    	_500WGoldBtn:onButtonClicked(function ()
	    		self:onTransferGoldQuickBtnClicked(5000000)
	    	end)
		end
		if _1000WGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(_1000WGoldBtn)
	    	_1000WGoldBtn:onButtonClicked(function ()
	    		self:onTransferGoldQuickBtnClicked(10000000)
	    	end)
		end
		if _5000WGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(_5000WGoldBtn)
	    	_5000WGoldBtn:onButtonClicked(function ()
	    		self:onTransferGoldQuickBtnClicked(50000000)
	    	end)
		end
		if _1WWGoldBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(_1WWGoldBtn)
	    	_1WWGoldBtn:onButtonClicked(function ()
	    		self:onTransferGoldQuickBtnClicked(100000000)
	    	end)
		end
		if okTransferBtn then
			AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(okTransferBtn)
	    	okTransferBtn:onButtonClicked(function ()
	    		self:onOkTransferBtnClicked()
	    	end)
		end
	end
end

function ServerBankWidget:initModifyPwd(parentNode)
	if parentNode then
		self._modifyPwdPanel = parentNode
		local okBtn = cc.uiloader:seekNodeByName(parentNode, "Button_OK_PWD")
	    local imgOrgPwdBg = cc.uiloader:seekNodeByName(parentNode, "Image_OrgPwdBg")
	    local imgNewPwd1Bg = cc.uiloader:seekNodeByName(parentNode, "Image_NewPwd1Bg")
	    local imgNewPwd2Bg = cc.uiloader:seekNodeByName(parentNode, "Image_NewPwd2Bg")

	    if okBtn then
	    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(okBtn)
	    	okBtn:onButtonClicked(function ()
	    		self:onModifyPwdOkBtnClicked()
	    	end) 
	    	okBtn:setButtonEnabled(false)
	    	okBtn:setColor(cc.c3b(166, 166, 166))
	    end
	    if imgOrgPwdBg then
	        self.mp_OrgPwdEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
	                            x=imgOrgPwdBg:getContentSize().width/2,
	                            y=imgOrgPwdBg:getContentSize().height/2,
	                            size=imgOrgPwdBg:getContentSize() })
	        self.mp_OrgPwdEdit:setInputFlag(0)
	        self.mp_OrgPwdEdit:setFontColor(cc.c3b(83,75,68))
	        self.mp_OrgPwdEdit:setFontSize(28)
	        self.mp_OrgPwdEdit:setFontName("微软雅黑")
	        self.mp_OrgPwdEdit:setPlaceHolder("点击输入旧密码")
        	self.mp_OrgPwdEdit:setPlaceholderFont("微软雅黑",28)
	        self.mp_OrgPwdEdit:setMaxLength(32)
	        imgOrgPwdBg:addChild(self.mp_OrgPwdEdit)
	    end
	    if imgNewPwd1Bg then
	        self.mp_NewPwd1Edit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
	                            x=imgNewPwd1Bg:getContentSize().width/2,
	                            y=imgNewPwd1Bg:getContentSize().height/2,
	                            size=imgNewPwd1Bg:getContentSize() })
	        self.mp_NewPwd1Edit:setInputFlag(0)
	        self.mp_NewPwd1Edit:setFontColor(cc.c3b(83,75,68))
	        self.mp_NewPwd1Edit:setFontSize(28)
	        self.mp_NewPwd1Edit:setFontName("微软雅黑")
	        self.mp_NewPwd1Edit:setPlaceHolder("点击输入新密码")
        	self.mp_NewPwd1Edit:setPlaceholderFont("微软雅黑",28)
	        self.mp_NewPwd1Edit:setMaxLength(32)
	        imgNewPwd1Bg:addChild(self.mp_NewPwd1Edit)
	    end
	    if imgNewPwd2Bg then
	        self.mp_NewPwd2Edit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
	                            x=imgNewPwd2Bg:getContentSize().width/2,
	                            y=imgNewPwd2Bg:getContentSize().height/2,
	                            size=imgNewPwd2Bg:getContentSize() })
	        self.mp_NewPwd2Edit:setInputFlag(0)
	        self.mp_NewPwd2Edit:setFontColor(cc.c3b(83,75,68))
	        self.mp_NewPwd2Edit:setFontSize(28)
	        self.mp_NewPwd2Edit:setFontName("微软雅黑")
	        self.mp_NewPwd2Edit:setPlaceHolder("点击输入确认密码")
        	self.mp_NewPwd2Edit:setPlaceholderFont("微软雅黑",28)
	        self.mp_NewPwd2Edit:setMaxLength(32)
	        imgNewPwd2Bg:addChild(self.mp_NewPwd2Edit)
	    end
	end
end

function ServerBankWidget:onQuitWidget()
	self.callBack()
    self:removeFromParent()
end

function ServerBankWidget:onStoreOrOutGoldQuickBtnClicked(goldNumber)	
	-- 存入
	if self.group.currentSelectedIndex_ == 1 then
		if goldNumber > GlobalUserInfo.lUserScore or goldNumber < 0 then
			goldNumber = GlobalUserInfo.lUserScore
		end
	-- 取出
	elseif self.group.currentSelectedIndex_ == 2 then
		if goldNumber > GlobalUserInfo.lUserInsure or goldNumber < 0 then
			goldNumber = GlobalUserInfo.lUserInsure
		end
	end
	self:updateGoldEditAndUpperCase(self.st_GoldEdit,self.st_labelUpperCase,goldNumber)
end

function ServerBankWidget:onStoreOrTakeOutBtnClicked()
	local goldNumber = checknumber(self.st_GoldEdit.number and self.st_GoldEdit.number or self.st_GoldEdit:getText())
    -- 存入
	if self.group.currentSelectedIndex_ == 1 then
		if goldNumber <= 0 then
			local dataMsgBox = {
	            nodeParent=self,
	            msgboxType=MSGBOX_TYPE_OK,
	            msgInfo="存入的游戏币数量不能为空，请重新输入游戏币数量！"
	        }
	        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
			return
		end
		if goldNumber > GlobalUserInfo.lUserScore then
			local dataMsgBox = {
	            nodeParent=self,
	            msgboxType=MSGBOX_TYPE_OK,
	            msgInfo="存入的游戏币不足，请重新输入游戏币数量！"
	        }
	        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
			return
		end
		self:PerformSaveScore(goldNumber)
	-- 取出
	elseif self.group.currentSelectedIndex_ == 2 then
		if goldNumber <= 0 then
			local dataMsgBox = {
	            nodeParent=self,
	            msgboxType=MSGBOX_TYPE_OK,
	            msgInfo="取出的游戏币数量不能为空，请重新输入游戏币数量！"
	        }
	        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
			return
		end
		if goldNumber > GlobalUserInfo.lUserInsure then
			local dataMsgBox = {
	            nodeParent=self,
	            msgboxType=MSGBOX_TYPE_OK,
	            msgInfo="保险柜游戏币的数目余额不足，请重新输入游戏币数量！"
	        }
	        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
			return
		end
		self:PerformTakeScore(goldNumber)
	end
end

function ServerBankWidget:onCheckBoxClicked(clickedBtn,otherBtn)
	if clickedBtn and otherBtn then
		clickedBtn:setButtonSelected(true)
		otherBtn:setButtonSelected(false)
	end
end

function ServerBankWidget:onTransferGoldQuickBtnClicked(goldNumber)
	if goldNumber > GlobalUserInfo.lUserInsure or goldNumber < 0 then
		goldNumber = GlobalUserInfo.lUserInsure
	end
	self:updateGoldEditAndUpperCase(self.tr_GoldEdit,self.tr_labelUpperCase,goldNumber)
end

function ServerBankWidget:onOkTransferBtnClicked()
    local lScore = checknumber(self.tr_GoldEdit.number and self.tr_GoldEdit.number or self.tr_GoldEdit:getText())
    local strNickName = self.tr_UserEdit:getText()
    string.ltrim(strNickName)
    string.rtrim(strNickName)
    -- 昵称判断
    if string.len(strNickName) == 0 then
    	local msgString = ""
    	if self.tr_CheckBoxID:isButtonSelected() then
    		msgString = "请输入要赠送的玩家ID！"
    	else
    		msgString = "请输入要赠送的玩家昵称！"
    	end
    	local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo=msgString
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
		return
    end
    -- ID号判断
    if self.tr_CheckBoxID:isButtonSelected() then
    	if not tonumber(strNickName) then
    		local dataMsgBox = {
	            nodeParent=self,
	            msgboxType=MSGBOX_TYPE_OK,
	            msgInfo="请输入正确的玩家ID！"
	        }
	        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
			return
    	end
    end
    -- 数据判断
    if not (lScore > 0) then
    	local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="游戏币数量不能为空，请重新输入游戏币数量！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
		return
    end
    -- 数目判断
    if lScore > GlobalUserInfo.lUserInsure then
    	local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="保险柜游戏币的数目余额不足，请重新输入游戏币数量！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
		return
    end
    if lScore < self.InsureInfo.lTransferPrerequisite then
    	local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="从保险柜转账的游戏币数目不能少于"..self.InsureInfo.lTransferPrerequisite.."，无法进行转账操作！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
		return
    end
    local cbByNickName = 1
    if self.tr_CheckBoxID:isButtonSelected() then
    	cbByNickName = 0
    end
    self:PerformTransferScore(cbByNickName,strNickName,lScore)
end

function ServerBankWidget:onModifyPwdOkBtnClicked()
	if not self.mp_OrgPwdEdit or not self.mp_NewPwd1Edit or not self.mp_NewPwd2Edit then
		return
	end
	local strOrgPwd = self.mp_OrgPwdEdit:getText()
	if string.len(strOrgPwd) < 8 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="旧密码长度过短(最低8位)，请重新输入！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
		return
	end

    local strNewPwd1 = self.mp_NewPwd1Edit:getText()
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

    local strNewPwd2 = self.mp_NewPwd2Edit:getText()
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
    if strOrgPwd == strNewPwd1 then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="您所输入的新密码与原密码一致，请重新输入新密码！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end

    self:ModifyInsurePwd(strOrgPwd,strNewPwd1)
end

function ServerBankWidget:PerformQueryInfo()
	local CMD_GR_C_QueryInsureInfoRequest = {
		cbActivityGame=0,
		szInsurePass=GlobalUserInfo.szPassword,
	}
    self.missionItem:requestCommand(MDM_GR_INSURE, SUB_GR_QUERY_INSURE_INFO, 
    	CMD_GR_C_QueryInsureInfoRequest,"CMD_GR_C_QueryInsureInfoRequest")
end

function ServerBankWidget:PerformTakeScore(lTakeScore)
	self.m_lScore = lTakeScore
	local CMD_GR_C_TakeScoreRequest = {
		cbActivityGame=0,
		lTakeScore=lTakeScore,
		szInsurePass=self.szInsureOrgPwd,
	}

	self.missionItem:requestCommand(MDM_GR_INSURE, SUB_GR_TAKE_SCORE_REQUEST, 
    	CMD_GR_C_TakeScoreRequest,"CMD_GR_C_TakeScoreRequest")
end

function ServerBankWidget:PerformSaveScore(lSaveScore)
	self.m_lScore = lSaveScore

	local CMD_GR_C_SaveScoreRequest = {
		cbActivityGame=0,
		lSaveScore=lSaveScore,
	}

	self.missionItem:requestCommand(MDM_GR_INSURE, SUB_GR_SAVE_SCORE_REQUEST, 
    	CMD_GR_C_SaveScoreRequest,"CMD_GR_C_SaveScoreRequest")
end

function ServerBankWidget:PerformTransferScore(cbByNickName,szNickName,lTransferScore)
	self.m_lScore = lTransferScore
	self.m_cbByNickName = cbByNickName
	self.m_szNickName = szNickName
	
	local CMD_GR_C_QueryUserInfoRequest = {
		cbActivityGame=0,
		cbByNickName=cbByNickName,
		szNickName=szNickName
	}
	self.missionItem:requestCommand(MDM_GR_INSURE, SUB_GR_QUERY_USER_INFO_REQUEST, 
    	CMD_GR_C_QueryUserInfoRequest,"CMD_GR_C_QueryUserInfoRequest")
end

function ServerBankWidget:ModifyInsurePwd(szOldPwd,szNewPwd)
	self.m_szOldInsurePass = szOldPwd
	self.m_szNewInsurePass = szNewPwd

	--self:connectLoginServer(self.BANKINSUREPWD)
end

function ServerBankWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("ServerBankWidget bConnectSucc: 连接成功！")
        if self.MissionType == self.BANKQUERYINSURE then
        	local CMD_GP_QueryInsureInfo = {
				dwUserID=GlobalUserInfo.dwUserID,
				szPassword=GlobalUserInfo.szPassword,
			}
            self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_QUERY_INSURE_INFO, 
            	CMD_GP_QueryInsureInfo,"CMD_GP_QueryInsureInfo")
        elseif self.MissionType == self.BANKTELLER then
        	local CMD_GP_UserTakeScore = {
				dwUserID=GlobalUserInfo.dwUserID,
				lTakeScore=self.m_lScore,
				szPassword=self.szInsureOrgPwd,
				szMachineID=GlobalPlatInfo.szMachineID,
			}
			self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_USER_TAKE_SCORE, 
            	CMD_GP_UserTakeScore,"CMD_GP_UserTakeScore")
        elseif self.MissionType == self.BANKSAVE then
        	local CMD_GP_UserSaveScore = {
				dwUserID=GlobalUserInfo.dwUserID,
				lSaveScore=self.m_lScore,
				szMachineID=GlobalPlatInfo.szMachineID,
			}
			self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_USER_SAVE_SCORE, 
            	CMD_GP_UserSaveScore,"CMD_GP_UserSaveScore")
        elseif self.MissionType == self.BANKTRANSFER then
        	local CMD_GP_QueryUserInfoRequest = {
				cbByNickName=self.m_cbByNickName,
				szNickName=self.m_szNickName,
			}
			self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_QUERY_USER_INFO_REQUEST, 
            	CMD_GP_QueryUserInfoRequest,"CMD_GP_QueryUserInfoRequest")
        elseif self.MissionType == self.BANKINSUREPWD then
        	local CMD_GP_ModifyInsurePass = {
				dwUserID=GlobalUserInfo.dwUserID,
				szDesPassword=cc.Crypto:MD5(self.m_szNewInsurePass,false),
				szScrPassword=cc.Crypto:MD5(self.m_szOldInsurePass,false),
			}
			self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_MODIFY_INSURE_PASS, 
            	CMD_GP_ModifyInsurePass,"CMD_GP_ModifyInsurePass")
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

function ServerBankWidget:receiveShutDownMessage(Params)
   print("ServerBankWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function ServerBankWidget:onGetInsureInfoMessage(Params)
    self:hideLoadingWidget()
    -- CMD_GR_S_UserInsureInfo

    local insureInfo = self.InsureInfo
   	insureInfo.wRevenueTake=Params.wRevenueTake or 0
	insureInfo.wRevenueTransfer=Params.wRevenueTransfer or 0
	insureInfo.wServerID=Params.wServerID or 0
	insureInfo.lUserScore=Params.lUserScore or 0
	insureInfo.lUserInsure=Params.lUserInsure or 0
	insureInfo.lTransferPrerequisite=Params.lTransferPrerequisite or 0
	insureInfo.lIngotScore=Params.lUserIngot or 0
	insureInfo.lUserLoveliness=Params.lUserLoveliness or 0 

	GlobalUserInfo.lUserInsure = Params.lUserInsure or GlobalUserInfo.lUserInsure
	GlobalUserInfo.lUserScore = Params.lUserScore or GlobalUserInfo.lUserScore
	GlobalUserInfo.lIngotScore = Params.lUserIngot or GlobalUserInfo.lIngotScore
	GlobalUserInfo.lLoveLiness = Params.lUserLoveliness or GlobalUserInfo.lLoveLiness
    

    self:updateWidgetData()
    -- 刷新用户信息
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
        name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_UpdateUserInfo,
        para = {}
    })
end

function ServerBankWidget:onGetInsureSuccessMessage(Params)
    self:hideLoadingWidget()

    -- CMD_GR_S_UserInsureSuccess

    self.InsureInfo.lUserScore=Params.lUserScore or 0
	self.InsureInfo.lUserInsure=Params.lUserInsure or 0
    GlobalUserInfo.lUserInsure = Params.lUserInsure or GlobalUserInfo.lUserInsure
	GlobalUserInfo.lUserScore = Params.lUserScore or GlobalUserInfo.lUserScore

    self:updateWidgetData()
    -- 刷新用户信息
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
        name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_UpdateUserInfo,
        para = {}
    })

    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function ServerBankWidget:onGetInsureFailureMessage(Params)
    self:hideLoadingWidget()

    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function ServerBankWidget:onGetUserInfoResultMessage(Params)
    self:hideLoadingWidget()

    -- CMD_GR_S_UserTransferUserInfo
    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OKCANCEL,
        msgInfo="您确定要给["..Params.szNickName.."], ID:["..Params.dwTargetGameID.."] 赠送"..self.m_lScore.." 游戏币吗？",
        callBack=function(ret)
            if ret == MSGBOX_RETURN_OK then
            	local CMD_GP_C_TransferScoreRequest = {
					cbActivityGame=0,
					cbByNickName=self.m_cbByNickName,
					lTransferScore=self.m_lScore,
					szNickName=self.m_szNickName,
					szInsurePass=self.szInsureOrgPwd,
				}
				self.missionItem:requestCommand(MDM_GR_INSURE, SUB_GR_TRANSFER_SCORE_REQUEST, 
            		CMD_GP_C_TransferScoreRequest,"CMD_GP_C_TransferScoreRequest")
            else                    

            end
        end
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

return ServerBankWidget
