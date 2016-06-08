local MatchGameListWidget = class("MatchGameListWidget")

MatchGameListWidget.listItemRootHeight = 45
MatchGameListWidget.listItemRoomHeight = 70
MatchGameListWidget.btnType = {
    freeSignUp = 1,
    notFreeSignUp = 2,
    exitGame = 3
}

function MatchGameListWidget:ctor(scene,wKindID)
    local node, width, height = cc.uiloader:load(GAME_SERVER_ROOM_LIST_CSB_FILE)
    if not node then
    	return
    end
    
    self.wKindID = wKindID
    self.attachNode = node
    self.frameScene = scene

    node:setNodeEventEnabled(true)
    node.onCleanup = handler(self, self.onCleanup)
    --node.onExit = handler(self, self.onExit)
--[[
    node:setTouchEnabled(true)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        if "began" == event.name then
            --node:removeFromParent()
        end
        return true
        end)]]
    local imgGameName = cc.uiloader:seekNodeByName(node, "Image_GameName")
    if imgGameName then
        local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
        local frame = sharedSpriteFrameCache:getSpriteFrame("pic/plazacenter/GameName/u_t_"..wKindID..".png")
        if frame then
            imgGameName:setSpriteFrame(frame)
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

    self.listPanel = cc.uiloader:seekNodeByName(node, "Panel_List")
    self.listViewSize = cc.size(self.listPanel:getContentSize().width-80, 
                            self.listPanel:getContentSize().height)
    self.matchGameListView = cc.ui.UIListView.new({
                    viewRect = cc.rect(40, 0, 
                            self.listViewSize.width, 
                            self.listViewSize.height),
                    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
                    alignment = cc.ui.UIListView.ALIGNMENT_TOP})
    self.matchGameListView:addTo(self.listPanel)
    self.matchGameListView:onScroll(handler(self,self.onScrollListener))
    self:addMatchGameListItem()

    if scene.mainPanelBg then
        scene.mainPanelBg:addChild(node)
    else
        scene:addChild(node)
    end

    local animationNode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    animationNode:setTouchEnabled(true)
    animationNode:setTouchSwallowEnabled(true)
    G_ShowNodeWithBackout(animationNode)

    self:onInit()
end

function MatchGameListWidget:onInit()
    self:registerEvents()
    local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    self.scheduleHandler = scheduler.scheduleGlobal(function ()
        local tagMatchSerial = {
            dwMatchInfoID=0,
            dwKindID=self.wKindID,
            dwMatchType=0,
            dwFullPlayerNum=0
        }
        self.frameScene.MissionMatch:requestCommand(MDM_GL_C_DATA,SUB_GL_C_MATCH_NUM,tagMatchSerial,"tagMatchSerial")
    end, 3)
end

function MatchGameListWidget:onCleanup()
    print("MatchGameListWidget:onCleanup")
    self:unregisterEvents()
    local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    scheduler.unscheduleGlobal(self.scheduleHandler)
end

function MatchGameListWidget:registerEvents()
    local eventListeners = {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[ServerMatchData.Message.MS_MatchInfoInsert] = handler(self, self.receiveMatchInfoInsertMessage)
    eventListeners[ServerMatchData.Message.MS_MatchInfoUpdate] = handler(self, self.receiveMatchInfoUpdateMessage)
    eventListeners[ServerMatchData.Message.MS_MatchInfoDelete] = handler(self, self.receiveMatchInfoDeleteMessage)
    eventListeners[ServerMatchData.Message.MS_MatchPlayerNumUpdate] = handler(self, self.receiveMatchInfoUpdateMessage)
    eventListeners[ServerMatchData.Message.MS_MatchDataReset] = handler(self, self.receiveMatchDataResetMessage)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function MatchGameListWidget:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function MatchGameListWidget:getServerStatusLevel(dwOnlineCount,dwMaxCount)
    if dwMaxCount == nil or dwMaxCount == 0 then
        dwMaxCount = 2
    end
    local per = math.floor((dwOnlineCount*100)/dwMaxCount)
    local statusLevel = 0
    if per > 80 then
        statusLevel = 3
    elseif per > 60 then
        statusLevel = 2
    elseif per > 20 then
        statusLevel = 1
    end
    return statusLevel
end

function MatchGameListWidget:getRoomInfo(matchInfo)
    local roomInfo = ""
    if matchInfo.dwSignUpScore > 0 then
        roomInfo = roomInfo..matchInfo.dwSignUpScore.."金币"
    end
    if matchInfo.dwSignUpTicket > 0 then
        if string.len(roomInfo) < 1 then
            roomInfo = roomInfo..matchInfo.dwSignUpTicket.."参赛券"
        else
            roomInfo = roomInfo.." & "..matchInfo.dwSignUpTicket.."参赛券"
        end
    end
    if string.len(roomInfo) < 1 then
        roomInfo = "免费报名"
    end

    return roomInfo
end

function MatchGameListWidget:getStartInfo(matchInfo)
    local sMatchTime = ""
    if matchInfo.MatchSerial.dwMatchType ~=4 then
        local sTimeNow = {
            wYear = tonumber(os.date("%Y")),
            wMonth = tonumber(os.date("%m")),
            wDay = tonumber(os.date("%d"))
        }
        if sTimeNow.wYear == matchInfo.tMatchTime.wYear 
            and sTimeNow.wMonth == matchInfo.tMatchTime.wMonth 
            and sTimeNow.wDay == matchInfo.tMatchTime.wDay then
            sMatchTime = string.format("今天 %02d:%02d",matchInfo.tMatchTime.wHour,matchInfo.tMatchTime.wMinute)
        else
            sMatchTime = string.format("%02d-%02d %02d:%02d",matchInfo.tMatchTime.wMonth,matchInfo.tMatchTime.wDay,matchInfo.tMatchTime.wHour,matchInfo.tMatchTime.wMinute)
        end
    else
        sMatchTime = string.format("满%d人开赛",matchInfo.MatchSerial.dwFullPlayerNum)
    end

    return sMatchTime
end

function MatchGameListWidget:getOnlineNum(matchInfo)
    local sPlayerNum = ""
    if matchInfo.MatchSerial.dwMatchType ~=4 then
        sPlayerNum = string.format("%d人已报名",matchInfo.dwSignUpPlayerNum)
    elseif matchInfo.MatchSerial.dwFullPlayerNum > 0 then
        sPlayerNum = string.format("%d人已参赛",matchInfo.dwSignUpPlayerNum)
    end

    return sPlayerNum
end

function MatchGameListWidget:signUpMatch(matchInfo)
        -- 退赛
    if matchInfo.dwSignUp == SignUpStatus.SignUp then
        local tagMatchID = {
            dwClientVersion=17039361,
            MatchSerial=matchInfo.MatchSerial
        }
        self.frameScene.MissionMatch:requestCommand(MDM_GL_C_DATA,SUB_GL_C_MATCH_WITHDRAWAL,tagMatchID,"tagMatchID")
    -- 报名
    elseif matchInfo.dwSignUp == SignUpStatus.NoSignUp then
        require("plazacenter.widgets.MatchSignUpWidget").new(self.frameScene, matchInfo)
    end
end

function MatchGameListWidget:compItemFunc(item1,item2)
    if item1.dwSortID < item2.dwSortID then
        return true
    else
        return false
    end
end

function MatchGameListWidget:getBtnPicAndType(matchInfo)
    local btnType = nil
    local strPicBg = nil
    local strPicText = nil
    -- 已报名
    if matchInfo.dwSignUp == SignUpStatus.SignUp then 
        btnType = self.btnType.exitGame
        strPicBg = "pic/plazacenter/Button/u_btn_sr.png"
        strPicText = "pic/plazacenter/Text/u_t_exit.png"
    else
        -- vip专享
        if matchInfo.dwMemberOrder > 0 then
            btnType = self.btnType.vipSignUp
            strPicBg = "pic/plazacenter/Button/u_btn_sr.png"
            strPicText = "pic/plazacenter/Text/u_competition_text_vip.png"
        -- 免费报名
        elseif matchInfo.dwSignUpScore == 0 and matchInfo.dwSignUpTicket == 0 then
            btnType = self.btnType.freeSignUp
            strPicBg = "pic/plazacenter/Button/u_btn_sy.png"
            strPicText = "pic/plazacenter/Text/u_t_fs.png"
        else
            btnType = self.btnType.notFreeSignUp
            strPicBg = "pic/plazacenter/Button/u_btn_sb.png"
            strPicText = "pic/plazacenter/Text/u_t_bm.png"
        end
    end
    return strPicBg,strPicText,btnType
end

function MatchGameListWidget:createRootItem(matchType)
    local content = display.newNode()
    content:setContentSize(self.listViewSize.width,MatchGameListWidget.listItemRootHeight)
    display.newSprite("#pic/plazacenter/Sundry/u_icon_ht.png")
            :align(display.CENTER, 40/840*self.listViewSize.width, MatchGameListWidget.listItemRootHeight/2)
            :addTo(content)
    content.labRoomName = cc.ui.UILabel.new(
                    {text = matchType.szMatchType,
                    font = "微软雅黑",
                    size = 28,
                    align = cc.ui.TEXT_ALIGN_LELF,
                    valign = cc.ui.VERTICAL_TEXT_ALIGNMENT_CENTER,
                    color = cc.c3b(255, 252, 0),
                    dimensions = cc.size(300, 36),
                    x = 65/840*self.listViewSize.width,
                    y = MatchGameListWidget.listItemRootHeight/2 })
                    :addTo(content)
    
    return content
end

function MatchGameListWidget:createRoomItem(matchInfo)    
    local content = display.newNode()
    content:setContentSize(self.listViewSize.width,MatchGameListWidget.listItemRoomHeight)
    content.labRoomName = cc.ui.UILabel.new(
                    {text = matchInfo.szRemark,
                    font = "微软雅黑",
                    size = 25,
                    align = cc.ui.TEXT_ALIGNMENT_LEFT,
                    valign = cc.ui.VERTICAL_TEXT_ALIGNMENT_CENTER,
                    color = display.COLOR_WHITE,
                    dimensions = cc.size(280, 30),
                    x = 15/840*self.listViewSize.width,
                    y = MatchGameListWidget.listItemRoomHeight/2 })
                    :addTo(content)
    content.labRoomInfo = cc.ui.UILabel.new(
                    {text = self:getRoomInfo(matchInfo),
                    font = "微软雅黑",
                    size = 25,
                    align = cc.ui.TEXT_ALIGN_CENTER,
                    valign = cc.ui.VERTICAL_TEXT_ALIGNMENT_CENTER,
                    color = display.COLOR_RED,
                    dimensions = cc.size(120, 30),
                    x = 295/840*self.listViewSize.width,
                    y = MatchGameListWidget.listItemRoomHeight/2 })
                    :addTo(content)
    content.labStartInfo = cc.ui.UILabel.new(
                    {text = self:getStartInfo(matchInfo),
                    font = "微软雅黑",
                    size = 25,
                    align = cc.ui.TEXT_ALIGN_CENTER,
                    valign = cc.ui.VERTICAL_TEXT_ALIGNMENT_CENTER,
                    color = display.COLOR_WHITE,
                    dimensions = cc.size(140, 30),
                    x = 410/840*self.listViewSize.width,
                    y = MatchGameListWidget.listItemRoomHeight/2 })
                    :addTo(content)
    content.labOnlineNum = cc.ui.UILabel.new(
                    {text = self:getOnlineNum(matchInfo),
                    font = "微软雅黑",
                    size = 25,
                    align = cc.ui.TEXT_ALIGN_CENTER,
                    valign = cc.ui.VERTICAL_TEXT_ALIGNMENT_CENTER,
                    color = display.COLOR_WHITE,
                    dimensions = cc.size(140, 30),
                    x = 570/840*self.listViewSize.width,
                    y = MatchGameListWidget.listItemRoomHeight/2 })
                    :addTo(content)
    local strPicBg,strPicText,btnType = self:getBtnPicAndType(matchInfo)
    content.btnControl = cc.Sprite:createWithSpriteFrameName(strPicBg)
    content.btnControlText = cc.Sprite:createWithSpriteFrameName(strPicText)
                                :align(display.CENTER, content.btnControl:getContentSize().width/2, content.btnControl:getContentSize().height/2)
                                :addTo(content.btnControl)
    content.btnControl:align(display.CENTER, 775/840*self.listViewSize.width, MatchGameListWidget.listItemRoomHeight/2)
    content.btnControl:addTo(content)
    content.btnControl:setTouchEnabled(true)
    content.btnControl:setTouchSwallowEnabled(true)
    content.btnControl:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        if "began" == event.name then
            content.btnControl:scaleTo(0.1,0.9)
        elseif "ended" == event.name then
            content.btnControl:scaleTo(0.1,1)
            self:signUpMatch(matchInfo)
        end
        return true
        end)
    content.btnType = btnType
    
    return content
end

function MatchGameListWidget:updateRoomItem(roomItem,matchInfo)
    local roomContent = roomItem:getContent()
    if roomContent.labRoomName then
        roomContent.labRoomName:setString(matchInfo.szRemark)
    end
    if roomContent.labRoomInfo then
        roomContent.labRoomInfo:setString(self:getRoomInfo(matchInfo))
    end
    if roomContent.labStartInfo then
        roomContent.labStartInfo:setString(self:getStartInfo(matchInfo))
    end
    if roomContent.labOnlineNum then
        roomContent.labOnlineNum:setString(self:getOnlineNum(matchInfo))
    end
    if roomContent.btnControl then
        local strPicBg,strPicText,btnType = self:getBtnPicAndType(matchInfo)
        roomContent.btnControl:setSpriteFrame(strPicBg)
        roomContent.btnControlText:setSpriteFrame(strPicText)
        roomContent.btnType = btnType
    end
end

function MatchGameListWidget:getSortID(matchInfo)
    if matchInfo.MatchSerial.dwMatchType == 4 then
        return matchInfo.MatchSerial.dwFullPlayerNum
    else
        local time = matchInfo.tMatchTime
        return tonumber(string.format("%d%02d%02d%02d%02d",time.wYear,time.wMonth,time.wDay,time.wHour,time.wMinute))
    end
end

function MatchGameListWidget:createListItem(matchType)
    local matchInfos = ServerMatchData:GetMatchServerItemByKindIDAndType(self.wKindID,matchType.dwType)
    if #matchInfos < 1 then
        return nil
    end
    local contentSize = cc.size(self.listViewSize.width, 
                            MatchGameListWidget.listItemRoomHeight*#matchInfos+MatchGameListWidget.listItemRootHeight)
    local contentList = cc.ui.UIListView.new({
                    viewRect = cc.rect(0, 0, 
                            contentSize.width, 
                            contentSize.height),
                    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL})
    contentList:setContentSize(contentSize.width,contentSize.height)
    contentList.touchNode_:setTouchEnabled(false)
    -- 添加RootItem
    local rootContent = self:createRootItem(matchType)
    local item = contentList:newItem()
            item:addContent(rootContent)
            item:setItemSize(contentSize.width, MatchGameListWidget.listItemRootHeight)
            contentList:addItem(item)

            item.dwSortID = -1
    item:setBg("#pic/plazacenter/Sundry/u_translucent_bg3.png")
    -- 添加RoomItem
    for k,v in pairs(matchInfos) do
        local roomContent = self:createRoomItem(v)
        local item = contentList:newItem()
        item:addContent(roomContent)
        item:setItemSize(contentSize.width, MatchGameListWidget.listItemRoomHeight)
        contentList:addItem(item)

        item.dwSortID = self:getSortID(v)
        item.matchInfo = v

        -- for test
        --[[if matchType.dwType == 1 then
            if not self.bTest then
                self.bTest = true
                local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
                scheduler.performWithDelayGlobal(function ()
                    self:receiveMatchInfoDeleteMessage({para=v})
                end, 5)
                scheduler.performWithDelayGlobal(function ()
                    self:receiveMatchInfoInsertMessage({para=v})
                end, 10)
            end            
        end]]
    end
    -- 排序
    contentList:sortItems(handler(self,self.compItemFunc))
    contentList:reload()

    return contentList,contentSize
end

function MatchGameListWidget:addMatchGameListItem()
	if self.matchGameListView then
        self.matchGameListView:removeAllItems()

        local matchTypes = ServerMatchData:GetMatchTypeItem()
        for i,v in ipairs(matchTypes) do
            local content,size = self:createListItem(v)
            while true do
                if not content then
                    break
                end

                local item = self.matchGameListView:newItem()
                item:addContent(content)
                item:setItemSize(size.width, size.height)
                self.matchGameListView:addItem(item)

                item.dwSortID = v.dwSortID
                item.matchType = v
                break
            end
        end
        
        self.matchGameListView:sortItems(handler(self,self.compItemFunc))
        self.matchGameListView:reload()
        --self.matchGameListView:setBounceable(false)
    end
end

function MatchGameListWidget:receiveMatchInfoInsertMessage(event)
    print("receiveMatchInfoInsertMessage")
    local matchInfo = event.para
    if matchInfo.MatchSerial.dwKindID ~= self.wKindID then
        return
    end
    -- 判断是否已经存在Type类型
    local matchType = ServerMatchData:SearchMatchType(matchInfo.MatchSerial.dwMatchType)
    if matchType then
        if self.matchGameListView then
            local bExsit = false
            for i,v in ipairs(self.matchGameListView.items_) do
                if matchType == v.matchType then
                    local roomContent = self:createRoomItem(matchInfo)
                    local contentList = v:getContent()
                    local item = contentList:newItem()
                    item:addContent(roomContent)
                    item:setItemSize(self.listViewSize.width, MatchGameListWidget.listItemRoomHeight)
                    contentList:addItem(item)
                    -- 重新设置高度
                    local contentSize = contentList:getContentSize()
                    contentSize.height = contentSize.height + MatchGameListWidget.listItemRoomHeight
                    contentList:setContentSize(contentSize.width,contentSize.height)
                    contentList:setViewRect(cc.rect(0, 0, contentSize.width, contentSize.height))
                    v:setItemSize(contentSize.width,contentSize.height)

                    item.dwSortID = self:getSortID(matchInfo)
                    item.matchInfo = matchInfo
                    -- 排序
                    contentList:sortItems(handler(self,self.compItemFunc))
                    contentList:reload()

                    self.bReload = true

                    bExsit = true
                    break
                end
            end
            -- 不存在，重新插入
            if not bExsit then
                local content,size = self:createListItem(matchType)
                while true do
                    if not content then
                        break
                    end

                    local item = self.matchGameListView:newItem()
                    item:addContent(content)
                    item:setItemSize(size.width, size.height)
                    self.matchGameListView:addItem(item)

                    item.dwSortID = matchType.dwSortID
                    item.matchType = matchType

                    self.matchGameListView:sortItems(handler(self,self.compItemFunc))
                    self.matchGameListView:reload()
                    self.bReload = true
                    break
                end
            end
        end
    end
end

function MatchGameListWidget:receiveMatchInfoUpdateMessage(event)
    --print("receiveMatchInfoUpdateMessage")
    local matchInfo = event.para
    if matchInfo.MatchSerial.dwKindID ~= self.wKindID then
        return
    end
    -- 判断是否已经存在Type类型
    local matchType = ServerMatchData:SearchMatchType(matchInfo.MatchSerial.dwMatchType)
    if matchType then
        if self.matchGameListView then
            for i,v in ipairs(self.matchGameListView.items_) do
                if matchType == v.matchType then
                    local contentList = v:getContent()
                    local roomItems = contentList.items_
                    for i,v in ipairs(roomItems) do
                        if v.matchInfo == matchInfo then
                            self:updateRoomItem(v, matchInfo)
                            break
                        end
                    end
                    -- 排序
                    --contentList:sortItems(handler(self,self.compItemFunc))
                    --contentList:reload()
                    break
                end
            end
        end
    end
end

function MatchGameListWidget:receiveMatchInfoDeleteMessage(event)
    print("receiveMatchInfoDeleteMessage")
    local matchInfo = event.para
    if matchInfo.MatchSerial.dwKindID ~= self.wKindID then
        return
    end
    -- 判断是否已经存在Type类型
    local matchType = ServerMatchData:SearchMatchType(matchInfo.MatchSerial.dwMatchType)
    if matchType then
        if self.matchGameListView then
            for i,v in ipairs(self.matchGameListView.items_) do
                if matchType == v.matchType then
                    local matchItem = v
                    local contentList = matchItem:getContent()
                    local roomItems = contentList.items_
                    for i,v in ipairs(roomItems) do
                        if v.matchInfo == matchInfo then
                            if #roomItems ~= 2 then -- 当只有一个数据时，rootItem会被移除，故可不改变大小
                                local contentSize = contentList:getContentSize()
                                contentSize.height = contentSize.height-MatchGameListWidget.listItemRoomHeight
                                contentList:setContentSize(contentSize.width,contentSize.height)
                                contentList:setViewRect(cc.rect(0, 0, contentSize.width, contentSize.height))
                                matchItem:setItemSize(contentSize.width,contentSize.height)
                            end                         
                            contentList:removeItem(v, false)
                            self.bReload = true
                            break
                        end
                    end
                    -- 无数据时，清空matchItem
                    if #roomItems < 2 then
                        self.matchGameListView:removeItem(matchItem,false)
                    end
                    break
                end
            end
        end
    end
end

function MatchGameListWidget:receiveMatchDataResetMessage(event)
    if self.matchGameListView then
        self.matchGameListView:removeAllItems()
        self.matchGameListView:reload()
    end
end

function MatchGameListWidget:onScrollListener(event)
    if self.bReload and event.name == "scrollEnd" then
        self.bReload = false
        self.matchGameListView:reload()
    end
end

return MatchGameListWidget