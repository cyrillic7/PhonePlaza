
local BaseGameScene = require("common.BaseGameScene")
local FrameBaseScene = class("FrameBaseScene", BaseGameScene)

function FrameBaseScene:ctor()
    FrameBaseScene.super.ctor(self)
end

function FrameBaseScene:playLogoAnimation()
    if self.armature ~= nil then
        self.armature:getAnimation():play("AnimationLogo")
    end
end

function FrameBaseScene:initUserListController(panelListViewBg,panelChatMsgBg)
    if not panelListViewBg and not panelChatMsgBg then
        return
    end
    if self.userListView then
        return
    end
    local tableRightSize = panelListViewBg:getContentSize()
    local headHeight = 42
    local scrollListViewBg = ccui.ScrollView:create()
    scrollListViewBg:setTouchEnabled(true) 
    scrollListViewBg:setDirection(ccui.ScrollViewDir.both) 
    scrollListViewBg:setBounceEnabled(false) 
    scrollListViewBg:setContentSize(tableRightSize) 
    scrollListViewBg:setInnerContainerSize(cc.size(tableRightSize.width+110, tableRightSize.height)) 
    scrollListViewBg:setPosition(0,0)
    scrollListViewBg:addTo(panelListViewBg)
    -- 创建列名
    display.newSprite("#pic/plazacenter/Sundry/u_line2.png")
    :align(display.TOP_CENTER, 45, tableRightSize.height)
    :addTo(scrollListViewBg)
    display.newSprite("#pic/plazacenter/Sundry/u_line2.png")
    :align(display.TOP_CENTER, 175, tableRightSize.height)
    :addTo(scrollListViewBg)
    display.newSprite("#pic/plazacenter/Sundry/u_line2.png")
    :align(display.TOP_CENTER, 270, tableRightSize.height)
    :addTo(scrollListViewBg)
    cc.ui.UILabel.new(
                    {text = "昵称",
                    size = 25,
                    align = cc.ui.TEXT_ALIGN_CENTER,
                    color = display.COLOR_WRITE,
                    x = 113,
                    y = tableRightSize.height-headHeight/2})
    :align(display.CENTER, 113, tableRightSize.height-headHeight/2)
    :addTo(scrollListViewBg)
    cc.ui.UILabel.new(
                    {text = "金币",
                    size = 25,
                    align = cc.ui.TEXT_ALIGN_CENTER,
                    color = display.COLOR_WRITE,
                    x = 221,
                    y = tableRightSize.height-headHeight/2})
    :align(display.CENTER, 221, tableRightSize.height-headHeight/2)
    :addTo(scrollListViewBg)
    cc.ui.UILabel.new(
                    {text = "积分",
                    size = 25,
                    align = cc.ui.TEXT_ALIGN_CENTER,
                    color = display.COLOR_WRITE,
                    x = 321,
                    y = tableRightSize.height-headHeight/2})
    :align(display.CENTER, 321, tableRightSize.height-headHeight/2)
    :addTo(scrollListViewBg)

    -- 创建列表
    local ccuiListViewCls = ccui.ListView or cc.ListView
    self.userListView = ccuiListViewCls:create()
    self.userListView:setBounceEnabled( true )
    self.userListView:setDirection( ccui.ScrollViewDir.vertical )
    self.userListView:setContentSize(tableRightSize.width+110,tableRightSize.height-45)
    self.userListView:addTo(scrollListViewBg)
    self.userListView.parentScrollBg = scrollListViewBg
    self.userListController = require("plazacenter.controllers.UserListController").new(self.userListView)
    if self.userListController ~= nil then
        self.userListController:registerEvents()
    end
end

function FrameBaseScene:unInitUserListController()
    if self.userListController ~= nil then
        self.userListController:unregisterEvents()
    end
end
function FrameBaseScene:initChatMsgController(panelChatMsg)
    if self.chatRichText then
        return
    end
    local chatMsgSize = panelChatMsg:getContentSize()
    chatMsgSize.width = chatMsgSize.width-20
    chatMsgSize.height = chatMsgSize.height-20
    local scrollListViewBg = ccui.ScrollView:create()
    scrollListViewBg:setTouchEnabled(true) 
    scrollListViewBg:setDirection(ccui.ScrollViewDir.vertical) 
    scrollListViewBg:setBounceEnabled(true) 
    scrollListViewBg:setContentSize(chatMsgSize) 
    scrollListViewBg:setInnerContainerSize(chatMsgSize) 
    scrollListViewBg:setPosition(panelChatMsg:getContentSize().width/2, panelChatMsg:getContentSize().height/2)
    scrollListViewBg:setAnchorPoint(cc.p(0.5,0.5))
    scrollListViewBg:addTo(panelChatMsg)

    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(false)
    richText:setVerticalSpace(10)
    richText:setContentSize(chatMsgSize)
    richText:setAnchorPoint(cc.p(0,1))
    richText:setPosition(0,chatMsgSize.height)
    scrollListViewBg:addChild(richText)
    self.chatMsgController = require("plazacenter.controllers.ChatMsgController").new(richText,scrollListViewBg)
    if self.chatMsgController ~= nil then
        self.chatMsgController:registerEvents()
    end
    self.chatRichText = richText
end

function FrameBaseScene:unInitChatMsgController()
    if self.chatMsgController ~= nil then
        self.chatMsgController:unregisterEvents()
    end
end

function FrameBaseScene:initHallHornController(imgHornArea)
    if self.hallHornController or not imgHornArea then
        return
    end
    -- 审核版本，隐藏喇叭
    if GlobalPlatInfo.isInReview then
        imgHornArea:setPositionX(display.width*2)
    end
    local hornPanel = cc.uiloader:seekNodeByName(imgHornArea, "Panel_Horn")
    if hornPanel then
        local panelSize = hornPanel:getContentSize()

        local richText = ccui.RichText:create()
        --richText:ignoreContentAdaptWithSize(false)
        --richText:setVerticalSpace(10)
        richText:setContentSize(panelSize)
        richText:setAnchorPoint(cc.p(0,0.5))
        richText:setPosition(0,panelSize.height/2)
        richText.maxWidth = panelSize.width
        hornPanel:addChild(richText)
        self.hallHornController = require("plazacenter.controllers.HallHornController").new(richText,self.MissionMatch)
        if self.hallHornController ~= nil then
            self.hallHornController:registerEvents()
            -- 添加触摸事件
            if imgHornArea then
                imgHornArea:setTouchEnabled(true)
                imgHornArea:addNodeEventListener(cc.NODE_TOUCH_EVENT,
                    handler(self.hallHornController, self.hallHornController.onTouchHornAreaEvent))
            end
        end
    end
end

function FrameBaseScene:unInitHallHornController()
    if self.hallHornController ~= nil then
        self.hallHornController:unregisterEvents()
    end
end

function FrameBaseScene:onEnter()
    if not self.bFirstEnter then
        return
    end
    -- 添加图片
    display.addSpriteFrames("UIHallText.plist", "UIHallText.png")
    display.addSpriteFrames("UIHallButton.plist", "UIHallButton.png")

    self.super.onEnter(self)

    -- 创建连接大厅服务器
    if not self.MissionMatch and string.len(GlobalLobbyServerInfo.szServerIP) > 1 then
        self.MissionMatch = require("plazacenter.controllers.MissionMatch").new(self,GlobalLobbyServerInfo)
        self.MissionMatch:onInitServer()
    end

    -- add bkimg
    local bkSprite = display.newSprite("pic/plazacenter/u_bg"..SessionManager:sharedManager():getSkinID()..".png")
    bkSprite:align(display.CENTER, display.cx, display.cy)
    bkSprite:scale(display.height/bkSprite:getContentSize().height)
    bkSprite:addTo(self)
    self.bkSprite = bkSprite

    local node = nil
    if GlobalPlatInfo.isInReview then
        node = cc.uiloader:load(FRAME_BASE_SCENE_FILE_IOS)
    else
        node = cc.uiloader:load(FRAME_BASE_SCENE_FILE)
    end
    if not node then
        return
    end
    -- add logo animation
    --[[
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo(LOGO_ANIMATION_CSB_FILE)
    self.armature = ccs.Armature:create("AnimationLogo")
    self.armature:align(display.LEFT_TOP, display.left+10, display.top)
    node:addChild(self.armature)
    self.armature:getAnimation():play("AnimationLogo")

    self.scriptEntryID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.playLogoAnimation), 10, false)
    ]]
    self:addChild(node)

    -- 创建更换皮肤按钮
    --[[cc.ui.UIPushButton.new({normal="pic/plazacenter/bt_skin_n.png",pressed = "pic/plazacenter/bt_skin_p.png"},{scale9 = true})
        :setButtonSize(29, 30)
        :scale(2)
        :onButtonClicked(function(event)
            local dwCurSkinID = SessionManager:sharedManager():getSkinID()
            display.removeSpriteFrameByImageName("pic/plazacenter/u_bg"..dwCurSkinID..".png")
            dwCurSkinID = dwCurSkinID + 1
            dwCurSkinID = math.mod(dwCurSkinID,3)
            SessionManager:sharedManager():setSkinID(dwCurSkinID)
            bkSprite:setTexture("pic/plazacenter/u_bg"..dwCurSkinID..".png")
        end)
        :align(display.RIGHT_TOP, display.right - 40, display.top)
        :addTo(self)]]
    
    self.imgUserFace = cc.uiloader:seekNodeByName(node, "Image_Face")
    self.labelNickName = cc.uiloader:seekNodeByName(node, "Label_NickName")
    self.labelIngot = cc.uiloader:seekNodeByName(node, "Label_IngotText")
    self.labelCoin = cc.uiloader:seekNodeByName(node, "Label_CoinText")
    self.labelBank = cc.uiloader:seekNodeByName(node, "Label_BankText")
    self.imgVipLevel = cc.uiloader:seekNodeByName(node, "Image_VipLevel")
    self.labelExpLevel = cc.uiloader:seekNodeByName(node, "Label_Level")
    local imgLvBg = cc.uiloader:seekNodeByName(node, "Image_LvBg")
    if imgLvBg then -- 创建等级进度条
        self.imgLvProgress = display.newScale9Sprite("#pic/plazacenter/Sundry/u_lv_bar.png", 0, 0, imgLvBg:getContentSize())
        self.imgLvProgress.maxWidth = imgLvBg:getContentSize().width
        self.imgLvProgress.height = imgLvBg:getContentSize().height
        self.imgLvProgress:align(display.LEFT_BOTTOM, 0, 0)
        self.imgLvProgress:addTo(imgLvBg)
    end

    local btnAddGold = cc.uiloader:seekNodeByName(node, "Button_AddGold")
    local btnAddWing = cc.uiloader:seekNodeByName(node, "Button_AddWing")
    local btnTask = cc.uiloader:seekNodeByName(node, "Button_Task")
    self.imgTaskTip = cc.uiloader:seekNodeByName(node, "Image_TaskTip")
    local btnMsg = cc.uiloader:seekNodeByName(node, "Button_Msg")
    self.imgMsgTip = cc.uiloader:seekNodeByName(node, "Image_MsgTip")
    local btnSetting = cc.uiloader:seekNodeByName(node, "Button_Setting")
    local btnNotice = cc.uiloader:seekNodeByName(node, "Button_Notice")

    local btnBank = cc.uiloader:seekNodeByName(node, "Button_Bank")
    local btnActivety = cc.uiloader:seekNodeByName(node, "Button_Activety")
    local btnBag = cc.uiloader:seekNodeByName(node, "Button_Bag")
    local btnAuction = cc.uiloader:seekNodeByName(node, "Button_Auction")
    local btnMall = cc.uiloader:seekNodeByName(node, "Button_Mall")
    local btnExchange = cc.uiloader:seekNodeByName(node, "Button_Exchange")

    self.imgGameTypeOptionList = cc.uiloader:seekNodeByName(node, "Image_GameTypeOptionList")
    self.imgGameItemList = cc.uiloader:seekNodeByName(node, "Image_GameItemList")

    self.mainPanelBg = cc.uiloader:seekNodeByName(node, "Panel_MainBg")
    self.mainPanel = cc.uiloader:seekNodeByName(node, "Panel_Main")
    self.imgGameArea = cc.uiloader:seekNodeByName(node, "Image_GameArea")

    self.tableFramePanel = cc.uiloader:seekNodeByName(node, "Panel_TableFrame")
    self.tableViewPanel = cc.uiloader:seekNodeByName(node, "Panel_TableView")
    self.listViewTable = cc.uiloader:seekNodeByName(node, "ListView_TableFrame")
    self.imgTableTopBg = cc.uiloader:seekNodeByName(node, "Image_TableTopBg")
    self.labelRoomName = cc.uiloader:seekNodeByName(node, "Label_RoomName")
    self.btnQuickJoin = cc.uiloader:seekNodeByName(node, "Button_QuickJoin")
    self.btnGoBack = cc.uiloader:seekNodeByName(node, "Button_GoBack")
    self.btnLockDesk = cc.uiloader:seekNodeByName(node, "Button_LockDesk")
    self.btnRule = cc.uiloader:seekNodeByName(node, "Button_Rule")
    self.panelRule = cc.uiloader:seekNodeByName(node, "Panel_Rule")
    self.imgRule = cc.uiloader:seekNodeByName(node, "Image_Rule")
    self.imgTableRight = cc.uiloader:seekNodeByName(self.tableFramePanel, "Image_TableRight")
    self.btnShowRight = cc.uiloader:seekNodeByName(self.tableFramePanel, "Button_ShowRight")
    self.btnHideRight = cc.uiloader:seekNodeByName(self.tableFramePanel, "Button_HideRight")
    self.panelListViewBg = cc.uiloader:seekNodeByName(self.tableFramePanel, "Panel_ListViewBg")
    self.imgSplitLine = cc.uiloader:seekNodeByName(self.tableFramePanel, "Image_SplitLine")
    self.panelChatMsg = cc.uiloader:seekNodeByName(self.tableFramePanel, "Panel_ChatMsg")
    self.panelAvertMode = cc.uiloader:seekNodeByName(self.tableFramePanel, "Panel_AvertCheat")
    self.imgAvertModeBg = cc.uiloader:seekNodeByName(self.tableFramePanel, "Image_AvertCheatBg")
    self.btnAvertStart = cc.uiloader:seekNodeByName(self.tableFramePanel, "Button_AvertCheatStart")
    -- 喇叭
    self.imgHornArea = cc.uiloader:seekNodeByName(node, "Image_HornArea")

    if btnBank then
        self:buttonTouchEvent(btnBank)
        btnBank:onButtonClicked(handler(self, self.onBankButtonClicked))
    end
    if btnActivety then
        self:buttonTouchEvent(btnActivety)
        btnActivety:onButtonClicked(handler(self, self.onActivetyButtonClicked))
        -- 审核版本，隐藏按钮
        if GlobalPlatInfo.isInReview then
            btnActivety:hide()
        end
    end
    if btnBag then
        self:buttonTouchEvent(btnBag)
        btnBag:onButtonClicked(handler(self, self.onBagButtonClicked))
    end
    if btnAuction then
        self:buttonTouchEvent(btnAuction)
        btnAuction:onButtonClicked(handler(self, self.onAuctionButtonClicked))
    end
    if btnMall then
        self:buttonTouchEvent(btnMall)
        btnMall:onButtonClicked(handler(self, self.onMallButtonClicked))
    end
    if btnExchange then
        self:buttonTouchEvent(btnExchange)
        btnExchange:onButtonClicked(handler(self, self.onExchangeButtonClicked))
    end

    self:initUserListController(self.panelListViewBg,self.panelChatMsg)
    self:initChatMsgController(self.panelChatMsg)
    self:initHallHornController(self.imgHornArea)

    self.topController = require("plazacenter.controllers.GameFrameTopController").new(self)
    if self.topController ~= nil then
        self.topController:updateUserInfo()
        self.topController:registerEvents()
    end

    if self.imgUserFace then
        self.topController:onTouchImgUserFace(self.imgUserFace)
    end
    if self.imgVipLevel then
        self.topController:onTouchImgVipLevel(self.imgVipLevel)
    end
    if btnAddGold then
        self:buttonTouchEvent(btnAddGold)
        btnAddGold:onButtonClicked(handler(self.topController, self.topController.onAddGoldButtonClicked))
    end
    if btnAddWing then
        self:buttonTouchEvent(btnAddWing)
        btnAddWing:onButtonClicked(handler(self.topController, self.topController.onAddWingButtonClicked))
    end
    if btnTask then
        self:buttonTouchEvent(btnTask)
        btnTask:onButtonClicked(handler(self.topController, self.topController.onTaskButtonClicked))
    end
    if btnMsg then
        self:buttonTouchEvent(btnMsg)
        btnMsg:onButtonClicked(handler(self.topController, self.topController.onMsgButtonClicked))
    end
    if btnSetting then
        self:buttonTouchEvent(btnSetting)
        btnSetting:onButtonClicked(handler(self.topController, self.topController.onSettingButtonClicked))
    end
    if btnNotice then
        self:buttonTouchEvent(btnNotice)
        btnNotice:onButtonClicked(handler(self.topController, self.topController.onNoticeButtonClicked))
        -- 审核版本，隐藏按钮
        if GlobalPlatInfo.isInReview then
            btnNotice:hide()
        end
    end        

    self.gameTypeController = require("plazacenter.controllers.GameTypeController").new(self)
    if self.gameTypeController ~= nil then
        self.gameTypeController:updateGameTypeList()
        self.gameTypeController:registerEvents()
    end

    self.gameItemListController = require("plazacenter.controllers.GameItemListController").new(self)
    if self.gameItemListController ~= nil then
        self.gameItemListController:updateGameItemList()
        self.gameItemListController:registerEvents()
    end

    self.TableFrameController = require("plazacenter.controllers.TableFrameController").new(self)
    if self.TableFrameController ~= nil then
        self.TableFrameController:registerEvents()
    end

    if self.btnQuickJoin then
        self:buttonTouchEvent(self.btnQuickJoin)
        self.btnQuickJoin:onButtonClicked(handler(self.TableFrameController, self.TableFrameController.onQuickJoinBtnClicked))
    end
    if self.btnAvertStart then
        self:buttonTouchEvent(self.btnAvertStart)
        self.btnAvertStart:onButtonClicked(handler(self.TableFrameController, self.TableFrameController.onQuickJoinBtnClicked))
    end
    if self.btnGoBack then
        self:buttonTouchEvent(self.btnGoBack)
        self.btnGoBack:onButtonClicked(handler(self.TableFrameController, self.TableFrameController.onGoBackBtnClicked))
    end

    if self.btnLockDesk then
        self:buttonTouchEvent(self.btnLockDesk)
        self.btnLockDesk:onButtonClicked(handler(self.TableFrameController, self.TableFrameController.onLockRoomBtnClicked))
    end

    if self.btnRule then
        self:buttonTouchEvent(self.btnRule)
        self.btnRule:onButtonClicked(handler(self.TableFrameController, self.TableFrameController.onRuleBtnClicked))
    end

    if self.panelRule then
        self.TableFrameController:onTouchPanelRule(self.panelRule)
    end

    if self.btnShowRight then
        self:buttonTouchEvent(self.btnShowRight)
        self.btnShowRight:onButtonClicked(handler(self.TableFrameController, self.TableFrameController.onShowRightBtnClicked))
    end

    if self.btnHideRight then
        self.TableFrameController:onHideRightPanelTouch(self.btnHideRight)
    end

    self:registerEvents()
end

function FrameBaseScene:onCleanup()
    self.super.onCleanup(self)

    if self.MissionMatch then
        self.MissionMatch:onCleanServer()
        self.MissionMatch = nil
    end
    
    if self.scriptEntryID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scriptEntryID)
        self.scriptEntryID = nil
    end

    if self.gameTypeController ~= nil then
        self.gameTypeController:unregisterEvents()
        self.gameTypeController = nil
    end

    if self.topController ~= nil then
        self.topController:unregisterEvents()
        self.topController = nil
    end

    if self.gameItemListController ~= nil then
        self.gameItemListController:unregisterEvents()
        self.gameItemListController = nil
    end

    if self.TableFrameController ~= nil then
        self.TableFrameController:unregisterEvents()
        self.TableFrameController = nil
    end

    if self.ServerMatchItemController then
        self.ServerMatchItemController:onCleanServerMatch()
        self.ServerMatchItemController = nil
    end

    if self.ServerViewItemController then
        self.ServerViewItemController:onCleanServerView()
        self.ServerViewItemController = nil
    end

    self:unInitUserListController()
    self:unInitChatMsgController()
    self:unInitHallHornController()

    self:unregisterEvents()
end

function FrameBaseScene:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.Ctrl_GameItemClicked] = handler(self, self.receiveGameItemClickedMessage)
    eventListeners[appBase.Message.Ctrl_GameServerItemClicked] = handler(self, self.receiveGameServerItemClickedMessage)
    eventListeners[ServerMatchData.Message.MS_EntranceMatchItem] = handler(self, self.receiveEntranceMatchMessage)
    eventListeners[appBase.Message.Ctrl_ChangeSkinBg] = handler(self, self.receiveChangeSkinBgMessage)
    eventListeners[appBase.Message.Ctrl_ShowBankWidget] = handler(self, self.receiveShowBankWidgetMessage)
    eventListeners[appBase.Message.Ctrl_OpenTopupWidget] = handler(self, self.receiveOpenTopupWidgetMessage)
    eventListeners[appBase.Message.LS_SystemMessage] = handler(self, self.receiveSocketSubSystemMessage)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function FrameBaseScene:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function FrameBaseScene:buttonTouchEvent(btn)
    if btn then
        btn:onButtonPressed(function ()
            btn:scaleTo(0.1,0.9)
        end)
        btn:onButtonRelease(function ()
            btn:scaleTo(0.1,1)
        end)
    end
end

function FrameBaseScene:setMainFrameVisible(bVisible)
    if self.mainPanelBg then
        self.mainPanelBg:setVisible(bVisible)
        --[[if bVisible then
            self.mainPanelBg:setScale(0.5)
            transition.execute(self.mainPanelBg,cc.ScaleTo:create(0.2, 1),{easing="backout",time="0.2"})
        end]]
    end
end

function FrameBaseScene:onBankButtonClicked()
    if  AppBaseInstanse.PLAZACENTER_APP:getLastPopWidgetType() == "HallBankWidget" then
        return
    end
    if GlobalUserInfo.cbInsurePwd == 0 then
        require("plazacenter.widgets.SetBankPwdWidget").new(self)
    else
        require("plazacenter.widgets.BankLoginWidget").new(self)
    end
end

function FrameBaseScene:onActivetyButtonClicked()
    if device.platform == "android" then
        local params = {"http://hdapp.719you.com/?Name="..GlobalUserInfo.dwUserID.."&Pwd="..GlobalUserInfo.szPassword.."&channelid="..GlobalPlatInfo.dwTerminal.."&skinid="..SessionManager:sharedManager():getSkinID(),
            function (...)
                dump(...)
            end}
        local succ = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "openWebview", params, "(Ljava/lang/String;I)V")
        if not succ then
            local dataMsgBox = {
                nodeParent=self.frameScene,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="打开活动页面失败，请稍后再试。给您带来不便，请谅解！"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        end
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("LuaCallObjcFuncs", "openWebview", 
            {url="http://hdapp.719you.com/?Name="..GlobalUserInfo.dwUserID.."&Pwd="..GlobalUserInfo.szPassword.."&channelid="..GlobalPlatInfo.dwTerminal.."&skinid="..SessionManager:sharedManager():getSkinID()})

    end
end

function FrameBaseScene:onBagButtonClicked()
    self:setMainFrameVisible(false) 
    AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(
        require("plazacenter.widgets.HallBagWidget").new(self,function ()
        self:setMainFrameVisible(true)
        AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(nil)
    end) )
end

function FrameBaseScene:onAuctionButtonClicked()
    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo="该功能暂未实现，敬请期待！"
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function FrameBaseScene:onMallButtonClicked()
    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo="该功能暂未实现，敬请期待！"
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function FrameBaseScene:onExchangeButtonClicked()
    require("plazacenter.widgets.CDKExchangeWidget").new(self)
end

function FrameBaseScene:entranceServerItem(gameServer)
    if self.ServerViewItemController then
        self.ServerViewItemController:onCleanServerView()
        self.ServerViewItemController = nil
    end
    self.ServerViewItemController = require("plazacenter.controllers.ServerViewItemController").new(self,gameServer)
    self.ServerViewItemController:onInitServerView()
end

function FrameBaseScene:entranceMatchItem(matchServer)
    if self.ServerMatchItemController then
        return
    end
    if self.ServerViewItemController then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OKCANCEL,
            msgInfo="你已在游戏房间，是否退出游戏进入比赛？",
            callBack=function(ret)
                    if ret == MSGBOX_RETURN_OK then
                        self:switchToTableFrame(false)
                        -- 进入比赛
                        self.ServerMatchItemController = require("plazacenter.controllers.ServerMatchItemController").new(self,matchServer)
                        self.ServerMatchItemController:onInitServerMatch()
                    end
                end
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    self.ServerMatchItemController = require("plazacenter.controllers.ServerMatchItemController").new(self,matchServer)
    self.ServerMatchItemController:onInitServerMatch()
end

function FrameBaseScene:switchToTableFrame(bToTableFrame)
    if self.mainPanel then
        self.mainPanel:setVisible(not bToTableFrame)
    end
    if self.tableFramePanel then
        self.tableFramePanel:setVisible(bToTableFrame)
    end
    if not bToTableFrame then
        if self.ServerViewItemController then
            self.ServerViewItemController:onCleanServerView()
            self.ServerViewItemController = nil
        end
    end
end

function FrameBaseScene:exitMatchAndToPlaza()
    if self.ServerMatchItemController then
        self.ServerMatchItemController:onCleanServerMatch()
        self.ServerMatchItemController = nil
    end
end

function FrameBaseScene:showImgGameArea(bVisible,bNotEffect)
    if self.imgGameArea then
        self.imgGameArea:setVisible(bVisible)
        if bVisible and not bNotEffect then
            self.imgGameArea:moveBy(0, -900, 0)
            transition.execute(self.imgGameArea,cc.MoveBy:create(0.6, cc.p(900, 0)),{easing="backInOut",time="0.6"})
        end
    end
end

function FrameBaseScene:receiveGameItemClickedMessage(event)
    print("receiveGameItemClickedMessage")
    if not self.imgGameArea:isVisible() then
        print("not in game area")
        return
    end
    if self.ServerViewItemController or self.ServerMatchItemController then
        print("in tableFramePanel")
        return
    end
    -- hide game item list
    self:showImgGameArea(false)
    local Params = event.para
    --  Normal Game
    if Params.nItemType == eGameItemType.eItemTypeNormalGame then
        require("plazacenter.widgets.NormalGameServerListWidget").new(self,Params.wKindID)
    else -- Match Game
        require("plazacenter.widgets.MatchGameListWidget").new(self,Params.wKindID)
    end 
end

function FrameBaseScene:receiveGameServerItemClickedMessage(event)
    print("receiveGameServerItemClickedMessage")
    local gameServer = event.para
    self:entranceServerItem(gameServer)
    self:showImgGameArea(true,true)
end

function FrameBaseScene:receiveEntranceMatchMessage(event)
    print("receiveEntranceMatchMessage")
    local matchServer = event.para.matchServer
    self:entranceMatchItem(matchServer)
end

function FrameBaseScene:receiveChangeSkinBgMessage(event)
    print("receiveChangeSkinBgMessage")
    local skinImgPath = event.para
    if self.bkSprite then
        self.bkSprite:setTexture(skinImgPath)

        self.bkSprite:scale(display.height/self.bkSprite:getContentSize().height)
    end
end

function FrameBaseScene:receiveShowBankWidgetMessage(event)
    print("receiveShowBankWidgetMessage")
    if  AppBaseInstanse.PLAZACENTER_APP:getLastPopWidgetType() == "HallBankWidget" then
        return
    end
    --判断是否在房间中
    local bankWidgetPath = "plazacenter.widgets.HallBankWidget"
    if self.ServerViewItemController and 
        self.ServerViewItemController.serviceClient:IsConnectedServer() then
        bankWidgetPath = "plazacenter.widgets.ServerBankWidget"
    end
    local szInsurePass = event.para
    self:setMainFrameVisible(false) 
    AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(
        require(bankWidgetPath).new(self,szInsurePass,function ()
        self:setMainFrameVisible(true)
        AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(nil)
    end,self.ServerViewItemController) )
end

function FrameBaseScene:receiveOpenTopupWidgetMessage(event)
    print("receiveOpenTopupWidgetMessage")
    if  AppBaseInstanse.PLAZACENTER_APP:getLastPopWidgetType() == "HallTopupWidget" then
        local lastWidget = AppBaseInstanse.PLAZACENTER_APP:getLastPopWidget()
        if lastWidget and lastWidget.setSelectedID then
            lastWidget:setSelectedID(event.para)
        end
        return
    end
    self:setMainFrameVisible(false) 
    AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(
        require("plazacenter.widgets.HallTopupWidget").new(self,function ()
        self:setMainFrameVisible(true)
        AppBaseInstanse.PLAZACENTER_APP:setLastPopWidget(nil)
    end, event.para) )
end

function FrameBaseScene:receiveSocketSubSystemMessage(event)
    local systemMessage = event.para
    if 0 ~= bit._and(systemMessage.wType, SMT_CLOSE_HALL) then
        local dataMsgBox = {
            nodeParent=display.getRunningScene(),
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo=systemMessage.szString,
            callBack=function()
                -- 清空资源
                local sharedTextureCache     = cc.Director:getInstance():getTextureCache()
                local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
                sharedSpriteFrameCache:removeSpriteFrames()
                sharedTextureCache:removeAllTextures()

                -- 进入登录界面
                require("plazacenter.MyApp").new("plazacenter","plazacenter"):run()
            end
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    end
end
return FrameBaseScene