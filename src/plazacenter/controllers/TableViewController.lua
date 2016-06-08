local TableViewController = class("TableViewController")

function TableViewController:ctor(tableFrame)
	self.tableFrame = tableFrame
	self.tableAttribute = {bLocker=false, --密码标志
		bPlaying=false, --游戏标志
		bFocusFrame=false, --框架标志
		wWatchCount=0, --旁观数目
		dwTableOwnerID=0, --桌主索引
		wTableID=0, --桌子号码
		wChairCount=0, --椅子数目
		ClientUserItem={} --用户信息
	}
end

function TableViewController:createFaceBtn(tableView)
	if tableView.userFaceTouch then
		return
	end
	tableView.userFaceTouch = {}
	for i=0,self.tableAttribute.wChairCount-1 do
		local imgFace = cc.uiloader:seekNodeByName(tableView, "Image_Face"..i)
		if imgFace then
			local userFace = display.newNode()
			userFace:setAnchorPoint(imgFace:getAnchorPoint())
			userFace:setPosition(imgFace:getPositionX(),imgFace:getPositionY())
			userFace:setContentSize(40,40)
			userFace:addTo(imgFace:getParent())
			table.insert(tableView.userFaceTouch,userFace)
		end
	end
end

function TableViewController:updateFaceBtnTouch(tableView)
	if tableView.userFaceTouch then
		for i,userFace in ipairs(tableView.userFaceTouch) do			
			userFace:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
			userFace:setTouchSwallowEnabled(false)
			userFace:setTouchEnabled(true)
			userFace:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
						if "began" == event.name then
							userFace.bDrag_ = false
							userFace.beginX = event.x
							userFace.beginY = event.y
						elseif "moved" == event.name then
							if math.abs(event.x-userFace.beginX)>5 or math.abs(event.y-userFace.beginY)>5 then
								userFace.bDrag_ = true
							end	
						elseif "ended" == event.name then
							if not userFace.bDrag_ then
								AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
						            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_TableViewChairClicked,
						            para = {wTableID=self.tableAttribute.wTableID,wChairID=i-1,
						            		bLocker=self.tableAttribute.bLocker,
						            		chairUserItem=self:getClientUserItem(i-1),
						            		sender=userFace}
						        })
							end
						end
						return true
			    	end)
		end
	end
end

function TableViewController:initTableView(wTableID,wChairCount)
	self.tableAttribute.wTableID = wTableID
	self.tableAttribute.wChairCount = wChairCount
end

function TableViewController:updateTableView(tableView)	
	tableView = tableView or self.tableFrame:getTableView(self.tableAttribute.wTableID)
	if not tableView then
		return
	end
	tableView:show()
	if not tableView.bCreatedFaceBtn then
		tableView.bCreatedFaceBtn = true
		self:createFaceBtn(tableView)
	end
	self:updateFaceBtnTouch(tableView)
	-- 是否游戏中
	local imgNormalBg = cc.uiloader:seekNodeByName(tableView, "Image_NormalBg")
	local imgPlayingBg = cc.uiloader:seekNodeByName(tableView, "Image_PlayingBg")
	--imgNormalBg:setVisible(not self:getPlayFlag())
	imgPlayingBg:setVisible(self:getPlayFlag())
	-- 玩家信息
	for i=0,self.tableAttribute.wChairCount-1 do
		while true do
			-- 用户信息
			local userItem = self.tableAttribute.ClientUserItem[tostring(i)]
			if userItem then
				if userItem.wTableID ~= self.tableAttribute.wTableID or i ~= userItem.wChairID then
					break
				end
			end
			-- 头像
			local imgFace = cc.uiloader:seekNodeByName(tableView, "Image_Face"..i)
			if imgFace then
				if userItem then
					imgFace:setSpriteFrame("pic/face/"..userItem.wFaceID..".png")
					imgFace:setVisible(true)
				else
					imgFace:setVisible(false)
				end
			end
			-- phone icon
			local imgPhoneIcon = cc.uiloader:seekNodeByName(tableView, "Image_PhoneIcon"..i)
			if imgPhoneIcon then
				if userItem then
					imgPhoneIcon:setVisible(userItem.wTerminal == 1)
				else
					imgPhoneIcon:setVisible(false)
				end
			end
			-- 昵称
			local labelUserName = cc.uiloader:seekNodeByName(tableView, "Label_Name"..i)
			if labelUserName then
				if userItem then
					labelUserName:setString(userItem.szNickName)
					labelUserName:setVisible(true)
				else
					labelUserName:setVisible(false)
				end
			end
			-- 是否准备
			local imgReady = cc.uiloader:seekNodeByName(tableView, "Image_Ready"..i)
			if imgReady then
				if userItem then
					imgReady:setVisible(not self:getPlayFlag() and userItem.cbUserStatus == US_READY)
				else
					imgReady:setVisible(false)
				end
			end

			break
		end
	end
	--是否锁定
	local imgLocker = cc.uiloader:seekNodeByName(tableView, "Image_Locker")
	imgLocker:setVisible(self:getLockerFlag())
	-- 桌号
	local tableNumber = cc.uiloader:seekNodeByName(tableView, "Label_Number")
	tableNumber:setString(tostring(self.tableAttribute.wTableID+1))
end

function TableViewController:getTableSize(count)
	if count == 2 then
		return cc.size(260,200)
	elseif count == 3 then
		return cc.size(260,250)
	elseif count == 4 then
		return cc.size(260,280)
	elseif count == 6 then
		return cc.size(280,280)
	elseif count == 8 then
		return cc.size(370,290)
	else
		return cc.size(260,200)
	end
end

function TableViewController:createTableView(count)
	local node, width, height = cc.uiloader:load(TABLE_FRAME_TABLE_CSB_FILE_PRE..count..".ExportJson")
    if not node then
        return
    end

    return node
end

function TableViewController:getPlayFlag()
	return self.tableAttribute.bPlaying
end

function TableViewController:getLockerFlag()
	return self.tableAttribute.bLocker
end

function TableViewController:getNullChairCount()
	return self.tableAttribute.wChairCount-table.nums(self.tableAttribute.ClientUserItem)
end

function TableViewController:getFirstNullChairID()
	for i=0,self.tableAttribute.wChairCount-1 do
		if not self.tableAttribute.ClientUserItem[tostring(i)] then
			return i
		end
	end
end

function TableViewController:setTableStatus(bPlaying, bLocker)
	if self.tableAttribute.bLocker ~= bLocker or self.tableAttribute.bPlaying ~= bPlaying then
		self.tableAttribute.bPlaying = bPlaying
		self.tableAttribute.bLocker =bLocker
		self:updateTableView()
	end
end

function TableViewController:setClientUserItem(wChairID, clientUserItem)
	self.tableAttribute.ClientUserItem[tostring(wChairID)] = clientUserItem
	self:updateTableView()
end

function TableViewController:getClientUserItem(wChairID)
	return self.tableAttribute.ClientUserItem[tostring(wChairID)]
end
return TableViewController