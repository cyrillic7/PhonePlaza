local GameItemListController = class("GameItemListController")

GameItemListController.kindGroups = GlobalKindGroups or {
	Normal560 = "560",-- 阳山9张
	Normal450 = "450",
	Normal460 = "460",
	Normal590 = "590",
	Normal430 = "430",-- 6人换牌牛牛
	Normal210 = "210",-- 2人牛牛
	Normal130 = "130",-- 通比牛牛
	Match310 = "310",-- 二斗比赛
}
-- 审核中，修改显示选项
if GlobalPlatInfo.isInReview then
	GameItemListController.kindGroups = {
		Normal560 = "560",-- 阳山9张
		Normal430 = "430",-- 6人换牌牛牛
		Normal210 = "210",-- 2人牛牛
		Normal130 = "130",-- 通比牛牛
	}
end

GameItemListController.diffApkUrls = {
	Normal450 = {
		url="MoreGame/GameCatchFishQCN.apk",
		packageName="com.game.GameCatchFish719",
		activityName="GameCatchFish"
	},
	Normal460 = {
		url="MoreGame/BullfightGameQCN.apk",
		packageName="com.xw.BullfightGame719",
		activityName="BullfightGame"},
}
if device.platform == "ios" then
	GameItemListController.diffApkUrls = {
		Normal450 = {
			url="itms://itunes.apple.com/cn/app/kuai-wan-bu-yu/id1057424577?l=en&mt=8",
			packageName="qy.gamecatchfish719://",
			activityName="GameCatchFish"
		},
		Normal460 = {
			url="itms://itunes.apple.com/cn/app/kuai-wan-niu-niu/id1054231208?l=en&mt=8",
			packageName="qy.bullfightgame719://",
			activityName="BullfightGame"},
	}
end

function GameItemListController:ctor(frameScene)
	self.frameScene = frameScene

	self.UpdaterManager = require("common.UpdaterManager").new()
end

function GameItemListController:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.LP_ListFinish] = handler(self, self.receiveGameItemFinish)
    eventListeners[appBase.Message.Ctrl_GameTypeSelectChanged] = handler(self, self.receiveGameTypeSelectChanged)
    eventListeners[ServerMatchData.Message.MS_MatchKindInsert] = handler(self, self.receiveMatchKindInsertMessage)
    eventListeners[appBase.Message.Ctrl_DownLoadClient] = handler(self, self.receiveDownLoadClientMessage)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function GameItemListController:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function GameItemListController:isExsitGameKind(gameKind,bNormalGame)
	local keyName = nil
	if bNormalGame then
		keyName = "Normal"..gameKind
	else
		keyName = "Match"..gameKind
	end
	if self.kindGroups[keyName] then
		return true
	end
end

function GameItemListController:getOtherApkKind(gameKind,bNormalGame)
	local keyName = nil
	if bNormalGame then
		keyName = "Normal"..gameKind
	else
		keyName = "Match"..gameKind
	end
	if self.diffApkUrls[keyName] then
		return self.diffApkUrls[keyName]
	end
end

function GameItemListController:receiveGameItemFinish()
	self:updateGameItemList()
end

function GameItemListController:receiveGameTypeSelectChanged(event)
	local Params = event.para
    if Params.wTypeID then
    	self:setPageType(Params.wTypeID)
    end  
end

function GameItemListController:receiveMatchKindInsertMessage(event)
	-- 单个插入有问题，故清空重新刷新
	self:updateGameItemList()
end

function GameItemListController:receiveDownLoadClientMessage(event)
	local wKindID = event.para.wKindID or 0
	local nItemType = event.para.nItemType or 0
	local strExeName = nil
    if nItemType == eGameItemType.eItemTypeNormalGame then
        strExeName = ServerListData:GetGameExeNameByKind(wKindID)
    elseif nItemType == eGameItemType.eItemTypeMatchGame then
        strExeName = ServerMatchData:GetMatchExeNameByKind(wKindID)
    end
    if not strExeName then
        local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="获取游戏名称失败，下载游戏失败，请退出大厅重新登录游戏！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return true
    end
    if not version then
		local updater = self.UpdaterManager:downLoadClient(strExeName, wKindID, 
			function(updater)
		    	self:updaterHandler(updater)
		    end)
		if not updater then
			G_showFloatTips("该游戏正在下载中，请等待...")
			return
		end
	    updater.nItemType = nItemType
	    self.frameScene:addChild(updater)
    end
end

function GameItemListController:updateGameItemList()
	self.nPageType = self.nPageType or eGameItemPageType.eAllGame
	if self.frameScene then
		if self.frameScene.imgGameItemList then
			self.frameScene.gameItemList = self.frameScene.gameItemList or cc.ui.UIPageView.new {
			        viewRect = cc.rect(0, 
			        		0, 
			        		self.frameScene.imgGameItemList:getContentSize().width, 
			        		self.frameScene.imgGameItemList:getContentSize().height),
			        column = math.floor(self.frameScene.imgGameItemList:getContentSize().width/(128+10)), 
			        row = math.floor(self.frameScene.imgGameItemList:getContentSize().height/(128+5)),
			        padding = {left = 20, right = 20, top = 10, bottom = 10},
			        columnSpace = 10, rowSpace = 5}
			        :onTouch(handler(self, self.touchListener))
			        :addTo(self.frameScene.imgGameItemList)
			self.frameScene.gameItemList:removeAllItems()
			self.frameScene.gameItemList:reload()
			
			if self.nPageType == eGameItemPageType.eAllGame then
				self:AddNormalGame(self.frameScene.gameItemList)
				self:AddMatchGame(self.frameScene.gameItemList)
			elseif self.nPageType == eGameItemPageType.eMatchGame then
				self:AddMatchGame(self.frameScene.gameItemList)
			elseif self.nPageType == eGameItemPageType.eNormalGame then
				self:AddNormalGame(self.frameScene.gameItemList)
			end
			-- 显示或隐藏
			self:showFriendsPlayWidget(self.nPageType == eGameItemPageType.eFriendsPlay)
			self:showHallHornMsgArea(self.nPageType ~= eGameItemPageType.eFriendsPlay)
		    self.frameScene.gameItemList:reload()
		end
	end
end

function GameItemListController:showFriendsPlayWidget(bShow)
	if not self.friendsPlayWidget then
		if not bShow then
			return
		end
		self.friendsPlayWidget = require("plazacenter.widgets.FriendsPlayWidget").new(self.frameScene.imgGameArea)
		self.friendsPlayWidget:setVisible(false)
	end
	self.friendsPlayWidget:setVisible(bShow)
end

function GameItemListController:showHallHornMsgArea(bShow)
	if self.frameScene and self.frameScene.imgHornArea then
		self.frameScene.imgHornArea:setVisible(bShow)
	end
end

function GameItemListController:touchListener(event)
	--dump(event)
	if event.name == "clicked" then
		if event.item then
			-- 不同APK游戏，如捕鱼
			if self:getOtherApkKind(event.item.wKindID, event.item.nItemType) then
				local data = self:getOtherApkKind(event.item.wKindID, event.item.nItemType)
				if device.platform == "android" then
					local succ,bInstalled = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "checkApkInstalled", {data.packageName}, "(Ljava/lang/String;)Z")
					if bInstalled then
						-- 启动应用
						local para = {pwd=GlobalUserInfo.szPassword,account=GlobalUserInfo.szAccounts}
						succ = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "startOtherApk", {data.packageName,data.activityName,json.encode(para)}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
						if not succ then
							local dataMsgBox = {
					            nodeParent=self.frameScene,
					            msgboxType=MSGBOX_TYPE_OK,
					            msgInfo="打开游戏应用失败，可尝试删除对应应用再进行尝试。给您带来不便，请谅解！"
					        }
					        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
						end
					else
						-- 下载安装
						local dataMsgBox = {
				            nodeParent=self.frameScene,
				            msgboxType=MSGBOX_TYPE_OKCANCEL,
				            msgInfo="游戏应用还没下载，是否进行下载？(建议在Wifi环境下下载)",
				            callBack=function (ret)
				            	if ret == MSGBOX_RETURN_OK then
				            		luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "downLoadApk", {GlobalPlatInfo.szDownLoadPreUrl..data.url}, "(Ljava/lang/String;)V")
				            	end
				            end
				        }
				        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
					end
				elseif device.platform == "ios" then
					local succ,bInstalled = luaoc.callStaticMethod("LuaCallObjcFuncs", "isCanOpenURL", 
            					{url=data.packageName})
					if succ and bInstalled == 1 then
						-- 启动应用
						local para = {pwd=GlobalUserInfo.szPassword,account=GlobalUserInfo.szAccounts}
						luaoc.callStaticMethod("LuaCallObjcFuncs", "openURL", 
            					{url=data.packageName..string.urlencode(json.encode(para))})
					else
						-- 跳转app store
						device.openURL(data.url)
					end
				end
				return
			end
			-- 判断是否需要下载或升级
			if not self:checkDownLoadClient(event.item.wKindID,event.item.nItemType) then
				AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
		            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_GameItemClicked,
		            para = {nItemType=event.item.nItemType,wKindID=event.item.wKindID}})
			end			
		end
	end
end

function GameItemListController:setPageType(nTypeID)
	self.nTypeID = nTypeID
	if nTypeID == eGameItemIndex.eAllGameIndex then
		self.nPageType = eGameItemPageType.eAllGame
	elseif nTypeID == eGameItemIndex.eMatchGameIndex then
		self.nPageType = eGameItemPageType.eMatchGame
	elseif nTypeID == eGameItemIndex.eActivityIndex then
		self.nPageType = eGameItemPageType.eActivity
	elseif nTypeID == eGameItemIndex.eFriendsPlayIndex then
		self.nPageType = eGameItemPageType.eFriendsPlay
	else
		self.nPageType = eGameItemPageType.eNormalGame
	end

	self:updateGameItemList()
end

function GameItemListController:createGameItemSprite(fileName)
	local content = display.newSprite(fileName)
	content:align(display.CENTER, 128/2, 128/2)
    content:setTouchSwallowEnabled(false)
	content:setTouchEnabled(true)
	content:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if "began" == event.name then
			content:scaleTo(0.1,0.9)
		elseif "ended" == event.name then
			content:scaleTo(0.1,1)
		end
		return true
    	end)

	return content
end
function GameItemListController:AddNormalGame(gameItemList)
	local nTypeID = self.nTypeID or -1
	if self.nPageType == eGameItemPageType.eAllGame then
		nTypeID = -1
	end
	local gameKinds = ServerListData:GetGameKindByGameType(nTypeID)
	for i,v in ipairs(gameKinds) do
		if self:isExsitGameKind(v.wKindID,true) then
			local item = gameItemList:newItem()
	    	local content = self:createGameItemSprite("pic/plazacenter/GameItem/GameItem_"..v.wKindID..".png")
			item:addChild(content)
			item.content = content
			item.wKindID = v.wKindID
			item.nItemType = eGameItemType.eItemTypeNormalGame
			gameItemList:addItem(item)   
			
			local updater = self.UpdaterManager:getDownLoadClient(item.wKindID)
	        if updater then
	        	self:createProgress(item)

				updater.percentage = updater.percentage or 0
		    	item.progress:setPercentage(updater.percentage)
	        end
		end
	end
end

function GameItemListController:AddMatchGame(gameItemList)
	print("GameItemListController:AddMatchGame")
	local matchKinds = ServerMatchData:GetMatchKindItem()
	for k,v in pairs(matchKinds) do
		if self:isExsitGameKind(v.dwKindID,false) then
			local item = gameItemList:newItem()
	    	local content = self:createGameItemSprite("pic/plazacenter/GameItem/GameItem_"..v.dwKindID..".png")
			item:addChild(content)
			item.content = content
			item.wKindID = v.dwKindID
			item.nItemType = eGameItemType.eItemTypeMatchGame
	        gameItemList:addItem(item)
			
			local updater = self.UpdaterManager:getDownLoadClient(item.wKindID)
	        if updater then
	        	self:createProgress(item)

				updater.percentage = updater.percentage or 0
		    	item.progress:setPercentage(updater.percentage)
	        end
	    end
	end
end

function GameItemListController:createProgress(item)
	if item and not item.progress then
		item.content:setColor(cc.c3b(125, 125, 125))
		local progress = cc.ProgressTimer:create(display.newSprite("pic/plazacenter/GameItem/GameItem_"..item.wKindID..".png"))
        progress:setType(0)
        progress:setReverseDirection(false)
        progress:align(display.CENTER, 128/2, 128/2)
        item:addChild(progress)
        progress:setTouchSwallowEnabled(true)
		progress:setTouchEnabled(true)
		item.progress = progress
	end
end

function GameItemListController:releaseProgress(item)
	if item and item.progress then
		item.content:setColor(cc.c3b(255, 255, 255))
		item.progress:removeFromParent()
		item.progress = nil
	end
end

function GameItemListController:getGameItem(wKindID)
	if self.frameScene.gameItemList then
		for i,v in ipairs(self.frameScene.gameItemList.items_) do
			if v.wKindID == wKindID then
				self:createProgress(v)
				return v
			end
		end
	end
end

function GameItemListController:checkDownLoadClient(wKindID,nItemType)
	local version,strExeName = AppBaseInstanse.PLAZACENTER_APP:getClientVersion(wKindID,nItemType)
    if not strExeName then
        local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="获取游戏种类失败，进入游戏服务列表失败！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return true
    end
    if not version then
    	local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OKCANCEL,
            msgInfo="游戏还没有下载，是否进行下载？(建议在Wifi环境下下载)",
            callBack=function (ret)
            	if ret == MSGBOX_RETURN_OK then
            		local updater = self.UpdaterManager:downLoadClient(strExeName, wKindID, 
	            		function(updater)
					    	self:updaterHandler(updater)
					    end)
            		if not updater then
            			G_showFloatTips("该游戏正在下载中，请等待...")
            			return
            		end
				    updater.nItemType = nItemType
				    self.frameScene:addChild(updater)
            	end
            end
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
	    return true
    end
    
    return false
end

function GameItemListController:updaterHandler(updater)
	dump(updater.stateValue,updater.state)
	if updater then
		local item = self:getGameItem(updater.wKindID)
	    if updater.state == "success" then
	    	-- 更新界面
	    	self:releaseProgress(item)
	    	-- 打开游戏列表
    		AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
	            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_GameItemClicked,
	            para = {nItemType=updater.nItemType,wKindID=updater.wKindID}})
    		-- 移除下载组件
	        updater:removeFromParent()
	    elseif updater.state == "error" then
	    	local kindName = nil
	    	if updater.nItemType == eGameItemType.eItemTypeNormalGame then
	    		kindName = ServerListData:GetGameNameByKind(updater.wKindID)
	    	else
	    		kindName = ServerMatchData:GetMatchNameByKind(updater.wKindID)
	    	end
	    	kindName = kindName or ""
	    	G_showFloatTips("下载游戏【"..kindName.."】失败，请稍后重试！")   	
	    	self:releaseProgress(item)
	        updater:removeFromParent()
	    elseif updater.state == "progress" then
	    	if item and item.progress then
	    		item.progress:setPercentage(updater.stateValue)
	    	end
	    	updater.percentage = updater.stateValue
	    end
	end
end

return GameItemListController