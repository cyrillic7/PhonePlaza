--
-- Author: SuperM
-- Date: 2015-11-10 11:01:38
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local HallTopupWidget = class("HallTopupWidget", XWWidgetBase)

HallTopupWidget.EXCHANGE_TYPE = 1
HallTopupWidget.GETORDER_TYPE = 2

function HallTopupWidget:ctor(parentNode,callBack,selectedID)
	HallTopupWidget.super.ctor(self)

	if device.platform == "ios" then
		self.payType = eHallPayType.eAppStorePay
	else
		self.payType = eHallPayType.eAlipay
	end
	
	self.callBack = callBack
	self.widgetType = "HallTopupWidget"
	self.selectedID = selectedID or 0
	self.currentSelectedIndex_ = -1
	self.MissionType = self.EXCHANGE_TYPE

	self.itemImgPictures = {}
	self.itemLabelNum1s = {}
	self.itemLabelNum2s = {}
	self.itemLabelNumExs = {}
	self.itemLabelCurrencys = {}
	self.itemImgIcons = {}

	self.itemGoldNumber ={
		{"10万金币","",10},
		{"30万金币","",30},
		{"50万金币","",50},
		{"100万金币","",100},
		{"200万金币","",200},
		{"500万金币","",500},
	}
	if device.platform == "ios" then
		self.itemGoldNumber ={
			{"6万金币","",6},
			{"30万金币","",30},
			{"50万金币","",50},
			{"108万金币","",108},
			{"208万金币","",208},
			{"518万金币","",518},
		}
	end
	self.itemWingNumber ={
		{"10元宝","加送1个红包碎片",10,"10元宝=10万金币"},
		{"30元宝","加送5个红包碎片",30,"30元宝=30万金币"},
		{"50元宝","加送2个红包",50,"50元宝=50万金币"},
		{"100元宝","加送5个红包",100,"100元宝=100万金币"},
		{"200元宝","加送12个红包",200,"200元宝=200万金币"},
		{"500元宝","加送35个红包",500,"500元宝=500万金币"},
	}

	if device.platform == "ios" then
		self.itemWingNumber ={
			{"6元宝","加送1个红包碎片",6,"6元宝=6万金币"},
			{"30元宝","加送5个红包碎片",30,"30元宝=30万金币"},
			{"50元宝","加送2个红包",50,"50元宝=50万金币"},
			{"108元宝","加送5个红包",108,"108元宝=108万金币"},
			{"208元宝","加送12个红包",208,"200元宝=208万金币"},
			{"518元宝","加送35个红包",518,"518元宝=518万金币"},
		}
	end

	self:addTo(parentNode)
end

function HallTopupWidget:setSelectedID(selectedID)
	if selectedID ~= self.currentSelectedIndex_ then
		if selectedID == 0 then
			if self.goldCheckBox then
				self.goldCheckBox:setButtonSelected(true)
			end
		else
			if self.wingCheckBox then
				self.wingCheckBox:setButtonSelected(true)
			end
		end
	end
end

function HallTopupWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	HallTopupWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_TOPUP_CSB_FILE)
    if not node then
        return
    end

    node:setTouchEnabled(false)

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local closeBtn = cc.uiloader:seekNodeByName(bgnode, "Button_Close")
    local goldCheckBox = cc.uiloader:seekNodeByName(bgnode, "CheckBox_Gold")
    local wingCheckBox = cc.uiloader:seekNodeByName(bgnode, "CheckBox_Wing")
    local goldWingListView = cc.uiloader:seekNodeByName(bgnode, "ListView_GoldWing")
    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
    		self.callBack()
    		self:removeFromParent()
    	end)    	
    end
    if goldWingListView then
    	for i=1,6 do
			local itemNode = cc.uiloader:seekNodeByName(goldWingListView, "Image_Item"..i)
			if itemNode then
				local imgPicture = cc.uiloader:seekNodeByName(itemNode, "Image_Picture")
				if imgPicture then
					table.insert(self.itemImgPictures,imgPicture)
				end
				local labelNum1 = cc.uiloader:seekNodeByName(itemNode, "Label_Number1")
				if labelNum1 then
					table.insert(self.itemLabelNum1s,labelNum1)
				end
				local labelNum2 = cc.uiloader:seekNodeByName(itemNode, "Label_Number2")
				if labelNum2 then
					table.insert(self.itemLabelNum2s,labelNum2)
				end
				local labelNumEx = cc.uiloader:seekNodeByName(itemNode, "Label_NumberEx")
				if labelNumEx then
					table.insert(self.itemLabelNumExs,labelNumEx)
				end
				local okBtn = cc.uiloader:seekNodeByName(itemNode, "Button_Ok")
				if okBtn then
					AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(okBtn)
					okBtn:onButtonClicked(function ()
						self:onOkBtnClicked(i)
					end)
				end
				local labelCurrency = cc.uiloader:seekNodeByName(itemNode, "AtlasLabel_Currency")
				if labelCurrency then
					table.insert(self.itemLabelCurrencys,labelCurrency)
				end
				local imgIcon = cc.uiloader:seekNodeByName(itemNode, "Image_Icon")
				if imgIcon then
					table.insert(self.itemImgIcons,imgIcon)
				end
			end
			
    	end
    end
    if goldCheckBox then
    	goldCheckBox.scale9_ = true
    	goldCheckBox:setButtonSize(409,74)
    	goldCheckBox:setButtonImage(goldCheckBox.OFF, {"#pic/plazacenter/Sundry/u_null.png"}, true)
    	goldCheckBox:setButtonImage(goldCheckBox.OFF_PRESSED, {"#pic/plazacenter/Topup/u_topup_btn_title.png"}, true)
    	goldCheckBox:setButtonImage(goldCheckBox.ON, {"#pic/plazacenter/Topup/u_topup_btn_title.png"}, true)
    	goldCheckBox:onButtonClicked(handler(self, self.onButtonStateChanged_))
    	goldCheckBox:onButtonStateChanged(handler(self, self.onButtonStateChanged_))
    	self.goldCheckBox = goldCheckBox
    end
    if wingCheckBox then
    	wingCheckBox.scale9_ = true
    	wingCheckBox:setButtonSize(409,74)
    	wingCheckBox:setButtonImage(wingCheckBox.OFF, {"#pic/plazacenter/Sundry/u_null.png"}, true)
    	wingCheckBox:setButtonImage(wingCheckBox.OFF_PRESSED, {"#pic/plazacenter/Topup/u_topup_btn_title.png"}, true)
    	wingCheckBox:setButtonImage(wingCheckBox.ON, {"#pic/plazacenter/Topup/u_topup_btn_title.png"}, true)
    	wingCheckBox:onButtonClicked(handler(self, self.onButtonStateChanged_))
    	wingCheckBox:onButtonStateChanged(handler(self, self.onButtonStateChanged_))
    	self.wingCheckBox = wingCheckBox
    end

    if self.selectedID == 0 then
    	self.goldCheckBox:setButtonSelected(true)
    else
    	self.wingCheckBox:setButtonSelected(true)
    end
    
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function HallTopupWidget:onCleanup()
	HallTopupWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function HallTopupWidget:cleanPlistRes()
	print("HallTopupWidget:cleanPlistRes")
    display.removeSpriteFramesWithFile("UIHallTopup.plist", "UIHallTopup.png")
end

function HallTopupWidget:onButtonStateChanged_(event)
    if not self.goldCheckBox or not self.wingCheckBox then
    	return
    end

    if event.name == event.target.STATE_CHANGED_EVENT and event.target:isButtonSelected() == false then
        return
    end
    
    self:updateButtonState_(event.target)
end

function HallTopupWidget:updateButtonState_(clickedButton)
	local currentSelectedIndex = 0
	if self.goldCheckBox == clickedButton then
		currentSelectedIndex = 0
		if not self.goldCheckBox:isButtonSelected() then
            self.goldCheckBox:setButtonSelected(true)
        end
        self.wingCheckBox:setButtonSelected(false)
    else
    	currentSelectedIndex = 1
    	if not self.wingCheckBox:isButtonSelected() then
            self.wingCheckBox:setButtonSelected(true)
        end
        self.goldCheckBox:setButtonSelected(false)
	end
	
	if self.currentSelectedIndex_ ~= currentSelectedIndex then
		self.currentSelectedIndex_ = currentSelectedIndex
		self:updateTopupWidget()
	end
end

function HallTopupWidget:updateTopupWidget()
	if #self.itemImgPictures ~= 6 or #self.itemLabelNum1s ~= 6
	  or  #self.itemLabelNum2s ~= 6 or #self.itemLabelCurrencys ~= 6
	  or #self.itemImgIcons ~= 6 or #self.itemLabelNumExs ~= 6 then
		print("error:HallTopupWidget list items error ")
		return
	end

	--if self.goldCheckBox:isButtonSelected() then
	if true then
		for i=1,6 do			
			self.itemImgPictures[i]:setSpriteFrame("pic/plazacenter/Topup/u_topup_icon_gold"..i..".png")
			self.itemLabelNum1s[i]:setString(self.itemGoldNumber[i][1])
			self.itemLabelNum2s[i]:setString(self.itemGoldNumber[i][1])
			self.itemLabelNumExs[i]:setString(self.itemGoldNumber[i][2])
			self.itemLabelCurrencys[i]:setString(self.itemGoldNumber[i][3])
			--self.itemImgIcons[i]:setSpriteFrame("pic/plazacenter/Sundry/u_icon_wing.png")
			self.itemImgIcons[i]:setSpriteFrame("pic/plazacenter/Topup/u_topup_icon_rmb.png")
		end
	else
		for i=1,6 do			
			self.itemImgPictures[i]:setSpriteFrame("pic/plazacenter/Topup/u_topup_icon_wing"..i..".png")
			self.itemLabelNum1s[i]:setString(self.itemWingNumber[i][1])
			self.itemLabelNum2s[i]:setString(self.itemWingNumber[i][1])
			self.itemLabelNumExs[i]:setString(self.itemWingNumber[i][2])
			self.itemLabelCurrencys[i]:setString(self.itemWingNumber[i][3])
			self.itemImgIcons[i]:setSpriteFrame("pic/plazacenter/Topup/u_topup_icon_rmb.png")
		end		
	end
end

function HallTopupWidget:onOkBtnClicked(itemIndex)
	print("onOkBtnClicked",itemIndex)
	--[[if self.goldCheckBox:isButtonSelected() then
		local wingCount = self.itemGoldNumber[itemIndex][3]
		if not wingCount then
			return
		end
		if wingCount > GlobalUserInfo.lIngotScore then
			local dataMsgBox = {
		        nodeParent=self,
		        msgboxType=MSGBOX_TYPE_OK,
		        msgInfo="您的元宝不足，兑换失败！"
		    }
		    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
			return
		end
		self.m_dwIngnot = wingCount or 1
		self:connectLoginServer(self.EXCHANGE_TYPE)
	else]]
		local rmbOrderItem = self.itemWingNumber[itemIndex]
		if not rmbOrderItem then
			return
		end
		self.m_rmbOrderItem = rmbOrderItem

		local function getOrderIDByPayType(payType)
			-- 创建订单
	        if device.platform == "android" then
	            local succ,strOrderID = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "GetOrderIDByPrefix", {"PAND"}, "(Ljava/lang/String;)Ljava/lang/String;")
	            if not succ then
	                return ""
	            end
	            return strOrderID
	        elseif device.platform == "ios" then
	        	local prefix = "PIOS"
	        	if payType == eHallPayType.eAlipay then
	        		prefix = "MFB"
	        	end
	            local succ,strOrderID = luaoc.callStaticMethod("LuaCallObjcFuncs", "GetOrderIDByPrefix",{prefix=prefix})
	            if not succ then
	                return ""
	            end
	            return strOrderID
	        end
		end

        -- 非IOS审核版本，弹出支付方式选择界面
        if not GlobalPlatInfo.isInReview then
        	require("plazacenter.widgets.HallPayTypeWidget").new(self,function (payType)
        		if payType then
        			self.payType = payType
        			self.m_strOrderID = getOrderIDByPayType(self.payType)
        			-- 微信支付无需下单，直接调用接口
        			if self.payType == eHallPayType.eWeixinPay then
        				self:onRechargeOrderMessage({dwRet=0})
        			else
        				self:connectLoginServer(self.GETORDER_TYPE)
        			end
        		end
        	end)
        else
        	self.m_strOrderID = getOrderIDByPayType()
        	self:connectLoginServer(self.GETORDER_TYPE)
        end
	--end
end

function HallTopupWidget:sendWxPayResult(callBack)
	if callBack then
		local postCocosCode = "SoGBAKZZeR3NBCZvIb1exgfEuqjAiifRC0t";
		local postUrl = "http://pay.719you.com/WS/QueryOrder.asmx/CocosWeiXinPay?"
		local postData = {}
		postData["orderID"]=self.m_strOrderID
		postData["strAccount"]=GlobalUserInfo.szAccounts
		postData["recharType"]="3"
		postData["amount"]=tostring(self.m_rmbOrderItem[3])
		postData["isfirst"]="0"
		postData["signCode"]=string.upper(cc.Crypto:MD5(self.m_strOrderID..GlobalUserInfo.szAccounts.."3"..self.m_rmbOrderItem[3].."0"..postCocosCode, false))
		-- 创建一个请求，并以 POST 方式发送数据到服务端
		self.request = network.createHTTPRequest(function (event)
				if event.name == "completed" then
					local code = self.request:getResponseStatusCode()
				    if code ~= 200 then
				        -- 请求结束，但没有返回 200 响应代码
				        print(code)
				        return
				    end
				 
				    -- 请求成功，显示服务端返回的内容
				    local response = self.request:getResponseString()
				    callBack(response)
				end
			end, postUrl, "POST")
		for k,v in pairs(postData) do
			self.request:addPOSTValue(k,v)
		end	 
		-- 开始请求。当请求完成时会调用 callback() 函数
		self.request:start()
	end
end

function HallTopupWidget:connectLoginServer(missionType)
    self.MissionType = missionType

    if not self.missionItem then
        self.missionItem = require("plazacenter.controllers.MissionItem").new(CLIENT_TYPE_LOGIN_POINT,"LoginServer_ExchangeGold")
			self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.receiveConnectMessage))
		    self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.receiveShutDownMessage))
		    self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_EXCHANGE_INGOT, handler(self, self.onExchangeIngotMessage))
		    self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_OPERATE_FAILURE, handler(self, self.onOperateFailureMessage))
		    self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_RECHARGE_ORDER, handler(self, self.onRechargeOrderMessage))
    end
    if self.missionItem then
        self.missionItem.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
        self:showLoadingWidget()
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
    end
end

function HallTopupWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("HallTopupWidget bConnectSucc: 连接成功！")
        if self.EXCHANGE_TYPE == self.MissionType then
        	local CMD_GP_UserExchangeIngot = {
				dwUserID=GlobalUserInfo.dwUserID,
				dwIngot=self.m_dwIngnot,
				szPassword=GlobalUserInfo.szPassword,
				szMachineID=GlobalPlatInfo.szMachineID,
			}
		    self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_EXCHANGE_INGOT, 
		    		CMD_GP_UserExchangeIngot,"CMD_GP_UserExchangeIngot")
        elseif self.GETORDER_TYPE == self.MissionType then
        	local CMD_GP_RechargeOrder = {
				szAccounts=GlobalUserInfo.szAccounts,
				dwOpTerminal=GlobalPlatInfo.dwTerminal,
				dwFirst=0,
				dwOrderAmount=self.m_rmbOrderItem[3],
				dwShareID=7,
				szLogonPass=GlobalUserInfo.szPassword,
				szRechargeOrder=self.m_strOrderID,
			}
			dump(CMD_GP_RechargeOrder)
			self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_RECHARGE_ORDER, 
		    		CMD_GP_RechargeOrder,"CMD_GP_RechargeOrder")
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

function HallTopupWidget:receiveShutDownMessage(Params)
   print("HallTopupWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function HallTopupWidget:onExchangeIngotMessage(Params)
    self:hideLoadingWidget()

    -- CMD_GP_ExchangeIngotSuccess

    GlobalUserInfo.lUserInsure = Params.lInsure
	GlobalUserInfo.lIngotScore = Params.lIngot
    
    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    if self.missionItem then
        self.missionItem:onDisconnectSocket()
    end

    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
        name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_UpdateUserInfo,
        para = {}
    })
end

function HallTopupWidget:onOperateFailureMessage(Params)
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

function HallTopupWidget:onRechargeOrderMessage(Params)
    self:hideLoadingWidget()

    -- CMD_GP_RechargeOrderLog

    -- error
    if Params.dwRet ~= 0 then
    	local dataMsgBox = {
	        nodeParent=self,
	        msgboxType=MSGBOX_TYPE_OK,
	        msgInfo=Params.szDescribeString
	    }
	    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
	else
        if device.platform == "android" then
        	-- 微信支付
        	if self.payType == eHallPayType.eWeixinPay then
        		self:sendWxPayResult(function (data)
        			luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "wxpayInApp", {data}, "(Ljava/lang/String;)V")
        		end)
        	else -- 支付宝支付
        		luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "s_pay", {self.m_rmbOrderItem[1], self.m_rmbOrderItem[4], tostring(self.m_rmbOrderItem[3]),0}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
        	end
        elseif device.platform == "ios" then
        	-- 支付宝支付
        	if self.payType == eHallPayType.eAlipay then
        		luaoc.callStaticMethod("LuaCallObjcFuncs", "alipayInApp",{price=self.m_rmbOrderItem[3],orderId=self.m_strOrderID})
        	-- 微信支付
        	elseif self.payType == eHallPayType.eWeixinPay then
        		luaoc.callStaticMethod("LuaCallObjcFuncs", "wxpayInApp",{price=self.m_rmbOrderItem[3],orderId=self.m_strOrderID,account=GlobalUserInfo.szAccounts})
        	else -- 苹果支付
        		luaoc.callStaticMethod("LuaCallObjcFuncs", "payInApp",{price=self.m_rmbOrderItem[3],orderId=self.m_strOrderID})
        	end
        end
    end

    if self.missionItem then
        self.missionItem:onDisconnectSocket()
    end
end

return HallTopupWidget