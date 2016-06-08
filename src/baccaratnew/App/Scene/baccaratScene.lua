-- ninePiece 
local CURRENT_MODULE_NAME = ...

local baccaratScene  = class("baccaratScene", function()
    return display.newScene("baccaratScene")
end)

require("socket")

local ClientKernel = require("common.ClientKernel")
-- 牌
local PokerCard = require("common.Widget.PokerCard")

local CardInfoView = import("..View.baccaratCardInfoView")

local RoundOverView = import("..View.baccaratRoundOverView")

local HistoryView = import("..View.baccaratHistoryView")

local RecordView = import("..View.baccaratRecordView")

local SettingView = import("..View.SoundSettingView")

local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()

local MainUITag = 
{
    BgTag = 4,
    BetBgTag = 8,
    ItemTag1 = {tag = 10,betArea = 0},
    ItemTag2 = {tag = 11,betArea = 1},
    ItemTag3 = {tag = 12,betArea = 2},
    ItemTag4 = {tag = 13,betArea = 3},
    ItemTag5 = {tag = 14,betArea = 4},
    ItemTag6 = {tag = 15,betArea = 5},
    ItemTag7 = {tag = 16,betArea = 6},
    ItemTag8 = {tag = 17,betArea = 7}, 
    panelChipsTag =  46,

    imageXiangKuangBg = 85,
    imageXiangTag  = 86,
    imageXiangTWTag = 87,
    LabelAtlasTW1Tag = 88,
    labelAtals1Tag   = 97,
    imageXiangPointTag = 98,

    imageBankerBg = 93,
    imageBankerTag  = 94,
    imageBankerTWTag = 95,
    LabelAtlasTW2Tag = 96,
    labelAtals2Tag   = 153,
    imageBankerPointTag = 154,

    BtnTrendTag         = 240,
    BtnHistoryTag       = 256,
    BtnUpBankerTag      = 241,
    BtnExitTag          = 544,
    BtnSettingTag       = 758,
    LabelSystimeTag     = 762,

    imageAlarmBgTag     = 253,
    LabelLeftTimeTag    = 254,
    imageStatusTag      = 255,

    --个人信息
    imagePlayerInfoBg   = 206,
    imagePlayerNickBg   = 207,
    labelPlayerNickTag  = 212,
    imagePlayerIconTag  = 211,
    imagePlayerScoreBg  = 209,
    labelPlayerScoreTag = 213,


    --庄家信息
    imageBankerInfoBg   = 221,
    imageBankerNickBg   = 222,
    labelBankerNickTag  = 223,
    imageBankerIconTag  = 227,
    imageBankerScoreBg  = 224,
    labelBankerScoreTag = 226,
    imageBankerCountBg  = 230,
    labelBankerCountTag = 232,
    imageBankerWinScoreBG = 236,
    labelBankerWinScoreTag = 238,
}

local ScoreLableTag = 
{
    ItemTag1 = {tag = 47,betType = 0,score=0,isMySelf = false},
    ItemTag2 = {paraetTag = 63,tag = 65,betType = 0,score=0,isMySelf = true},
    ItemTag3 = {tag = 49,betType = 1,score=0,isMySelf = false},
    ItemTag4 = {paraetTag = 68,tag = 69,betType = 1,score=0,isMySelf = true},
    ItemTag5 = {tag = 51,betType = 2,score=0,isMySelf = false},
    ItemTag6 = {paraetTag = 72,tag = 73,betType = 2,score=0,isMySelf = true},
    ItemTag7 = {tag = 53,betType = 3,score=0,isMySelf = false},
    ItemTag8 = {paraetTag = 74,tag = 75,betType = 3,score=0,isMySelf = true},
    ItemTag9 = {tag = 55,betType = 4,score=0,isMySelf = false},
    ItemTag10 = {paraetTag = 76,tag = 77,betType = 4,score=0,isMySelf = true},
    ItemTag11 = {tag = 57,betType = 5,score=0,isMySelf = false},
    ItemTag12 = {paraetTag = 78,tag = 79,betType = 5,score=0,isMySelf = true},
    ItemTag13 = {tag = 59,betType = 6,score=0,isMySelf = false},
    ItemTag14 = {paraetTag = 80,tag = 81,betType = 6,score=0,isMySelf = true},
    ItemTag15 = {tag = 61,betType = 7,score=0,isMySelf = false},
    ItemTag16 = {paraetTag = 82,tag = 83,betType = 7,score=0,isMySelf = true},
}

--下注按钮TAG
local ImageAllChipsTag = 
{
    ItemTag1 = {tag = 19,power=1,index = 1},
    ItemTag2 = {tag = 23,power=5,index = 2},
    ItemTag3 = {tag = 27,power=10,index = 3},
    ItemTag4 = {tag = 31,power=50,index = 4},
    ItemTag5 = {tag = 35,power=500,index = 5},
}

local AllBitValue = {
    10000000,
    5000000,
    1000000,
    100000,
    10000,
    1000,
    100,
}

--所有下注区域
local allPolygon = 
{
   area1 = { betType = 0,ploygon = { 
                                        {x = display.cx + 114 ,y = display.cy + 202 },
                                        {x = display.cx + 121 ,y = display.cy +102 },
                                        {x = display.cx + 305,y = display.cy +102},
                                        {x = display.cx + 216, y =display.cy + 175},
                                   },
           },
   area2 = { betType = 1,ploygon =  {
                                        {x = display.cx + 121 ,y = display.cy - 115 },
                                        {x = display.cx + 121 ,y = display.cy - 205 },
                                        {x = display.cx + 211,y = display.cy - 183},
                                        {x = display.cx + 274, y =display.cy - 115},
                                    },
           } ,
   area3 = { betType = 2,ploygon =  {
                                        {x = display.cx - 61 ,y = display.cy - 117 },
                                        {x = display.cx + 12 ,y = display.cy - 183 },
                                        {x = display.cx + 92,y = display.cy - 205},
                                        {x = display.cx + 92, y =display.cy - 115},
                                    },
            },
   area4 = { betType = 3,ploygon = {
                                        {x = display.cx +4 ,y = display.cy + 178 },
                                        {x = display.cx - 65 ,y = display.cy+ 104 },
                                        {x = display.cx + 102,y = display.cy + 104},
                                        {x = display.cx + 102, y =display.cy + 200},
                                    },
            },
   area5 = { betType = 4,ploygon =  {
                                        {x = display.cx + 121 ,y = display.cy + 118 },
                                        {x = display.cx + 121  ,y = display.cy + 58},
                                        {x = display.cx +  175,y = display.cy - 4},
                                        {x = display.cx + 312, y =display.cy - 4},
                                        {x = display.cx + 292, y =display.cy +102},
                                    },
           },
   area6 = { betType = 5,ploygon = {
                                        {x = display.cx + 175 ,y = display.cy - 10 },
                                        {x = display.cx + 114  ,y = display.cy - 74},
                                        {x = display.cx +  121,y = display.cy - 115},
                                        {x = display.cx + 278, y =display.cy - 115},
                                        {x = display.cx + 312, y =display.cy -10 },
                                    },
            },
   area7 = { betType = 6,ploygon =  {
                                        {x = display.cx - 93 ,y = display.cy - 10 },
                                        {x = display.cx - 83  ,y = display.cy - 78},
                                        {x = display.cx - 57  ,y = display.cy - 114},
                                        {x = display.cx +  93,y = display.cy - 114},
                                        {x = display.cx + 102, y =display.cy - 74},
                                        {x = display.cx + 40, y =display.cy -10 },
                                    },
            },
   area8 =  { betType = 7,ploygon = {
                                        {x = display.cx - 69 ,y = display.cy + 114 },
                                        {x = display.cx -87  ,y = display.cy + 8},
                                        {x = display.cx +  42,y = display.cy + 8},
                                        {x = display.cx + 94, y =display.cy + 67},
                                        {x = display.cx + 94, y =display.cy + 114},
                                    },
            },
}


function baccaratScene:ctor(args)
	print("baccaratScene:ctor")
	self:setNodeEventEnabled(true)
	if args.gameClient then
		self.gameClient = args.gameClient
		self.serviceClient = ClientKernel.new(self.gameClient,AppBaseInstanse.BaccaratApp.notificationCenter)
		
		self.workflow = import("..Controller.baccaratWorkflow", CURRENT_MODULE_NAME).new(self)
		
		self.ResponseHandler = import("..Command.baccaratResponseHandler", CURRENT_MODULE_NAME).new(self.gameClient)
	end

    math.randomseed(os.time())

    self.iconW = 43
    self.iconH = 42
    self.timeLeft = 0
    self.timeInterVal = 0

    self.chipsArray = {}

	self:loadUI()
    --加载牌的资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Common/AnimationCard.ExportJson")
   
    --创建牌组区域
    self:createCardInfoView()
end

function baccaratScene:createCardInfoView()
    self.playerCardView = CardInfoView.new():addTo(self)
    self.playerCardView:setTableSide(PokerTableSide.left)
    self.playerCardView:setPosition(cc.p(display.left+50,display.cy - 80))
    self.playerCardView:resetGiveCardStartPos()

    self.bankerCardView = CardInfoView.new():addTo(self)
    self.bankerCardView:setTableSide(PokerTableSide.left)
    self.bankerCardView:setPosition(cc.p(display.right-210,display.cy - 80))
    self.bankerCardView:resetGiveCardStartPos()
end


function baccaratScene:loadUI()
	--加载JSON
    self.mainWidget = GameUtil:widgetFromCocostudioFile("baccaratnew/BaccaratGameScene"):addTo(self)
    self.mainWidget:setTouchEnabled(true)
    self.mainWidget:addTouchEventListener(handler(self,self.panelOnTouched))

    self.betBg = self.mainWidget:getChildByTag(MainUITag.BetBgTag)
    self.chipsPanel = self.mainWidget:getChildByTag(MainUITag.panelChipsTag)

    local bg = self.mainWidget:getChildByTag(MainUITag.BgTag)
    bg:scale(display.height/bg:getContentSize().height)

    self.xinagValueBg = self.mainWidget:getChildByTag(MainUITag.imageXiangKuangBg)
    self.imageXiangTw = self.xinagValueBg:getChildByTag(MainUITag.imageXiangTWTag)
    self.labelXiangTw = self.imageXiangTw:getChildByTag(MainUITag.LabelAtlasTW1Tag)
    --闲标题
    self.imageXiang   = self.xinagValueBg:getChildByTag(MainUITag.imageXiangTag)

    self.imageXiangPoint = self.xinagValueBg:getChildByTag(MainUITag.imageXiangPointTag)
    self.labelXiang = self.xinagValueBg:getChildByTag(MainUITag.labelAtals1Tag)

    self.bankerValueBg = self.mainWidget:getChildByTag(MainUITag.imageBankerBg)
    self.imageBankerTw = self.bankerValueBg:getChildByTag(MainUITag.imageBankerTWTag)
    self.labelBankerTw = self.imageBankerTw:getChildByTag(MainUITag.LabelAtlasTW2Tag)

    self.imageBankerPoint = self.bankerValueBg:getChildByTag(MainUITag.imageBankerPointTag)
    self.labelBanker = self.bankerValueBg:getChildByTag(MainUITag.labelAtals2Tag)
    --庄标题
    self.imageBanker = self.bankerValueBg:getChildByTag(MainUITag.imageBankerTag)

    for k, v in pairs(ImageAllChipsTag) do
        local btnChips = self.mainWidget:getChildByTag(v.tag)
        btnChips:addTouchEventListener(handler(self, self.onClickChips))
    end

    local btnHistory = self.mainWidget:getChildByTag(MainUITag.BtnHistoryTag)
    btnHistory:addTouchEventListener(handler(self, self.onClickHistory))

    local btnUpBanker = self.mainWidget:getChildByTag(MainUITag.BtnUpBankerTag)
    btnUpBanker:addTouchEventListener(handler(self, self.onClickUpbanker))

    local btnExit = self.mainWidget:getChildByTag(MainUITag.BtnExitTag)
    btnExit:addTouchEventListener(handler(self, self.onClickBack))

    local btnSetting = self.mainWidget:getChildByTag(MainUITag.BtnSettingTag)
    btnSetting:addTouchEventListener(handler(self, self.onClickSetting))


    local btnTrend = self.mainWidget:getChildByTag(MainUITag.BtnTrendTag)
    btnTrend:addTouchEventListener(handler(self, self.onClickTrend))

    self.lableTime = self.mainWidget:getChildByTag(MainUITag.LabelSystimeTag)

    --当前时间
    self.sTimeNow = {
            wHour = tonumber(os.date("%H")),
            wMin = tonumber(os.date("%M")),
    }
    self.lableTime:setString(string.format("%02d:%02d",self.sTimeNow.wHour,self.sTimeNow.wMin))

    --筹码ICON
    self.iconBet = ccui.ImageView:create():addTo(self)
    self.iconBet:loadTexture("image_chips1.png",1)
    self.iconBet:setScale(0.5)
    self.iconBet:setPosition(cc.p(-100,-100))

    --倒计时相关
    self.alarmBg = self.mainWidget:getChildByTag(MainUITag.imageAlarmBgTag)
    self.alarmBg:setVisible(false)

    self.labelLeftime = self.alarmBg:getChildByTag(MainUITag.LabelLeftTimeTag)
    self.imageStatus  = self.alarmBg:getChildByTag(MainUITag.imageStatusTag)
    
    --庄家信息 和个人信息相关

    local bankerInfoBg = self.mainWidget:getChildByTag(MainUITag.imageBankerInfoBg)
    local bankerNickBg =  bankerInfoBg:getChildByTag(MainUITag.imageBankerNickBg)
    self.textBankerNick = bankerNickBg:getChildByTag(MainUITag.labelBankerNickTag)
    self.textBankerNick:setString("")
    local bankerScoreBg = bankerInfoBg:getChildByTag(MainUITag.imageBankerScoreBg)
    self.textBankerScore = bankerScoreBg:getChildByTag(MainUITag.labelBankerScoreTag)
    self.textBankerScore:setString("0")
    local bankerWinScoreBg = bankerInfoBg:getChildByTag(MainUITag.imageBankerWinScoreBG)
    self.textBankerWin = bankerWinScoreBg:getChildByTag(MainUITag.labelBankerWinScoreTag)
    self.textBankerWin:setString("0")
    local bankerCountBg = bankerInfoBg:getChildByTag(MainUITag.imageBankerCountBg)
    self.textBeingBankerCount = bankerCountBg:getChildByTag(MainUITag.labelBankerCountTag)
    self.textBeingBankerCount:setString("0")

    --self.bankerIcon = self.mainWidget:getChildByTag(MainUITag.imageBankerIconTag)
    --self.bankerIcon:setScale(0.45)
    --local iconBg = self.mainWidget:getChildByTag(MainUITag.imageBankerIconTag)
    self.bankerIcon = ccui.ImageView:create():addTo(bankerInfoBg)
    self.bankerIcon:setPosition(cc.p(bankerInfoBg:getContentSize().width/2,2+bankerInfoBg:getContentSize().height/2))
    self.bankerIcon:setLocalZOrder(bankerInfoBg:getLocalZOrder()-1)
    self.bankerIcon:setScale(0.45)
    
    
    

    local playerInfoBg = self.mainWidget:getChildByTag(MainUITag.imagePlayerInfoBg)
    local nickBg = playerInfoBg:getChildByTag(MainUITag.imagePlayerNickBg)
    self.textPlayerNick = nickBg:getChildByTag(MainUITag.labelPlayerNickTag)
    self.textPlayerNick:setString("")
    local scoreBg = playerInfoBg:getChildByTag(MainUITag.imagePlayerScoreBg)
    self.textPlayerScore = scoreBg:getChildByTag(MainUITag.labelPlayerScoreTag)
    self.textPlayerScore:setString("0")
    --self.playerIcon = self.mainWidget:getChildByTag(MainUITag.imagePlayerIconTag)
    --self.playerIcon:setScale(0.45)
    self.playerIcon = ccui.ImageView:create():addTo(playerInfoBg)
    self.playerIcon:setPosition(cc.p(playerInfoBg:getContentSize().width/2,1+playerInfoBg:getContentSize().height/2))
    self.playerIcon:setLocalZOrder(playerInfoBg:getLocalZOrder()-1)
    self.playerIcon:setScale(0.45)

    self:resetUI()  
end

--刷新玩家信息
function baccaratScene:refreshPlayerInfo()
    local userInfo = self.serviceClient:SearchUserByUserID(self.workflow:getMyUserID())
    if userInfo then
        --头像可能会改变
        self.playerIcon:loadTexture(string.format("pic/face/%d.png",userInfo.wFaceID),1)
        self.textPlayerScore:setString(tostring(userInfo.lScore))
        self.textPlayerNick:setString(userInfo.szNickName)
        self.initPlayerScore = userInfo.lScore
    end
end

--刷新庄家信息
function baccaratScene:refreshBankerInfo()
    local userInfo = self.serviceClient:SearchUserByChairID(self.workflow:getCurBankerUserId())
    if userInfo then
        self.bankerIcon:loadTexture(string.format("pic/face/%d.png",userInfo.wFaceID),1)
        self.textBankerScore:setString(tostring(userInfo.lScore))
        self.initBankerScore = userInfo.lScore
        self.textBankerWin:setString("0")
        self.textBankerNick:setString(userInfo.szNickName)
        self.textBeingBankerCount:setString(tostring(self.workflow:getCurBankerTime()))
    end
end

function baccaratScene:refreshBankerItemInfo(userItem)
    if userItem.wChairID == self.workflow:getCurBankerUserId() then
        self.textBankerScore:setString(tostring(userItem.lScore))
        --[[self.textBankerWin:setString("0")
        if userItem.lScore - self.initBankScore > 0 then
            self.textBankerWin:setString(string.format(":%s",tostring(userItem.lScore - self.initBankScore)))
        elseif userItem.lScore - self.initBankScore < 0 then
            self.textBankerWin:setString(string.format(";%s",tostring(userItem.lScore - self.initBankScore)))
        end]]
        
    end
    if userItem.wChairID == self.workflow:getMyChairID() then
        self.textPlayerScore:setString(tostring(userItem.lScore))
    end
end

function baccaratScene:onClickChips(pSender,touchType)
    self.betIndex = -1
    if touchType == TOUCH_EVENT_ENDED  then
        for k ,v in pairs(ImageAllChipsTag) do
            if type(v) == "table" and v.tag == pSender:getTag() then
                self.betPower = v.power
                self.betIndex = v.index
                pSender:loadTextureNormal("btn_bet_effect.png",1)
                pSender:loadTexturePressed("btn_bet_effect.png",1)
                self:createBtnEffectNode(pSender)
            else
                --其他还原
                local otherBtn = self.mainWidget:getChildByTag(v.tag)
                otherBtn:loadTextureNormal("u_button_chip.png",1)
                otherBtn:loadTexturePressed("u_button_chip.png",1)
            end
        end
        self.iconBet:loadTexture(string.format("image_chips%d.png",self.betIndex),1)
    end
   
end

function baccaratScene:onCleanup()
    print("baccaratScene:onCleanup")
    -- 这个schedule必须释放掉
    if self.schedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
        self.schedulerId = nil
    end

    self.workflow:cleanup()
    self.workflow = nil 

    --to do 释放资源
    self.serviceClient:cleanup()
end


function baccaratScene:onClickHistory(pSender,touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end
    if touchType == TOUCH_EVENT_ENDED  then
        if not self.historyView then
            self.historyView = HistoryView.new(self.workflow)
            self.historyView:setPosition(cc.p(display.cx,display.cy))
            self:addChild(self.historyView)
        end
        if not self.historyView:isVisible() then
            self.historyView:setVisible(true)
        end
    end
end

function baccaratScene:playScaleAnimation(less, pSender)
    local  scale = less and 0.6 or 0.7
    pSender:runAction(cc.ScaleTo:create(0.2,scale))
end
--点击上庄按钮处理
function baccaratScene:onClickUpbanker(pSender,touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        self:playScaleAnimation(true, pSender)
    else
        self:playScaleAnimation(false, pSender)
    end
    if touchType == TOUCH_EVENT_ENDED  then
        local BankerListView = import("..View.baccaratBankerListView", CURRENT_MODULE_NAME).new(self.workflow)
        BankerListView:setPosition(cc.p(display.cx,display.cy))
        self:addChild(BankerListView)
    end
end

function baccaratScene:onClickSetting(pSender,touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end
    if touchType == TOUCH_EVENT_ENDED  then
        local settingView = SettingView.new()
        settingView:setPosition(cc.p(display.cx,display.cy))
        self:addChild(settingView)
    end
end

function baccaratScene:onClickBack(pSender,touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end
    if touchType == TOUCH_EVENT_ENDED  then
        if not self.workflow:isPlaying() then
            if self.serviceClient.exitGameApp then
                self.serviceClient:exitGameApp()
            else
                self.workflow:sendStandUpRequest()
                cc.Director:getInstance():popToRootScene() 
            end
        else
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OKCANCEL,
                msgInfo="游戏进行中，如您已押注，强退将被扣分，确认要强退吗？",
                callBack=function(ret)
                    if ret == MSGBOX_RETURN_OK then
                        if self.serviceClient.exitGameApp then
                            self.serviceClient:exitGameApp()
                        else
                            self.workflow:sendStandUpRequest()
                            cc.Director:getInstance():popToRootScene() 
                        end
                    end
                end
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        end
    end
end

function baccaratScene:onClickTrend(pSender,touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end
    if touchType == TOUCH_EVENT_ENDED  then
        local recordView = RecordView.new(self.workflow)
        recordView:setPosition(cc.p(display.cx,display.cy))
        self:addChild(recordView)
    end
end

function baccaratScene:createBtnEffectNode(parent)
    if not self.btnEffectNode then
        self.btnEffectNode = cc.Node:create():addTo(self.mainWidget)
        self.btnEffectNode:setLocalZOrder(parent:getLocalZOrder() - 1)
        local  bgSp  = display.newSprite("#btn_bet_effectbg.png"):addTo(self.btnEffectNode)
        
        local btnEffectSp = cc.Sprite:create():addTo(self.btnEffectNode)
        local frames = {}
        for i = 1 ,9 do 
            local  frame  = sharedSpriteFrameCache:getSpriteFrame(string.format("btn_bet_effect%d.png",i))
            if frame then
                frames[#frames + 1] = frame
            end
        end
        local anima = cc.Animation:createWithSpriteFrames(frames,0.12)
        btnEffectSp:runAction(cc.RepeatForever:create(cc.Animate:create(anima)))
    end
    --local  worldPos = self.betBg:convertToWorldSpace(cc.p(curImage:getPositionX(),curImage:getPositionY()))
    --print(string.format("x = %f,y = %f",parent:getPositionX(),parent:getPositionY()))
    self.btnEffectNode:setPosition(parent:getPosition())
    if not self.btnEffectNode:isVisible() then
        self.btnEffectNode:setVisible(true)
    end   
end

--重新初始化UI 
function baccaratScene:resetUI()
    self:resetScoreLable()
    local allArea = self.betBg:getChildren()
    for i= 1,#allArea do 
        local image = allArea[i]
        image:setVisible(false)
    end
    self.canNotAddRecord = false
    self.gameState       =-1 
    self.timeLeft        = 0
    self.bankerCardPoint = 0 --庄家牌点数
    self.playerCardPoint = 0 --闲家牌点数
    self.cardTotalCount  = 0
    self.curCardCount    = 0
    self.betPower        = 0
    self.betType         =-1
    self.isBettingFlag   = false

    self.xinagValueBg:setVisible(false)
    self.bankerValueBg:setVisible(false)

    if self.tieEffectNode then
        self.tieEffectNode:setVisible(false)
    end

    self.imageXiang:loadTexture("u_text_xian.png",1)
    self.imageBanker:loadTexture("u_text_zh.png",1)

    if self.winEffects and #self.winEffects > 0 then
        for j=1 ,#self.winEffects do
            local effectSp = self.winEffects[j]
            effectSp:stopAllActions()
            effectSp:removeFromParent()
            self.winEffects[j] = nil
        end
    end
    --重置下注按钮
    self:resetBetBtn(false)
end

function baccaratScene:resetBetBtn(isEnable)
    for k, v in pairs(ImageAllChipsTag) do
        local btnChips = self.mainWidget:getChildByTag(v.tag)
        btnChips:setTouchEnabled(isEnable)
        if not isEnable then
            btnChips:loadTextureNormal("btn_bet_an.png",1)
            btnChips:loadTexturePressed("btn_bet_an.png",1)
        else
            btnChips:loadTextureNormal("u_button_chip.png",1)
            btnChips:loadTexturePressed("u_button_chip.png",1)
        end
    end

    if self.btnEffectNode and not isEnable then
        self.btnEffectNode:setVisible(false)
    end
end

function baccaratScene:onEnter()
    --注册网络层接收接口
    self.ResponseHandler:registerPlayHandlers()
    if not self.schedulerId then
        self.schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.refreshCountDownTime), 1 , false)
    end

    SoundManager:playMusicBackground("baccaratnew/audio/bground.mp3", true)
end

function baccaratScene:refreshCountDownTime(dt)
    self.timeInterVal = self.timeInterVal + 1 
    --一分钟对时
    if self.timeInterVal == 60 then
        self.sTimeNow = {
            wHour = tonumber(os.date("%H")),
            wMin = tonumber(os.date("%M")),
        }
        self.timeInterVal = 0
    end
    if self.sTimeNow.wMin <= 0 then
        self.lableTime:setString(string.format("%02d:%02d",self.sTimeNow.wHour-1,59))
    else
        self.lableTime:setString(string.format("%02d:%02d",self.sTimeNow.wHour,self.sTimeNow.wMin))
    end

    if self.timeLeft > 0 then
        if not self.alarmBg:isVisible() then
           self.alarmBg:setVisible(true)
        end
        self.labelLeftime:setString(tostring(self.timeLeft))
        self.timeLeft = self.timeLeft  - 1
        if self.gameState == GAME_STATE_FREE then
            self.imageStatus:loadTexture("u_text_kx.png",1)
        elseif self.gameState == GAME_STATE_BET then
            self.imageStatus:loadTexture("u_text_bet.png",1)
        else
            self.imageStatus:loadTexture("u_text_kp.png",1)
        end
    else
        self.alarmBg:setVisible(false)
    end
end

function baccaratScene:onExit()
    self.ResponseHandler:unregisterPlayHandlers()
    if self.schedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
        self.schedulerId = nil
    end
    SoundManager:stopMusicBackground()

    ---释放图片
    display.removeSpriteFramesWithFile("baccaratnew/gameScene.plist","baccaratnew/gameScene.png")
end

function baccaratScene:getCurClientKernel()
    return self.serviceClient
end


function baccaratScene:panelOnTouched( sender, touchType)
    --不在下注时间内 不作处理
    if self.historyView then
        self.historyView:setVisible(false)
    end

    if not self.isBettingFlag then
        return 
    end
    if touchType == TOUCH_EVENT_BEGAN then
        self.betType = -1
        if self.betType ~= -1 then
            --[[if self.betPower <= 0 and not self.hasShowTipFlag then
                self.hasShowTipFlag = true
                local dataMsgBox = {
                    nodeParent=self,
                    msgboxType=MSGBOX_TYPE_OK,
                    msgInfo="请先选择下注金额！",
                    callBack=function(ret)
                        if ret == MSGBOX_RETURN_OK then
                            self.hasShowTipFlag = false
                        end    
                    end
                }
                require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
                return
            end ]] 
            --[[self.selectImage = self:getSelectItemByType(self.betType)
            self.selectImage:loadTexture(string.format("transferbattle/Bet_light_%d.png",self.betType),0)
            --下注的筹码
            self.iconBet:setVisible(true)
            self.iconBet:setPosition(cc.p(winPos.x,winPos.y))]]
            
        end
    elseif touchType == TOUCH_EVENT_ENDED then
        self.betType = -1
        local winPos = sender:getTouchEndPosition()
        --print(string.format("TOUCH_EVENT_MOVED  x= %f,y = %f",winPos.x,winPos.y))
        local allArea = self.betBg:getChildren()
        for i= 1,#allArea do 
            local image = allArea[i]
            if image:hitTest(winPos) and image:getTag() >=10 and image:getTag()<=17 then
                self.betType = self:getBetTypeByTag(image:getTag())
            end
            if image:getTag() >=10 and image:getTag()<=17 then
                image:setVisible(false)
            end
        end

        if self.iconBet then
            self.iconBet:setVisible(false)
        end    
        if self.betType ~=-1 then
            --print(string.format("betType = %d",self.betType))
            --发送下注消息
            if self.betPower > 0 then
                self.betMyPos = cc.p(winPos.x,winPos.y)
                self.workflow:placeBet(self.betType,self.betPower*1000) 
            else
                if not self.hasShowTipFlag then
                    self.hasShowTipFlag = true
                    local dataMsgBox = {
                        nodeParent=self,
                        msgboxType=MSGBOX_TYPE_OK,
                        msgInfo="请先选择下注金额！",
                        callBack=function(ret)
                            if ret == MSGBOX_RETURN_OK then
                                self.hasShowTipFlag = false
                            end    
                        end
                    }
                    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
                    return
                end  
            end
           
        end
    elseif TOUCH_EVENT_MOVED == touchType  then
        local winPos = sender:getTouchMovePosition()
        --print(string.format("TOUCH_EVENT_MOVED  x= %f,y = %f",winPos.x,winPos.y))
        local allArea = self.betBg:getChildren()
        for i= 1,#allArea do 
            local image = allArea[i]
            local insidePolygon = false
            if image:hitTest(winPos) then
                image:setVisible(true)
                self.betType = self:getBetTypeByTag(image:getTag())
            else
                if image:getTag() >=10 and image:getTag()<=17 then
                    image:setVisible(false)
                end
                --image:setVisible(false)
            end
        end
        if not self.iconBet:isVisible() then
            self.iconBet:setVisible(true)
        end
        self.iconBet:setPosition(cc.p(winPos.x,winPos.y))    
    end
end

function baccaratScene:receiveUserBetPro( betInfo )
    --播放下注音效
    if not self.prePlaytime or socket.gettime() - self.prePlaytime >=0.1 then
        self.prePlaytime = socket.gettime()
        if betInfo.lBetScore >=5000000 then
            SoundManager:playMusicEffect("baccaratnew/audio/addgold_ex.mp3", false)
        else
            SoundManager:playMusicEffect("baccaratnew/audio/addgold.mp3", false)
        end
    end

    local chipsPos = self:getEndposByType(betInfo.cbBetArea)
    local chipsIndex =self:getChipsIndexByScore(betInfo.lBetScore)
    local imageChips = ccui.ImageView:create():addTo(self.betBg)
    imageChips:loadTexture(string.format("image_chips%d.png",chipsIndex),1)

    --imageChips:setPosition(cc.p(-200,-80))
    imageChips.betData =  betInfo
    local startPos = cc.p(-200,-80)
    local  endPos = chipsPos
     if self.workflow:getMyChairID() == betInfo.wChairID then
        local nodePos = self.betBg:convertToNodeSpace(cc.p(self.betMyPos.x,self.betMyPos.y))
        endPos = nodePos
        startPos = cc.p(-40,-100)
    end
    imageChips:setPosition(startPos)
    local moveTime = cc.pGetDistance(endPos, startPos) / 2000
    local _mt = cc.MoveTo:create(moveTime, endPos)
    local callback  = cc.CallFunc:create(handler(self, self.displayCardMoveEnd))
    imageChips:runAction(cc.Sequence:create(_mt,callback))
    
    table.insert(self.chipsArray,imageChips)

    
    --[[for k ,v in pairs(ScoreLableTag) do
        if v.isMySelf == isMySelf and v.betType == betInfo.cbBetArea then
            local labelChips = self.chipsPanel:getChildByTag(v.tag)
            v.score = v.score + betInfo.lBetScore
            labelChips:setString(tostring(v.score))
            if not labelChips:isVisible() and v.score > 0 then
                labelChips:setVisible(true)
            end
            if v.isMySelf and v.score > 0 then
                local betBg = self.chipsPanel:getChildByTag(v.paraetTag)
                betBg:setVisible(true)
            end
        end
    end]]

end

function baccaratScene:displayCardMoveEnd(pSender)
    local betInfo = pSender.betData
    local isMySelf = false
    if self.workflow:getMyChairID() == betInfo.wChairID then
        isMySelf = true
    end
    for k ,v in pairs(ScoreLableTag) do
        if v.isMySelf == isMySelf and v.betType == betInfo.cbBetArea then
            local labelChips = self.chipsPanel:getChildByTag(v.tag)
            v.score = v.score + betInfo.lBetScore
            labelChips:setString(tostring(v.score))
            if not labelChips:isVisible() and v.score > 0 then
                labelChips:setVisible(true)
            end
            if v.isMySelf and v.score > 0 then
                local betBg = self.chipsPanel:getChildByTag(v.paraetTag)
                betBg:setVisible(true)
            end
        end
    end
end

function baccaratScene:receiveGameFreePro(freeInfo)
    --self:resetScoreLable()
    --停止恢复场景的动画
    self.imageXiang:stopAllActions()
    self.imageBanker:stopAllActions()
    if self.tieEffectNode then
        self.tieEffectNode:stopAllActions()
    end

    self:resetUI()
    self.gameState = GAME_STATE_FREE
    self.timeLeft  = freeInfo.cbTimeLeave

    self.playerCardView:clearAllCards()
    self.bankerCardView:clearAllCards()
end

function baccaratScene:receiveGameStartPro(startInfo)
    SoundManager:playMusicEffect("baccaratnew/audio/game_start.mp3", false)
    SoundManager:playMusicEffect("baccaratnew/audio/pleasebet.mp3", false)
    --开始下注
    self.isBettingFlag = true
    self.gameState = GAME_STATE_BET
    self.timeLeft = startInfo.cbTimeLeave

    --置设置按钮为可操作状态
    if self.workflow:getCurBankerUserId() == self.workflow:getMyChairID() then
        self:resetBetBtn(false)
    else
        self:resetBetBtn(true)
    end
end

--收到场景消息处理
function baccaratScene:receiveSceneMessagePro(statusInfo,isFreeStatus)
    --恢复下注区域
    self.timeLeft = statusInfo.cbTimeLeave
    self.initBankScore = statusInfo.lBankerScore
    self.initPlayerScore = statusInfo.lPlayFreeSocre
    --游戏状态下处理
    --print("baccaratScene:receiveSceneMessagePro")
    if not isFreeStatus then
        print("is playing")
        self.isBettingFlag = true
        for k ,v in pairs(ScoreLableTag) do
            for i=1,8 do
                local curBetType = i-1
                if v.betType == curBetType and v.isMySelf == false then
                    local labelChips = self.chipsPanel:getChildByTag(v.tag)
                    if statusInfo.lAllBet[i] > 0 then
                        v.score = v.score + statusInfo.lAllBet[i]
                        labelChips:setString(tostring(v.score))
                        labelChips:setVisible(true)
                        self:createRandomBetChips(curBetType,v.score)
                    end
                elseif v.betType == curBetType and v.isMySelf == true then
                    if statusInfo.lPlayBet[i] > 0 then
                        local labelChips = self.chipsPanel:getChildByTag(v.tag)
                        v.score = v.score + statusInfo.lPlayBet[i]
                        labelChips:setString(tostring(v.score))
                        labelChips:setVisible(true)
                        local betBg = self.chipsPanel:getChildByTag(v.paraetTag)
                        betBg:setVisible(true)
                        self:createRandomBetChips(curBetType,v.score)
                    end
                end
            end
        end

        if statusInfo.cbCardCount[1] == 2 then
            self.playerCardView:setPositionX(display.left+40)
        else
            self.playerCardView:setPositionX(display.left+20)
        end

        if statusInfo.cbCardCount[2] == 2 then
            self.bankerCardView:setPositionX(display.right-215)
        else
            self.bankerCardView:setPositionX(display.right-235) 
        end

        --牌已发,不能再下注
        if statusInfo.cbCardCount[1] >0 and statusInfo.cbCardCount[2] >0 then
            self.canNotAddRecord = true
            self.isBettingFlag = false
            self.cardTotalCount = statusInfo.cbCardCount[1] + statusInfo.cbCardCount[2]
            self.gameState = GAME_STATE_ROUNDOVER
            --分析数据
            self.roundInfo = statusInfo 
            self:analyzeRoundInfo(statusInfo)
            --关连牌信息
            for i=1,3 do 
                --闲家牌数
                if i <= statusInfo.cbCardCount[1] then
                    local  xinagCardIndex= statusInfo.cbTableCardArray[i]
                    local cardType, cardNumber = GameUtil:GetCardForPc(xinagCardIndex)
                    --print(string.format("闲家手牌,牌型 = %d ,牌值=%d",cardType,cardNumber))
                    -- 界面上闲家加入一张牌
                    if self.playerCardView then
                        local card = PokerCard.new{ctype = cardType, number = cardNumber }
                        card:setScale(0.9)
                        self.playerCardView:giveCard{card = card, isDeal = false}
                        self:cardMoveEnd(false,card)
                    end
                    
                end
                if i <= statusInfo.cbCardCount[2] then
                    local  bankerCardIndex= statusInfo.cbTableCardArray[3+i]
                    local cardType, cardNumber = GameUtil:GetCardForPc(bankerCardIndex)
                    --print(string.format("庄家手牌,牌型 = %d ,牌值=%d",cardType,cardNumber))
                     --界面上庄家加入一张牌
                    if self.bankerCardView then
                        local card = PokerCard.new{ctype = cardType, number = cardNumber }
                        card:setScale(0.9)
                        self.bankerCardView:giveCard{card = card, isDeal = false}
                        self:cardMoveEnd(true,card)
                    end
                    
                end
            end
        else
            self.gameState = GAME_STATE_BET
        end

    else
        self.gameState = GAME_STATE_FREE
    end

     --恢复的时候自已是庄家，都不可点击
    if self.workflow:getCurBankerUserId() == self.workflow:getMyChairID() then
        self:resetBetBtn(false)
    else
        self:resetBetBtn(self.isBettingFlag)
    end
end

--根据下注类型和下注金额在该下注类型区域内随机产生一堆筹码
function baccaratScene:createRandomBetChips(betType,betScore)
    local curLeftScore = betScore
    local chipsArrayInfo = {}
    while curLeftScore >0 do
        for k ,v in pairs(AllBitValue) do
            local bitCount  = math.floor(curLeftScore/v) 
            if bitCount > 0 then
                local chipsIndex = self:getChipsIndexByScore(v)
                table.insert(chipsArrayInfo,{count=bitCount,chipsIndex = chipsIndex })
                curLeftScore = curLeftScore - bitCount*v
            end
        end
    end
    for m,info in pairs(chipsArrayInfo) do
        if type(info) =="table" and info.count and info.chipsIndex then
            for i=1,info.count do
                local chipsPos = self:getEndposByType(betType)
                local imageChips = ccui.ImageView:create():addTo(self.betBg)
                if imageChips then
                    imageChips:setPosition(chipsPos)
                    imageChips:loadTexture(string.format("image_chips%d.png",info.chipsIndex),1)
                    table.insert(self.chipsArray,imageChips)
                end
            end
        end
    end
    --dump(chipsArrayInfo)
end

function baccaratScene:resetScoreLable()
    for k ,v in pairs(ScoreLableTag) do
        local labelChips = self.chipsPanel:getChildByTag(v.tag)
        v.score = 0
        labelChips:setString(tostring(v.score))
        labelChips:setVisible(false)
        if v.isMySelf == true  then
            local betBg = self.chipsPanel:getChildByTag(v.paraetTag)
            betBg:setVisible(false)
        end
    end
    

    for i, chips in pairs(self.chipsArray) do
            chips:removeFromParent()
            self.chipsArray[i] = nil
    end
end

function baccaratScene:receiveRoundOverMessage( roundInfo )
    print("baccaratScene:receiveRoundOverMessage")
    self.roundInfo = roundInfo
    self.gameState = GAME_STATE_ROUNDOVER 
    self.timeLeft = roundInfo.cbTimeLeave
    self.isBettingFlag = false
    self:resetBetBtn(self.isBettingFlag)
    self.textBeingBankerCount:setString(tostring(self.workflow:getCurBankerTime()))
    if roundInfo.lBankerTotallScore > 0 then
        self.textBankerWin:setString(string.format(":%s",tostring(roundInfo.lBankerTotallScore)))
    else
        self.textBankerWin:setString(string.format(";%s",tostring(roundInfo.lBankerTotallScore)))
    end
    
    local delaytime = 0
    if roundInfo.cbCardCount[1] == 2 then
        self.playerCardView:setPositionX(display.left+40)
    else
        self.playerCardView:setPositionX(display.left+20)
    end

    if roundInfo.cbCardCount[2] == 2 then
        self.bankerCardView:setPositionX(display.right-215)
    else
        self.bankerCardView:setPositionX(display.right-235) 
    end
    --分析牌型
    self:analyzeRoundInfo(roundInfo)
    
    --记录总的牌数
    self.cardTotalCount = roundInfo.cbCardCount[1] + roundInfo.cbCardCount[2]

    for i=1,3 do 
        --闲家牌数
        if i <= roundInfo.cbCardCount[1] then
            local  xinagCardIndex= roundInfo.cbTableCardArray[i]
            local cardType, cardNumber = GameUtil:GetCardForPc(xinagCardIndex)
            --print(string.format("闲家手牌,牌型 = %d ,牌值=%d",cardType,cardNumber))
            -- 界面上闲家加入一张牌
            if self.playerCardView then
                local card = PokerCard.new{ctype = cardType, number = cardNumber }
                card:setScale(0.9)
                self.playerCardView:giveCard{card = card, isDeal = true,isBanker = false, delay = delaytime,isTurnOpen = true,moveEndHandler = handler(self, self.cardMoveEnd)}
                
            end
            delaytime = delaytime + i*0.8
        end
        if i <= roundInfo.cbCardCount[2] then
            local  bankerCardIndex= roundInfo.cbTableCardArray[3+i]
            local cardType, cardNumber = GameUtil:GetCardForPc(bankerCardIndex)
            --print(string.format("庄家手牌,牌型 = %d ,牌值=%d",cardType,cardNumber))
             --界面上庄家加入一张牌
            if self.bankerCardView then
                local card = PokerCard.new{ctype = cardType, number = cardNumber }
                card:setScale(0.9)
                self.bankerCardView:giveCard{card = card, isDeal = true, isBanker = true,delay = delaytime,isTurnOpen = true,moveEndHandler = handler(self, self.cardMoveEnd)}
                --SoundManager:playMusicEffect("baccaratnew/audio/dispatchcard.mp3", false)
            end
            delaytime = delaytime + i*0.8
        end
    end
end

--分析牌数据
function baccaratScene:analyzeRoundInfo(roundInfo)
    self.winArea = {}
    for k = 1, 8 do
        self.winArea[tostring(k-1)] = 0
    end

    local playerCardPoint= 0
    local bankerCardPoint = 0
    for i = 1,3 do
        if i <= roundInfo.cbCardCount[1] then
            local  xinagCardIndex= roundInfo.cbTableCardArray[i]
            local cardType, cardNumber = GameUtil:GetCardForPc(xinagCardIndex)
            playerCardPoint = self:calRealPont(playerCardPoint,cardNumber)
        end
        if i <= roundInfo.cbCardCount[2] then
            local  bankerCardIndex= roundInfo.cbTableCardArray[3+i]
            local cardType, cardNumber = GameUtil:GetCardForPc(bankerCardIndex)
            bankerCardPoint = self:calRealPont(bankerCardPoint,cardNumber)
        end
    end
    --闲
    if playerCardPoint > bankerCardPoint then
        self.winArea[tostring(0)] = 1
        --闲天王
        if playerCardPoint >=8 then
            self.winArea[tostring(3)] = 1
        end
    --平
    elseif playerCardPoint == bankerCardPoint then
        self.winArea[tostring(1)] = 1
    --庄
    elseif playerCardPoint < bankerCardPoint then
        self.winArea[tostring(2)] = 1
        --庄天王
        if bankerCardPoint >=8  then
            self.winArea[tostring(4)] = 1
        end
    end

    --判断是否是同点平,每一张牌的点数相等
    local isTongDianPing = true
    --牌张数一样
    if roundInfo.cbCardCount[1] == roundInfo.cbCardCount[2] then
        for k =1 ,roundInfo.cbCardCount[1] do
            local cardType, cardNumber = GameUtil:GetCardForPc(roundInfo.cbTableCardArray[k])
            local cardType2, cardNumber2 = GameUtil:GetCardForPc(roundInfo.cbTableCardArray[k+3])
            if  cardNumber ~= cardNumber2 then
                isTongDianPing = false
                break
            end
        end
    else
        isTongDianPing = false
    end

    if isTongDianPing then
        self.winArea[tostring(5)] = 1
    end

    --闲对子
    local cardType, cardNumber = GameUtil:GetCardForPc(roundInfo.cbTableCardArray[1])
    local cardType2,cardNumber2 = GameUtil:GetCardForPc(roundInfo.cbTableCardArray[2])
    if cardNumber == cardNumber2 then
        self.winArea[tostring(6)] = 1
    end
    --庄对子
    cardType, cardNumber = GameUtil:GetCardForPc(roundInfo.cbTableCardArray[4])
    cardType2,cardNumber2 = GameUtil:GetCardForPc(roundInfo.cbTableCardArray[5])
    if cardNumber == cardNumber2 then
        self.winArea[tostring(7)] = 1
    end
    --print("self.winArea")
    --dump(self.winArea)
end

function baccaratScene:calRealPont(prePoint,cardNumber)
    if cardNumber >=10 then
        prePoint  = prePoint
    else
        prePoint  = prePoint + cardNumber 
    end

    if prePoint >=10 then
        prePoint = prePoint - 10 
    end
    return prePoint
end

function baccaratScene:cardMoveEnd(isbanker,card)
    --闲家牌
    local pointV = card.number
    --10 j q k 点值为0 
    if card.number >=10 then
        pointV = 0
    end

    if not isbanker then
        --第一张牌
        if self.playerCardPoint == 0 then
            self.xinagValueBg:setVisible(true)
        end
        self.playerCardPoint = self.playerCardPoint + pointV
        if self.playerCardPoint >= 10  then
            self.playerCardPoint = self.playerCardPoint - 10
        end
        --天王
        if self.playerCardPoint >=8 then
            self.imageXiangPoint:setVisible(false)
            self.labelXiang:setVisible(false)
            self.imageXiangTw:setVisible(true)
            self.labelXiangTw:setString(tostring(self.playerCardPoint))
        else
            self.imageXiangPoint:setVisible(true)
            self.labelXiang:setVisible(true)
            self.labelXiang:setString(tostring(self.playerCardPoint))
            self.imageXiangTw:setVisible(false)
        end
    else
        --第一张牌
        if self.bankerCardPoint == 0 then
            self.bankerValueBg:setVisible(true)
        end
        self.bankerCardPoint = self.bankerCardPoint + pointV

        if self.bankerCardPoint >= 10  then
            self.bankerCardPoint = self.bankerCardPoint - 10
        end
        --天王
        if self.bankerCardPoint >=8 then
            self.imageBankerPoint:setVisible(false)
            self.labelBanker:setVisible(false)
            self.imageBankerTw:setVisible(true)
            self.labelBankerTw:setString(tostring(self.bankerCardPoint))
        else
            self.imageBankerPoint:setVisible(true)
            self.labelBanker:setVisible(true)
            self.labelBanker:setString(tostring(self.bankerCardPoint))
            self.imageBankerTw:setVisible(false)
        end
    end

    self.curCardCount = self.curCardCount + 1
    if self.curCardCount == self.cardTotalCount then
        if self.bankerCardPoint == self.playerCardPoint then
            self:dealTieEffect()
        elseif self.bankerCardPoint > self.playerCardPoint then
            self:dealBankerWinEffect() 
        else
            self:dealPlayerWinEffect()   
        end

        if self.roundInfo.lPlayAllScore > 0 then
            SoundManager:playMusicEffect("baccaratnew/audio/end_win.mp3", false)
        elseif self.roundInfo.lPlayAllScore < 0 then
            SoundManager:playMusicEffect("baccaratnew/audio/end_lost.mp3", false)
        else
            SoundManager:playMusicEffect("baccaratnew/audio/end_tie.mp3", false)
        end
    end
end

--播放开口区域高亮效果
function baccaratScene:dealWinAreaEffect()
    self.winEffects = {}
    local frames = {}
    local frame = nil
    for k,v in pairs(self.winArea) do
        --压中区域
        if v == 1 then
            --有可能是同几个区域清空前一个区域的
            frames = {}
            local winAreaIndex = tonumber(k)
            for m,n in pairs(MainUITag) do
                if type(n) == "table" and n.betArea == winAreaIndex then
                    local curImage = self.betBg:getChildByTag(n.tag)
                    local worldPos = self.betBg:convertToWorldSpace(cc.p(curImage:getPositionX(),curImage:getPositionY()))
                    if winAreaIndex < 3 then
                        frame = sharedSpriteFrameCache:getSpriteFrame("image_big_1.png")
                        if frame then
                            table.insert(frames,frame)
                        end
                        frame = sharedSpriteFrameCache:getSpriteFrame("image_big_2.png")
                        if frame then
                            table.insert(frames,frame)
                        end
                    else
                        frame = sharedSpriteFrameCache:getSpriteFrame("image_small_1.png")
                        if frame then
                            table.insert(frames,frame)
                        end
                        frame = sharedSpriteFrameCache:getSpriteFrame("image_small_2.png")
                        if frame then
                            table.insert(frames,frame)
                        end
                    end
                    local winSprite = display.newSprite():addTo(self.mainWidget)
                    winSprite:setPosition(worldPos)
                    local anima = cc.Animation:createWithSpriteFrames(frames,0.2)
                    winSprite:runAction(cc.RepeatForever:create(cc.Animate:create(anima)))
                    table.insert(self.winEffects,winSprite)
                    break
                end
            end
        end
    end
end

function  baccaratScene:dealBankerWinEffect()
    local actionArray= {}
    local delay = cc.DelayTime:create(1)
    local _zoomOut = cc.OrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0)
    local _open = cc.CallFunc:create(function ()
        self.imageBanker:loadTexture("image_banker_win.png",1)
        self:dealWinAreaEffect()
        if not self.canNotAddRecord then
            local itemInfo = {}
            itemInfo.winScore = self.roundInfo.lPlayAllScore
            itemInfo.isPlayer= -1
            itemInfo.isBanker = 1
            itemInfo.isSamePoint =  -1
            itemInfo.cbPlayerCount = self.playerCardPoint
            itemInfo.cbBankerCount = self.bankerCardPoint
            self.workflow:addRecordIem(itemInfo)
        end
    end)
    local _zoomIn = cc.OrbitCamera:create(0.2, 1, 0, -90, 90, 0, 0)
    table.insert(actionArray,delay)
    table.insert(actionArray,_zoomOut)
    table.insert(actionArray,_open)
    table.insert(actionArray,_zoomIn)
    local delay2 = cc.DelayTime:create(3)
    table.insert(actionArray,delay2)
    local showEndView = cc.CallFunc:create(function ()
        if self:checkPopOverView() then
            local RoundOverView = RoundOverView.new(self.roundInfo.lPlayScore)
            self:addChild(RoundOverView)
        end
    end)
    table.insert(actionArray,showEndView)
    local _seq = cc.Sequence:create(actionArray)
    self.imageBanker:runAction(_seq)
end

--是否弹出结算框
function baccaratScene:checkPopOverView()
    for k ,v in pairs(self.roundInfo.lPlayScore) do
        if v ~=0 then
            return true
        end
    end
    return false
end

function  baccaratScene:dealPlayerWinEffect()
    local actionArray= {}
    local delay = cc.DelayTime:create(1)
    local _zoomOut = cc.OrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0)
    local _open = cc.CallFunc:create(function ()
        self.imageXiang:loadTexture("image_xiang_win.png",1)
        self:dealWinAreaEffect()
        if not self.canNotAddRecord then
            local itemInfo = {}
            itemInfo.winScore = self.roundInfo.lPlayAllScore
            itemInfo.isPlayer= 1
            itemInfo.isBanker = -1
            itemInfo.isSamePoint =  -1
            itemInfo.cbPlayerCount = self.playerCardPoint
            itemInfo.cbBankerCount = self.bankerCardPoint
            self.workflow:addRecordIem(itemInfo)
        end
    end)
    local _zoomIn = cc.OrbitCamera:create(0.2, 1, 0, -90, 90, 0, 0)
    table.insert(actionArray,delay)
    table.insert(actionArray,_zoomOut)
    table.insert(actionArray,_open)
    table.insert(actionArray,_zoomIn)
    local delay2 = cc.DelayTime:create(3)
    table.insert(actionArray,delay2)
    local showEndView = cc.CallFunc:create(function ()
        if self:checkPopOverView() then
            local RoundOverView = RoundOverView.new(self.roundInfo.lPlayScore)
            self:addChild(RoundOverView)
        end
    end)
    table.insert(actionArray,showEndView)
    local _seq = cc.Sequence:create(actionArray)
    self.imageXiang:runAction(_seq)
end

function baccaratScene:dealTieEffect()
    if not self.tieEffectNode then
        self.tieEffectNode = ccui.ImageView:create():addTo(self)
        self.tieEffectNode:setLocalZOrder(999)
        self.tieEffectNode:loadTexture("image_he.png",1)
        self.tieEffectNode:setPosition(cc.p(display.cx,display.cy))
    end
    self.tieEffectNode:setVisible(true)
    self.tieEffectNode:setOpacity(255)
    self.tieEffectNode:setScale(0.1)

    local actionArray = {}
    local scaleTo = cc.ScaleTo:create(0.5,1.2)
    table.insert(actionArray,scaleTo)
    local scaleTo2 = cc.ScaleTo:create(0.25, 0.8)
    table.insert(actionArray,scaleTo2)
    local fade     = cc.FadeOut:create(1.5)
    table.insert(actionArray,fade)
    local _callback = cc.CallFunc:create(function ()
        self:dealWinAreaEffect()
        if not self.canNotAddRecord then
            local itemInfo = {}
            itemInfo.winScore = self.roundInfo.lPlayAllScore
            itemInfo.isPlayer= -1
            itemInfo.isBanker = -1
            itemInfo.isSamePoint =  1
            itemInfo.cbPlayerCount = self.playerCardPoint
            itemInfo.cbBankerCount = self.bankerCardPoint
            self.workflow:addRecordIem(itemInfo)
        end
    end)
    table.insert(actionArray,_callback)
    local delay2 = cc.DelayTime:create(3)
    table.insert(actionArray,delay2)
    local showEndView = cc.CallFunc:create(function ()
        if self:checkPopOverView()then
            local RoundOverView = RoundOverView.new(self.roundInfo.lPlayScore)
            self:addChild(RoundOverView)
        end
    end)
    table.insert(actionArray,showEndView)
    self.tieEffectNode:runAction(cc.Sequence:create(actionArray))
end


function baccaratScene:getChipsIndexByScore(score)
    if score <=100 then
        return 1
    elseif score  > 100 and score <=1000 then
        return 2
    elseif score > 1000 and score <=5000 then
        return 3
    elseif score > 5000 and score <=10000 then
        return 4
    elseif score > 10000 and score <=100000 then
        return 5
    elseif score > 100000 and score <=500000 then
        return 6
    elseif score >500000 and score <=1000000 then
        return 7
    elseif score >1000000 and score <=5000000 then
        return 8
    elseif score >5000000 and score <=10000000 then
        return 9 
    else
        return 9
    end
end

function baccaratScene:getBetTypeByTag(tag)
    for k ,v in pairs(MainUITag) do
        if type(v) =="table" and v.tag == tag then
            return v.betArea
        end
    end
end

function baccaratScene:getBetAreaByBetType(betType)
    for k ,v in pairs(MainUITag) do
        if type(v) =="table" and v.betArea == betType then
            return v.tag
        end
    end
end

function baccaratScene:getEndposByType(betType)
    local curAreaTag = self:getBetAreaByBetType(betType)
    local imageChips = self.betBg:getChildByTag(curAreaTag)
    local imgW = imageChips:getContentSize().width
    local imgH = imageChips:getContentSize().height
    --转成世界坐标
    --local worldPos = self.betBg:convertToWorldSpace(cc.p(imageChips:getPositionX(),imageChips:getPositionY()))
    local worldPos = cc.p(imageChips:getPositionX(),imageChips:getPositionY())
    local curRect = cc.rect(worldPos.x-imgW/2,worldPos.y-imgH/2,imgW,imgH-50)
    --for test
    --[[local DiceRollRect = display.newRect(cc.rect(0,0,curRect.width, curRect.height), {fill=true, color=cc.c4f(255, 0, 0, 100)})
    DiceRollRect:setPosition(cc.p(cc.rectGetMidX(curRect),cc.rectGetMidY(curRect)))
    self:addChild(DiceRollRect)
    local DiceRollRect = display.newRect(cc.rect(0,0,imgW, imgH-60), {fill=true, color=cc.c4f(255, 255, 0, 255)})
    
    DiceRollRect:setAnchorPoint(cc.p(0.5,0.5))
    DiceRollRect:setPosition(cc.p(worldPos.x - imgW/2,worldPos.y - imgH/2 ))
    self:addChild(DiceRollRect)]]
    --chips 位置
    local  _x  = self:getRandomValue(-curRect.width/2 + self.iconW/2,curRect.width/2 - self.iconW/2)
    local  _y  = self:getRandomValue(-curRect.height/2 + self.iconH/2,curRect.height/2 - self.iconH/2)
    --return cc.p(cc.rectGetMidX(curRect) + _x, cc.rectGetMidY(curRect) + _y)
    return cc.p( worldPos.x+ _x,  worldPos.y+ _y)
end

--随机获取一定范围的值
function baccaratScene:getRandomValue(min,max)
    return math.random(min,max)
end


return baccaratScene
