local TableFrameController = class("TableFrameController")

function TableFrameController:ctor(frameScene)
	self.frameScene = frameScene
	self.TableViewArray = {}
end

function TableFrameController:showTableRight(bShow)
	if self.frameScene and self.frameScene.imgTableRight then
		local imgTableRight = self.frameScene.imgTableRight
		imgTableRight:setVisible(bShow)
		self.frameScene.btnShowRight:setVisible(not bShow)
		local tableViewWidth = display.width
		if bShow then
			tableViewWidth = tableViewWidth - imgTableRight:getContentSize().width + 42
		end
		self:resizeControlsPosition(tableViewWidth)
	end
end
function TableFrameController:onQuickJoinBtnClicked()
	AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_QuickJoinBtnClicked,
            para = {wTableID=INVALID_TABLE,wChairID=INVALID_CHAIR}
        })
end

function TableFrameController:onGoBackBtnClicked()
	if self.frameScene then
		if self.frameScene.listViewTable then
			self.frameScene.listViewTable:removeAllItems()
			self.frameScene.listViewTable:reload()
			self.frameScene.listViewTable.content = nil
			self.TableViewArray = {}
		end
		self.frameScene:switchToTableFrame(false)
	end
end

function TableFrameController:onLockRoomBtnClicked()
	AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_SetTableLockBtnClicked,
            para = {}
        })
end

function TableFrameController:onRuleBtnClicked()
	if self.frameScene.ServerViewItemController then
		local gameName = self.frameScene.ServerViewItemController:gameName()
		
		if gameName and cc.FileUtils:getInstance():isFileExist(gameName.."/u_game_rule.png") then
			self.frameScene.imgRule:removeAllChildren()
			-- 创建滚动层
			local size = self.frameScene.imgRule:getContentSize()
			local ruleImg = display.newSprite(gameName.."/u_game_rule.png")
			:align(display.LEFT_TOP, 5,size.height-20)
			local emptyNode = cc.Node:create()
		    emptyNode:addChild(ruleImg)
		    
		    local ruleScroll = cc.ui.UIScrollView.new({viewRect = cc.rect(5,10,size.width-20,size.height-25)})
		    ruleScroll:addScrollNode(emptyNode)
		    ruleScroll:setDirection(cc.ui.UIScrollView.DIRECTION_VERTICAL)
		    ruleScroll:addTo(self.frameScene.imgRule)
			self.frameScene.panelRule:show()
			-- 屏蔽tableview消息
			if self.ccTableView then
				self.ccTableView:setTouchEnabled(false)
			end

			self.frameScene.panelRule.lastRulePic = gameName.."/u_game_rule.png"
			return
		end
		local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="当前游戏的游戏规则未配置，给您带来不便，请谅解！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
	end
end

function TableFrameController:onTouchPanelRule(panelRule)
	if panelRule then
		panelRule:setTouchEnabled(true)
		panelRule:setTouchSwallowEnabled(false)
		panelRule:addNodeEventListener(cc.NODE_TOUCH_EVENT,function (event)
		    if "began" == event.name then
			    panelRule:hide()
			    if self.frameScene.panelRule.lastRulePic then
			    	display.removeSpriteFrameByImageName(self.frameScene.panelRule.lastRulePic)
			    	self.frameScene.panelRule.lastRulePic = nil
			    end
			    -- 恢复tableview消息
				if self.ccTableView then
					self.ccTableView:setTouchEnabled(true)
				end
		    end
		    return true
    	end)
	end
end

function TableFrameController:onShowRightBtnClicked()
	self:showTableRight(true)
end

function TableFrameController:onHideRightPanelTouch(btnHideRight)
	if btnHideRight then
		btnHideRight:onButtonPressed(function (event)
			btnHideRight.bDrag_ = false
			btnHideRight.beginX = event.x
			btnHideRight.beginY = event.y
		end)
		btnHideRight:onButtonRelease(function (event)
			if math.abs(event.x-btnHideRight.beginX)>5 or math.abs(event.y-btnHideRight.beginY)>5 then
				btnHideRight.bDrag_ = true
			end
		end)
		btnHideRight:onButtonClicked(function ()
			--if not btnHideRight.bDrag_ then
				self:showTableRight(false)
			--end
		end)
	end
end

function TableFrameController:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    local plazaUserManager = require("plazacenter.controllers.PlazaUserManagerController")
    eventListeners[appBase.Message.GS_ConfigServer] = handler(self, self.receiveConfigServerMessage)
    eventListeners[appBase.Message.GS_TableInfo] = handler(self, self.receiveTableInfoMessage)
    eventListeners[appBase.Message.GS_TableStatus] = handler(self, self.receiveTableStatusMessage)
    eventListeners[plazaUserManager.Message.PLAZA_UserItemAcitve] = handler(self, self.onUserItemAcitve)
    eventListeners[plazaUserManager.Message.PLAZA_UserItemDelete] = handler(self, self.onUserItemDelete)
    eventListeners[plazaUserManager.Message.PLAZA_UserItemStatusUpdate] = handler(self, self.onUserItemStatusUpdate)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function TableFrameController:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function TableFrameController:setClientUserItem(wTableID,wChairID,clientUserItem)
	if self.TableViewArray[tostring(wTableID)] then
		self.TableViewArray[tostring(wTableID)]:setClientUserItem(wChairID,clientUserItem)
	end
end

function TableFrameController:setTableStatus(wTableID, bPlaying, bLocker)
	if self.TableViewArray[tostring(wTableID)] then
		self.TableViewArray[tostring(wTableID)]:setTableStatus(bPlaying,bLocker)
	end
end

function TableFrameController:getClientUserItem(wTableID,wChairID)
	if self.TableViewArray[tostring(wTableID)] then
		self.TableViewArray[tostring(wTableID)]:getClientUserItem(wChairID)
	end
end

function TableFrameController:onGameServerSelectChanged(event)
	if self.serverListGroup then
        local selectedItem = self.serverListGroup:getButtonAtIndex(event.selected)
        if selectedItem then
            AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
               name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_GameServerItemClicked,
                  para = selectedItem.gameServer})
        end
    end
end

function TableFrameController:showTableFrameByType(bAvertMode)
	if self.frameScene.listViewTable then
		self.frameScene.listViewTable:setVisible(not bAvertMode)
	end
	if self.ccTableView then
		self.ccTableView:setVisible(not bAvertMode)
	end
	if self.frameScene.panelAvertMode then
		self.frameScene.panelAvertMode:setVisible(bAvertMode)
	end
	if self.frameScene.btnQuickJoin then
		self.frameScene.btnQuickJoin:setVisible(not bAvertMode)
	end
	if self.frameScene.btnLockDesk then
		self.frameScene.btnLockDesk:setVisible(not bAvertMode)
	end
end

function TableFrameController:resizeControlsPosition(width)
	if not width then
		return
	end
	width = width
	local listViewTable = self.frameScene.listViewTable
	listViewTable:setContentSize(width,listViewTable:getContentSize().height)
	local viewRectTemp = listViewTable:getViewRect()
	viewRectTemp.width = width
	listViewTable:setViewRect(viewRectTemp)
	listViewTable:addTouchNode()
	self.frameScene.btnHideRight:setPositionX(width)
	local listViewSize = listViewTable:getContentSize()
	-- 按钮位置调整
	local topWidth = width - 50
	if self.frameScene.imgTableTopBg then
		local imgTableTopBg = self.frameScene.imgTableTopBg
		local oldSize = imgTableTopBg:getContentSize()
		imgTableTopBg:setContentSize(topWidth,oldSize.height)
	end
	if self.frameScene.btnLockDesk then
		self.frameScene.btnLockDesk:setPositionX(topWidth-310)
	end
	if self.frameScene.btnRule then
		self.frameScene.btnRule:setPositionX(topWidth-180)
	end
	if self.frameScene.btnGoBack then
		self.frameScene.btnGoBack:setPositionX(topWidth-50)
	end
	-- 调整imgRule位置
	if self.frameScene.imgRule then
		self.frameScene.imgRule:setPositionX(topWidth-180-150)
	end
	-- 调整防作弊模式位置
	if self.frameScene.imgAvertModeBg then
		self.frameScene.imgAvertModeBg:setPositionX(width/2)
	end
	if self.frameScene.btnAvertStart then
		self.frameScene.btnAvertStart:setPositionX(width/2)
	end
	local bAvertMode = (0 ~= bit._and(self.ConfigServer.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE))
	if bAvertMode then
		return
	end
	-- 计算cell count
    local tableViewController = require("plazacenter.controllers.TableViewController")
	local tableSize = tableViewController:getTableSize(self.ConfigServer.wChairCount)
	local nCoulmnCount = math.floor(listViewTable:getContentSize().width/tableSize.width)
	if nCoulmnCount < 1 then
		nCoulmnCount = 1
	end
	local nRowCount = math.ceil(self.ConfigServer.wTableCount/nCoulmnCount)
	if nRowCount < 1 then
		nRowCount = 1
	end
	self.ccTableView.nCoulmnCount = nCoulmnCount
	self.ccTableView.nCellCount = nRowCount
	self.ccTableView.nCellHeight = tableSize.height
	self.ccTableView.nTableWidth = width/nCoulmnCount		
	self.ccTableView:setContentSize(cc.size(width,listViewTable:getContentSize().height))
	self.ccTableView:setViewSize(cc.size(width,listViewTable:getContentSize().height))
	self.ccTableView:reloadData()
end

function TableFrameController:receiveTableInfoMessage(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	local netWork = event.para.netWork
	local tableInfo = event.para.tableInfo
	if tableInfo and tableInfo.wTableCount > 0 then
		self:setTableStatus(0,tableInfo.TableStatusArray.cbPlayStatus==1,tableInfo.TableStatusArray.cbTableLock==1)
	end
	if tableInfo.unResolvedData and netWork then
		local tableGroup = netWork:ParseStructGroup(tableInfo.unResolvedData, "tagTableStatus")
		for i,v in ipairs(tableGroup) do
			self:setTableStatus(i,v.cbPlayStatus==1,v.cbTableLock==1)
		end
	end
end

function TableFrameController:receiveTableStatusMessage(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	local tableStatusInfo = event.para
	if tableStatusInfo then
		self:setTableStatus(tableStatusInfo.wTableID, tableStatusInfo.TableStatus.cbPlayStatus==1, tableStatusInfo.TableStatus.bLocker==1)
	end
end

function TableFrameController:onUserItemAcitve(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	local clientUserItem = event.para
	if clientUserItem.cbUserStatus >= US_SIT and clientUserItem.cbUserStatus ~= US_LOOKON then
		self:setClientUserItem(clientUserItem.wTableID,clientUserItem.wChairID,clientUserItem)
	end
end

function TableFrameController:onUserItemDelete(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	local clientUserItem = event.para
    if clientUserItem.wTableID ~= INVALID_TABLE and clientUserItem.wChairID ~= INVALID_CHAIR then
		self:setClientUserItem(clientUserItem.wTableID,clientUserItem.wChairID,nil)
		-- 离开判断
		if clientUserItem.dwUserID == GlobalUserInfo.dwUserID then
			--todo
		end
	end
end

function TableFrameController:onUserItemStatusUpdate(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	local clientUserItem = event.para.clientUserItem
	local preUserStatus = event.para.preUserStatus
	-- 桌子离开
	if preUserStatus.wTableID ~= INVALID_TABLE and 
		(preUserStatus.wTableID ~= clientUserItem.wTableID or preUserStatus.wChairID ~= clientUserItem.wChairID) then
		self:setClientUserItem(preUserStatus.wTableID,preUserStatus.wChairID,nil)
	end
	-- 桌子加入
	if clientUserItem.wTableID ~= INVALID_TABLE and clientUserItem.cbUserStatus ~= US_LOOKON and 
		(preUserStatus.wTableID ~= clientUserItem.wTableID or preUserStatus.wChairID ~= clientUserItem.wChairID) then
		self:setClientUserItem(clientUserItem.wTableID,clientUserItem.wChairID,clientUserItem)
	end
	-- 桌子状态
	if (preUserStatus.wTableID == clientUserItem.wTableID or preUserStatus.wChairID == clientUserItem.wChairID) then
		self:setClientUserItem(clientUserItem.wTableID,clientUserItem.wChairID,clientUserItem)
	end
end



function TableFrameController:receiveConfigServerMessage(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	self.ConfigServer = event.para
	-- 百人游戏不用配置桌子/ios审核版本
	if self.ConfigServer.wChairCount >= HUNDRRED_GAME_NUM or GlobalPlatInfo.isInReview then
		return
	end
	if self.frameScene and self.frameScene.listViewTable then
		if self.frameScene.ServerViewItemController then
			local  gameServer = self.frameScene.ServerViewItemController.gameServer
			if gameServer.wSortID < 510 then
		        self.ConfigServer.dwServerRule = bit._or(self.ConfigServer.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE)
		    end
		end
		-- 房间名称
		local labelRoomName = self.frameScene.labelRoomName
		if labelRoomName then
			local curGameServer = self.frameScene.ServerViewItemController.gameServer
			labelRoomName:setString("【"..curGameServer.szServerName.."】")
		end
		local listViewTable = self.frameScene.listViewTable
		listViewTable:removeAllItems()
		listViewTable.content = nil
		self.TableViewArray = {}
		local bAvertMode = (0 ~= bit._and(self.ConfigServer.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE))
		self:showTableFrameByType(bAvertMode)
		if bAvertMode then -- 防作弊模式
			return
		end
		-- 添加TableView
		listViewTable:hide()
		if self.ccTableView and self.ccTableView.wChairCount ~= self.ConfigServer.wChairCount then
			self.ccTableView:removeFromParent()
			self.ccTableView = nil
		end
		if not self.ccTableView then
			local ccTableView = cc.TableView:create(listViewTable:getContentSize())
			ccTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
		    ccTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
		    ccTableView:setDelegate()
		    ccTableView:addTo(self.frameScene.tableViewPanel)
		    --ccTableView:align(display.LEFT_BOTTOM, 0, 0)
		    ccTableView:registerScriptHandler(handler(self,self.tableCellTouched), cc.TABLECELL_TOUCHED)
	    	ccTableView:registerScriptHandler(handler(self,self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
	    	ccTableView:registerScriptHandler(handler(self,self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
	    	ccTableView:registerScriptHandler(handler(self,self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	    	self.ccTableView = ccTableView
	    	self.ccTableView.wChairCount = self.ConfigServer.wChairCount
		end
	    -- 初始化self。TableViewArray
	    for i=0,self.ConfigServer.wTableCount-1 do
			local tableView = require("plazacenter.controllers.TableViewController").new(self)
			tableView:initTableView(i,self.ConfigServer.wChairCount)
			self.TableViewArray[tostring(i)] = tableView
		end
		-- 计算cell count
	    local tableViewController = require("plazacenter.controllers.TableViewController")
		local tableSize = tableViewController:getTableSize(self.ConfigServer.wChairCount)
		local nCoulmnCount = math.floor(listViewTable:getContentSize().width/tableSize.width)
		if nCoulmnCount < 1 then
			nCoulmnCount = 1
		end
		local nRowCount = math.ceil(self.ConfigServer.wTableCount/nCoulmnCount)
		if nRowCount < 1 then
			nRowCount = 1
		end
		self.ccTableView.nCoulmnCount = nCoulmnCount
		self.ccTableView.nCellCount = nRowCount
		self.ccTableView.nCellHeight = tableSize.height
		self.ccTableView.nTableWidth = listViewTable:getContentSize().width/nCoulmnCount		
		self.ccTableView:reloadData()
	end
end

function TableFrameController:tableCellTouched(view, cell)
	--dump(cell,"tableCellTouched")
end

function TableFrameController:cellSizeForTable(view, idx)
	return view.nCellHeight,0
end

function TableFrameController:tableCellAtIndex(view, idx)
	local cell = view:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:create()
        cell.subTableView = {}
    end
    cell.subItemCount = cell.subItemCount or 0
    cell.idx = idx
    if cell.subItemCount < view.nCoulmnCount then
    	cell:performWithDelay(function ()
    		self:delayCreateTableView(view,cell)
    	end, 0)
    end
    self:updateTableViewCell(view,cell)
    return cell
end

function TableFrameController:numberOfCellsInTableView(view)
	return view.nCellCount
end

function TableFrameController:delayCreateTableView(view,cell)
	-- 创建桌子
	local tableViewController = require("plazacenter.controllers.TableViewController")
	local tableViewNode = tableViewController:createTableView(self.ConfigServer.wChairCount)
	if tableViewNode then
		tableViewNode:align(display.LEFT_BOTTOM, cell.subItemCount*view.nTableWidth, 0)
		tableViewNode:addTo(cell)
		table.insert(cell.subTableView,tableViewNode)
		-- 刷新table
		local idx = cell.idx
		if idx ~= -1 then
			if self.TableViewArray[tostring(idx*view.nCoulmnCount+cell.subItemCount)] then
				self.TableViewArray[tostring(idx*view.nCoulmnCount+cell.subItemCount)]:updateTableView(tableViewNode)
			else
				tableViewNode:hide()
			end
		end
	end
	cell.subItemCount = cell.subItemCount + 1

	if cell.subItemCount < view.nCoulmnCount then
    	cell:performWithDelay(function ()
    		self:delayCreateTableView(view,cell)
    	end, 0)
    end
end

function TableFrameController:updateTableViewCell(view,cell)
	local idx = cell.idx
	if idx ~= -1 then
		for i=0,view.nCoulmnCount-1 do
			if self.TableViewArray[tostring(idx*view.nCoulmnCount+i)] then
				self.TableViewArray[tostring(idx*view.nCoulmnCount+i)]:updateTableView(cell.subTableView[i+1])
			elseif cell.subTableView[i+1] then
				cell.subTableView[i+1]:hide()
			end
		end
	end
end

function TableFrameController:getTableView(wTableID)
	local idx = math.floor(wTableID/self.ccTableView.nCoulmnCount)
	local cell = self.ccTableView:cellAtIndex(idx)
	if cell and cell.subTableView then
		return cell.subTableView[wTableID%self.ccTableView.nCoulmnCount+1]
	end
end

return TableFrameController