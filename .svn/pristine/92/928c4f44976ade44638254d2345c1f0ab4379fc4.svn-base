local NormalGameServerListWidget = class("NormalGameServerListWidget")

function NormalGameServerListWidget:ctor(scene,wKindID)
    local node, width, height = cc.uiloader:load(NORMAL_GAME_SERVER_ROOM_LIST_CSB_FILE)
    if not node then
    	return
    end

    -- add animation
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(ANIMATION_SERVER_STATUS_CSB_FILE)
    
    self.wKindID = wKindID
    self.attachNode = node
--[[
    node:setTouchEnabled(true)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        if "began" == event.name then
            node:removeFromParent()
        end
        return true
        end)]]
    local imgGameName = cc.uiloader:seekNodeByName(node, "Image_GameName")
    if imgGameName then
        local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
        local frame = sharedSpriteFrameCache:getSpriteFrame("pic/plazacenter/GameName/u_t_"..wKindID..".png")
        if frame then
            imgGameName:setSpriteFrame(frame)
        else
            imgGameName:hide()
        end
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Goback")
    :onButtonClicked(function ()
        node:removeFromParent()
        if scene.showImgGameArea then
            scene:showImgGameArea(true)
        end
    end)
    scene:buttonTouchEvent(closeBtn)

    self.gameServerListPanel = cc.uiloader:seekNodeByName(node, "Panel_List")
    self.gameServerListView = cc.ui.UIListView.new({
                    viewRect = cc.rect(0, 0, 
                            self.gameServerListPanel:getContentSize().width, 
                            self.gameServerListPanel:getContentSize().height),
                    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
                    alignment = cc.ui.UIListView.ALIGNMENT_TOP})
    self.gameServerListView:addTo(self.gameServerListPanel)
    self:addGameServerListItem()

    if scene.mainPanelBg then
        scene.mainPanelBg:addChild(node)
    else
        scene:addChild(node)
    end

    local animationNode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    animationNode:setTouchEnabled(true)
    animationNode:setTouchSwallowEnabled(true)
    G_ShowNodeWithBackout(animationNode)
end

function NormalGameServerListWidget:getServerStatusLevel(dwOnlineCount,dwMaxCount)
    if dwMaxCount == nil or dwMaxCount == 0 then
        dwMaxCount = 2
    end
    local per = math.floor((dwOnlineCount*100)/dwMaxCount)
    local statusLevel = "free"
    if per > 80 then
        statusLevel = "full"
    elseif per > 60 then
        statusLevel = "busy"
    elseif per > 20 then
        statusLevel = "crowd"
    end
    return statusLevel
end

function NormalGameServerListWidget:createServerItem(gameServer,index)    
    local content = cc.uiloader:load(NORMAL_GAME_SERVER_ITEM_CSB_FILE)
    if content then
        local imgBg = cc.uiloader:seekNodeByName(content, "Image_Bg")
        local labelRoomID = cc.uiloader:seekNodeByName(content, "Label_RoomID")
        local labelRoomName = cc.uiloader:seekNodeByName(content, "Label_RoomName")
        local imgCoinIcon = cc.uiloader:seekNodeByName(content, "Image_CoinIcon")
        local labelRoomDes = cc.uiloader:seekNodeByName(content, "Label_RoomDesc")
        local labelRoomRate = cc.uiloader:seekNodeByName(content, "Label_RoomRate")
        local imgStatusBg = cc.uiloader:seekNodeByName(content, "Image_StatusBg")
        local enterBtn = cc.uiloader:seekNodeByName(content, "Button_Enter")

        local szSplit = string.split(gameServer.szGameLevel,"-")
        local szGameLevel = szSplit[1] or gameServer.szGameLevel
        local wKindID = gameServer.wKindID
        local gameKind = ServerListData:GetGameKindByKind(gameServer.wKindID)
        if imgBg and index%2==0 then
            local contentSize = imgBg:getContentSize()
            imgBg:setSpriteFrame(display.newSpriteFrame("pic/plazacenter/Sundry/u_server_item_blackbg.png"),cc.rect(280,6,2,1))
            imgBg:setContentSize(contentSize)
        end
        if labelRoomID then
            labelRoomID:setString(tostring(index))
        end
        local nextPosX = nil
        local nameWidth = nil
        if labelRoomName then
            labelRoomName:setString(szGameLevel)
            nextPosX = labelRoomName:getPositionX()
            nextPosX = nextPosX+labelRoomName:getContentSize().width+2
        end
        if imgCoinIcon and nextPosX then
            imgCoinIcon:setPositionX(nextPosX)
            nextPosX = nextPosX + imgCoinIcon:getContentSize().width+2
        end
        if labelRoomDes and nextPosX then
            labelRoomDes:setString(gameServer.szDescription)
            labelRoomDes:setPositionX(nextPosX)
        end
        if imgStatusBg then
            local status = self:getServerStatusLevel(gameServer.dwOnLineCount,gameServer.dwFullCount)
            local armature = ccs.Armature:create("ServerStatusAnimation")
            local size = imgStatusBg:getContentSize()
            armature:align(display.CENTER, size.width/2, size.height/2)
            armature:addTo(imgStatusBg)
            if status=="full" then
                armature:getAnimation():play(status)
            else
                armature:getAnimation():play(status,-1,0)
                armature:getAnimation():pause()
                -- 随机播放动画
                imgStatusBg:schedule(function ()
                    armature:getAnimation():play(status,-1,0)
                end, status=="full" and 0 or math.random(4,8))
            end
            
        end
        if enterBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(enterBtn)
            enterBtn:onButtonClicked(function ()
                AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
                    name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_GameServerItemClicked,
                    para = gameServer})
                self.attachNode:removeFromParent()
            end)
        end
    end
    
    return content
end

function NormalGameServerListWidget:addGameServerListItem()
	if self.gameServerListView then
        self.gameServerListView:removeAllItems()
        local gameServerData = ServerListData:GetGameServerByGameKind(self.wKindID)
        for k,v in pairs(gameServerData) do
            local content = self:createServerItem(v,k)
            local item = self.gameServerListView:newItem()
            item:addContent(content)
            item:setItemSize(920, 70)
            self.gameServerListView:addItem(item)

            item.gameServer = v
        end
        self.gameServerListView:reload()
    end
end

return NormalGameServerListWidget