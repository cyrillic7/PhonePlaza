--
-- Author: SuperM
-- Date: 2016-01-15 16:37:00
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local HallBagWidget = class("HallBagWidget", XWWidgetBase)

HallBagWidget.EXCHANGE_TYPE = 1
HallBagWidget.GETLIST_TYPE = 2

HallBagWidget.NOT_USE = 1           --道具不能使用
HallBagWidget.USE_STATE = 2         --使用
HallBagWidget.EXCHANGE_STATE = 3    --兑换

function HallBagWidget:ctor(parentNode,callBack)
	HallBagWidget.super.ctor(self)

	self.callBack = callBack
	self.widgetType = "HallBagWidget"
	self.MissionType = self.GETLIST_TYPE
    self.knapsackList = {}
    self.selItem = nil

	self:addTo(parentNode)
end

function HallBagWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	HallBagWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_BAG_CSB_FILE)
    if not node then
        return
    end

    node:setTouchEnabled(false)

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local closeBtn = cc.uiloader:seekNodeByName(bgnode, "Button_Close")
    self.okBtn = cc.uiloader:seekNodeByName(bgnode, "Button_Operate")
    self.imgBtnTxt = cc.uiloader:seekNodeByName(bgnode, "Image_BtnTxt")
    self.labelSelName1 = cc.uiloader:seekNodeByName(bgnode, "Label_SelName1")
    self.labelSelName2 = cc.uiloader:seekNodeByName(bgnode, "Label_SelName2")
    self.imgSelPic = cc.uiloader:seekNodeByName(bgnode, "Image_SelPic")
    self.labelSelTitle = cc.uiloader:seekNodeByName(bgnode, "Label_SelTitle")
    self.labelSelDesc = cc.uiloader:seekNodeByName(bgnode, "Label_SelDesc")
    self.goodsPageView = cc.uiloader:seekNodeByName(bgnode, "PageView_List")
    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
    		self.callBack()
    		self:removeFromParent()
    	end)    	
    end
    if self.okBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(self.okBtn)
    	self.okBtn:onButtonClicked(handler(self,self.onOkBtnClicked))
    end
    if self.goodsPageView then
        self.goodsPageView.column_ = 4
        self.goodsPageView.row_ = 2
        self.goodsPageView:onTouch(handler(self, self.touchListener))
    end
    
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)

    self:connectLoginServer(self.GETLIST_TYPE)
    -- 更新选中物品
    self:updateSelGood()
end

function HallBagWidget:onCleanup()
	HallBagWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function HallBagWidget:cleanPlistRes()
	print("HallBagWidget:cleanPlistRes")
    display.removeSpriteFramesWithFile("UIHallBag.plist", "UIHallBag.png")
end

function HallBagWidget:sendExchangePackage(dwID,count,sContent)
    self.CMD_GP_UseKnapsack = {
        dwUserID=GlobalUserInfo.dwUserID,
        dwOpTerminal=GlobalPlatInfo.dwTerminal,
        szPassword=GlobalUserInfo.szPassword,
        dwID=dwID,
        dwNum=count,
        szNote=sContent,
        szMachineID=GlobalPlatInfo.szMachineID,
    }
    self.preExchangeCount = count
    self:connectLoginServer(self.EXCHANGE_TYPE)
end

function HallBagWidget:onOkBtnClicked()
	if self.selItem and self.selItem.info then
        local info = self.selItem.info
        if info.dwExchangeType == self.EXCHANGE_STATE then
            require("plazacenter.widgets.HallBagExchangeWidget").new(self,info,function (count)
                self:sendExchangePackage(info.dwID,count,"")
            end)
        else
            -- 首登礼包
            if info.dwExchangeType == self.USE_STATE and info.dwUseType ~= 5 and info.dwUseType ~= 6 then
                self:sendExchangePackage(info.dwID,1,"")
            else
                require("plazacenter.widgets.HallBagUseGoodWidget").new(self,info,function (sContent)
                    self:sendExchangePackage(info.dwID,1,sContent)
                end)    
            end
        end
    end
end

function HallBagWidget:touchListener(event)
    --dump(event)
    if event.name == "clicked" then
        self:updateSelGood(event.item)
    end
end

function HallBagWidget:setNetworkPic(imgCtrl,strPicName)
    if string.len(strPicName) < 1 then
        return
    end
    
    if cc.FileUtils:getInstance():isFileExist("download/"..strPicName..".png") then
        imgCtrl:setTexture("download/"..strPicName..".png")
    else
        local updater = require("common.UpdaterModule").new()
        if updater then
            updater:updateFile(string.format("%s/image/PropIcon/%s.png",GlobalWebIPs.szMallWebIP,strPicName)
                    ,strPicName..".png",function (event,value)
                        if event == "success" then
                            imgCtrl:setTexture("download/"..strPicName..".png")
                        end
                    end,false)
            updater:addTo(imgCtrl)
        end
        imgCtrl:setSpriteFrame("pic/plazacenter/Sundry/u_null.png")
    end
end

function HallBagWidget:addGoodItemToList(info)
    local goodsPageView = self.goodsPageView
    if goodsPageView and info then
        local item = goodsPageView:newItem()
        local content = cc.uiloader:load(WIDGET_BAG_ITEM_CSB_FILE)
        if not content then
            return
        end
        local title = cc.uiloader:seekNodeByName(content, "Label_Title")
        local count = cc.uiloader:seekNodeByName(content, "Label_Count")
        local imgGoodPic = cc.uiloader:seekNodeByName(content, "Image_GoodPic")
        local imgSelBg = cc.uiloader:seekNodeByName(content, "Image_SelBg")
        if title then
            title:setString(info.szName)
        end
        if count then
            count:setString(tostring(info.dwNum))
        end
        if imgGoodPic then
            self:setNetworkPic(imgGoodPic, info.szImgName)
        end
        if imgSelBg then
            item.imgSelBg = imgSelBg
        end
        item:addChild(content)
        item.info = info
        goodsPageView:addItem(item)
    end
end

function HallBagWidget:updateListGoods()
    if self.goodsPageView then
        self.goodsPageView:removeAllItems()
        for k,v in pairs(self.knapsackList) do
            self:addGoodItemToList(v)
        end
        self.goodsPageView:reload()
        -- 更新选中物品
        self:updateSelGood()
    end
end

function HallBagWidget:updateGoodInfo(info)
    if self.okBtn then
        if not info or info.dwExchangeType == self.NOT_USE then
            self.okBtn:hide()
        else
            self.okBtn:show()
            if self.imgBtnTxt then
                self.imgBtnTxt:setSpriteFrame(info.dwExchangeType == self.USE_STATE and
                    "pic/plazacenter/Bag/u_backpack_text_use.png" or 
                    "pic/plazacenter/Bag/u_backpack_text_exchange.png")
            end
        end
    end
    if self.labelSelName1 then
        self.labelSelName1:setString(info and info.szName or "")
    end
    if self.labelSelName2 then
        self.labelSelName2:setString(info and info.szName or "")
    end
    if self.imgSelPic then
        if info then
            self:setNetworkPic(self.imgSelPic, info.szImgName)
        else
            self.imgSelPic:setSpriteFrame("pic/plazacenter/Sundry/u_null.png")
        end
    end
    if self.labelSelTitle then
        self.labelSelTitle:setString(info and info.szOpenDespict or "")
    end
    if self.labelSelDesc then
        self.labelSelDesc:setString(info and info.szDespict or "")
    end
end

function HallBagWidget:updateSelGood(item)
    if not item then
        if self.goodsPageView and #self.goodsPageView.items_>0 then
            item = self.goodsPageView.items_[1]
        end
    end
    self.selItem = item
    if item then
        if item.imgSelBg then
            if item.imgSelBg:isVisible() then
                return
            end
            item.imgSelBg:show()
        end
        for i,v in ipairs(self.goodsPageView.items_) do
            if v ~= item and v.imgSelBg then
                v.imgSelBg:hide()
            end
        end
        self:updateGoodInfo(item.info)
        return
    end
    self:updateGoodInfo()
end

function HallBagWidget:connectLoginServer(missionType)
    self.MissionType = missionType

    if not self.missionItem then
        self.missionItem = require("plazacenter.controllers.MissionItem").new(CLIENT_TYPE_LOGIN_POINT,"LoginServer_ExchangeGold")
			self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.receiveConnectMessage))
		    self.missionItem.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.receiveShutDownMessage))
		    self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_KNAPSACK, handler(self, self.onGetKnapsackMessage))
		    self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_KNAPSACKLOG, handler(self, self.onKnapsackLogMessage))
		    self.missionItem.scriptHandler:registerResponseHandler(MDM_GP_USER_SERVICE, SUB_GP_USE_KNAPSACKLOG, handler(self, self.onUseKnapsackLogMessage))
    end
    if self.missionItem then
        self.missionItem.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
        self:showLoadingWidget()
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
    end
end

function HallBagWidget:receiveConnectMessage(Params)
   if Params.bConnectSucc then
        print("HallBagWidget bConnectSucc: 连接成功！")
        if self.GETLIST_TYPE == self.MissionType then
            local CMD_GP_UserID = {
                dwUserID=GlobalUserInfo.dwUserID,
                szPassword=GlobalUserInfo.szPassword,
            }
		    self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_KNAPSACK, 
		    		CMD_GP_UserID,"CMD_GP_UserID")
        elseif self.EXCHANGE_TYPE == self.MissionType then
        	if self.CMD_GP_UseKnapsack then
                self.missionItem:requestCommand(MDM_GP_USER_SERVICE, SUB_GP_USE_KNAPSACKLOG, 
                    self.CMD_GP_UseKnapsack,"CMD_GP_UseKnapsack")
                self.CMD_GP_UseKnapsack = nil
            end
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

function HallBagWidget:receiveShutDownMessage(Params)
   print("HallBagWidget receiveShutDownMessage")
   self:hideLoadingWidget()
end

function HallBagWidget:onGetKnapsackMessage(Params)
    self:hideLoadingWidget()

    -- CMD_GP_Knapsack
    self.knapsackList = {}
    if Params.unResolvedData then
        self.knapsackList = self.missionItem:ParseStructGroup(Params.unResolvedData,"CMD_GP_Knapsack")
    end
   table.insert(self.knapsackList,Params)
   table.sort(self.knapsackList,function(item1,item2)
    if item1.dwSortID < item2.dwSortID then
            return true
        else
            return false
        end
    end)
   
   self:updateListGoods()

   if self.missionItem then
        self.missionItem:onDisconnectSocket()
    end
end

function HallBagWidget:onKnapsackLogMessage(Params)
    self:hideLoadingWidget()

    --CMD_GP_KnapsackLog
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

function HallBagWidget:onUseKnapsackLogMessage(Params)
    self:hideLoadingWidget()
    if self.missionItem then
        self.missionItem:onDisconnectSocket()
    end
    -- CMD_GP_UseKnapsackLog

    if Params.dwRet == 0 then
        if self.selItem and self.selItem.info then
            local info = self.selItem.info
            info.dwNum = info.dwNum - self.preExchangeCount or 1
            if info.dwNum <= 0 then
                for k,v in pairs(self.knapsackList) do
                    if info == v then
                        table.remove(self.knapsackList,k)
                        break
                    end
                end
            end
        end
        self:updateListGoods()
        self:connectLoginServer(self.GETLIST_TYPE)
    end

    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

return HallBagWidget