--
-- Author: SuperM
-- Date: 2016-02-24 10:14:32
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local HallHornMsgWidget = class("HallHornMsgWidget", XWWidgetBase)

HallHornMsgWidget.HORN_MSG_COLOR1 = cc.c3b(255, 255, 255)
HallHornMsgWidget.HORN_MSG_COLOR2 = cc.c3b(25, 206, 99)

function HallHornMsgWidget:ctor(parentNode,hornMsgs,missionMatch)
	HallHornMsgWidget.super.ctor(self)
	self.hornMsgs={}
	if hornMsgs and #hornMsgs then
		for i,v in ipairs(hornMsgs) do
			table.insert(self.hornMsgs,1,v)
		end
	end
	self.missionMatch = missionMatch

	self:addTo(parentNode)
end

function HallHornMsgWidget:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.LS_LinkConnect] = handler(self, self.receiveConnectServerMessage)
    eventListeners[appBase.Message.LS_GetHornMessage] = handler(self, self.receiveHallHornMessage)
    eventListeners[appBase.Message.LS_GetSendHornRes] = handler(self, self.receiveSendHornResMessage)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function HallHornMsgWidget:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function HallHornMsgWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
    self:registerEvents()
	HallHornMsgWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_HALL_HORN_MSG_CSB_FILE)
    if not node then
        return
    end
    node:setTouchEnabled(true)
    --node:setTouchSwallowEnabled(false)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT,function (event)
	    if "began" == event.name then
		    self:hide()	    	
	    end
	    return true
	end)

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgInputBg = cc.uiloader:seekNodeByName(node, "Image_InputBg")
    self.labelHornCount = cc.uiloader:seekNodeByName(node, "Label_HornCount")
    local sendBtn = cc.uiloader:seekNodeByName(bgnode, "Button_Send")
    self.hornMsgList = cc.uiloader:seekNodeByName(node, "ListView_HornMsg")
    bgnode:setTouchEnabled(true)

    if sendBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(sendBtn)
        sendBtn:onButtonClicked(handler(self, self.onSendBtnClicked) )
    end

    if self.labelHornCount then
    	self.labelHornCount:setString(tostring(GlobalUserInfo.dwHornNum))
    end

    if imgInputBg then
    	local bgSize = imgInputBg:getContentSize()
    	self.hornMsgEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_null.png",
                            x=bgSize.width/2-20,
                            y=bgSize.height/2,
                            size=cc.size(bgSize.width-140,bgSize.height) })
        --self.hornMsgEdit:setInputMode(3)
        self.hornMsgEdit:setFontColor(cc.c3b(83,75,68))
        self.hornMsgEdit:setFontSize(25)
        self.hornMsgEdit:setFontName("微软雅黑")
        self.hornMsgEdit:setPlaceHolder("点击输入广播内容")
        self.hornMsgEdit:setPlaceholderFont("微软雅黑",25)
        self.hornMsgEdit:setMaxLength(255)
        imgInputBg:addChild(self.hornMsgEdit)
    end

    if self.hornMsgList then
    	self.hornMsgList.bAsyncLoad = true
		self.hornMsgList:setDelegate(handler(self, self.listViewDelegate))
    end

    self:addChild(node)

    self.bgnode = bgnode
    self:showHornMsgWidget()
    self:updateHornMsgList()
end

function HallHornMsgWidget:onCleanup()
	HallHornMsgWidget.super.onCleanup(self)

	self:unregisterEvents()
end

function HallHornMsgWidget:updateHornMsgList()
	if self.hornMsgList then
		self.hornMsgList:reload()
	end
end

function HallHornMsgWidget:showHornMsgWidget()
	if self.bgnode and not self.isShowing then
		self.isShowing = true
		self:show()

		local orgPosX = self.bgnode:getPositionX()
		local orgPosY = self.bgnode:getPositionY()
		local size = self.bgnode:getContentSize()
		self.bgnode:setPositionY(orgPosY-size.height)
		transition.execute(self.bgnode, cc.MoveTo:create(0.2,cc.p(orgPosX,orgPosY)), 
			{easing = "exponentialIn",
				onComplete = function()
				    self.isShowing = false
				end})
	end
end

function HallHornMsgWidget:newHornMsgItem()
	local content = display.newNode()
	content.labelHorn = display.newTTFLabel({
            text = "",
            font = "微软雅黑",
            size = 22,
            color = cc.c3b(255, 255, 255),
            align = cc.TEXT_ALIGNMENT_LEFT,
            dimensions = cc.size(690, 0)
        })
	:align(display.LEFT_BOTTOM, 0, 5)
	:addTo(content)
    content.lineSplit = display.newLine({{0, 0}, {690,0}},{borderColor=cc.c4f(160,160,160,1)})
    :addTo(content)
    return content
end

function HallHornMsgWidget:updateHornMsgItem(content,hornMsg,idx)
	if content and hornMsg then
		if content.labelHorn then
			content.labelHorn:setString(hornMsg.szNickName.."："..hornMsg.szLabaText)
			content.labelHorn:setTextColor(idx%2==0 and self.HORN_MSG_COLOR1 or self.HORN_MSG_COLOR2)
			local labelSize = content.labelHorn:getContentSize()
			content:setContentSize(cc.size(labelSize.width,labelSize.height+10))
			return content:getContentSize()
		end
	end
	return cc.size(690,30)
end

function HallHornMsgWidget:listViewDelegate(listView, tag, idx)
    --print(string.format("TestUIListViewScene tag:%s, idx:%s", tostring(tag), tostring(idx)))
    if cc.ui.UIListView.COUNT_TAG == tag then
        return #self.hornMsgs
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content

        item = self.hornMsgList:dequeueItem()
        if not item then
            item = self.hornMsgList:newItem()
            content = self:newHornMsgItem()
            item:addContent(content)
        else
            content = item:getContent()
        end
        local itemSize = self:updateHornMsgItem(content,self.hornMsgs[idx],idx)
        item:setItemSize(itemSize.width, itemSize.height)

        return item
    else
    end
end

function HallHornMsgWidget:onSendBtnClicked()
    if self.hornMsgEdit then
    	local hornMsgText = self.hornMsgEdit:getText()
    	if string.len(hornMsgText) == 0 then
    		local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="广播内容不能为空！"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        else
        	local sendHornMsgFunc = function ()
        		local CMD_GL_Laba = {
					dwUserID=GlobalUserInfo.dwUserID,
					szNickName=GlobalUserInfo.szNickName,
					dwKindID=0,
					dwServerID=0,
					dwPropNum=0,
					szLabaText=hornMsgText,
				}
				self:requestCommand(MDM_GL_C_DATA, SUB_GL_C_LABA, CMD_GL_Laba, "CMD_GL_Laba")
        	end
        	if GlobalUserInfo.dwHornNum < 1 then
        		local dataMsgBox = {
	            	nodeParent=self,
	            	msgboxType=MSGBOX_TYPE_OKCANCEL,
	            	msgInfo="您可发送的喇叭数为0，继续发送将会从保险柜中扣除100万币，是否继续发送？",
	            	callBack=function(ret)
	                	    if ret == MSGBOX_RETURN_OK then
	                	        sendHornMsgFunc()
	                	    end
	               		end
	        	}
        		require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        	else
        		sendHornMsgFunc()
        	end
    	end
    end
end

function HallHornMsgWidget:hideLoadingWidget()
    HallHornMsgWidget.super.hideLoadingWidget(self)
    if self.hideLoadingAction then
        self:stopAction(self.hideLoadingAction)
        self.hideLoadingAction = nil
    end
end

function HallHornMsgWidget:requestCommand(mainID, subID, request,structName)
    if self.missionMatch then
        self:hideLoadingWidget()
        self:showLoadingWidget()
        self:updateStatusLabel("发送请求中，请稍后")
        self.missionMatch:requestCommand(mainID, subID, request,structName)
        self.hideLoadingAction = self:performWithDelay(function ()
            self:hideLoadingWidget()
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="发送数据请求失败，请稍后重试！"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        end, 10)
    end
end

function HallHornMsgWidget:receiveConnectServerMessage(event)
	if event.para.bConnectSucc then
        self.hornMsgs = {}
        self:updateHornMsgList()
    end
end

function HallHornMsgWidget:receiveHallHornMessage(event)
	--[[local CMD_GL_Laba = {
		dwUserID= ,
		szNickName="",
		dwKindID= ,
		dwServerID= ,
		dwPropNum= ,
		szLabaText="",
	}]]
	table.insert(self.hornMsgs,1,event.para)
	self:updateHornMsgList()
end

function HallHornMsgWidget:receiveSendHornResMessage(event)
	local CMD_GL_LabaLog = event.para
	--	lResultCode= ,
	--	dwPropNum= ,
	--	szDescribeString="",
	--}
	self:hideLoadingWidget()
	if CMD_GL_LabaLog.lResultCode ~= 0 then
		local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo=CMD_GL_LabaLog.szDescribeString
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    else
    	if self.labelHornCount then
    		self.labelHornCount:setString(tostring(GlobalUserInfo.dwHornNum))
    	end
	end
end

return HallHornMsgWidget