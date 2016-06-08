--
-- TransferBattleBankView
-- Author: tjl
-- Date: 2016-02-29 9:20:01
--
local  TransferBattleBankView = class("TransferBattleBankView",function()
	return ccui.Widget:create()
end)


local UITag = {
  	ImageBgTag =   198,
    LabeInsureTag = 345,
    LabelScoreTag = 347,
    ImageInputScoreTag = 351,
    LabelUpperScoreTag = 358,
    ImageInputPwdTag = 383,
    ImageAllTag     = 353,
    Image1bWTag     = { tag = 354,value = 1000000},
    Image5bWTag     = { tag = 362,value = 5000000},
    Image1kWTag     = { tag = 366,value = 10000000},
    Image5kWTag     = { tag = 370,value = 50000000},
    Image1yTag     = { tag = 374,value = 100000000},
    ImageSaveTag  = 376,
    ImageTakeTag  = 378,
    ImageExitTag  = 424,
}

function TransferBattleBankView:ctor(workflow)
	self:setContentSize(cc.size(display.width,display.height))
	self:setTouchEnabled(true)
	self:setSwallowTouches(true)

    self.app = AppBaseInstanse.TurntableApp
    
	self:loadUI(workflow)
    --注册消息
    self:registerEvents()
end

function TransferBattleBankView:loadUI(workflow)
	self.mainWidget = GameUtil:widgetFromCocostudioFile("transferbattle/gameBankWidget")
    self.mainWidget:setAnchorPoint(CCPoint(0.5, 0.5))
    self.mainWidget:setPosition(cc.p(display.cx,display.cy))
    self:addChild(self.mainWidget)

    local  bg  = self.mainWidget:getChildByTag(UITag.ImageBgTag)
    self.labelInsure = bg:getChildByTag(UITag.LabeInsureTag)
    self.labelInsure:setString("")
    self.labelUserScore = bg:getChildByTag(UITag.LabelScoreTag)
    self.labelUserScore:setString("")

    self.labelUpperScore = bg:getChildByTag(UITag.LabelUpperScoreTag)

    local inputScoreBg = bg:getChildByTag(UITag.ImageInputScoreTag)
    if inputScoreBg then
            self.st_GoldEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                                x=inputScoreBg:getContentSize().width/2,
                                y=inputScoreBg:getContentSize().height/2,
                                size=inputScoreBg:getContentSize(),
                                listener=handler(self, self.onEdit)})
            self.st_GoldEdit:setInputMode(3)
            self.st_GoldEdit:setFontColor(cc.c3b(83,75,68))
            self.st_GoldEdit:setFontSize(25)
            self.st_GoldEdit:setFontName("微软雅黑")
            self.st_GoldEdit:setPlaceHolder("点击输入金币")
            self.st_GoldEdit:setPlaceholderFont("微软雅黑",25)
            inputScoreBg:addChild(self.st_GoldEdit)
    end

    local inputBankPwdBg = bg:getChildByTag(UITag.ImageInputPwdTag)
    if inputBankPwdBg then
        self.PwdEditPwd = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=inputBankPwdBg:getContentSize().width/2,
                            y=inputBankPwdBg:getContentSize().height/2,
                            size=inputBankPwdBg:getContentSize() })
        self.PwdEditPwd:setInputFlag(0)
        self.PwdEditPwd:setFontColor(cc.c3b(83,75,68))
        self.PwdEditPwd:setFontSize(25)
        self.PwdEditPwd:setFontName("微软雅黑")
        self.PwdEditPwd:setPlaceHolder("点击输入保险柜密码")
        self.PwdEditPwd:setMaxLength(32)
        inputBankPwdBg:addChild(self.PwdEditPwd)
    end

    local imageAll = bg:getChildByTag(UITag.ImageAllTag)
    imageAll:addTouchEventListener(handler(self, self.onClickAll))

    for k,v in pairs(UITag) do
        if type(v) == "table" and v.tag and v.value then
            local imageChips = bg:getChildByTag(v.tag)
            imageChips:addTouchEventListener(handler(self, self.onClickChips))
        end
    end

    local imageSave = bg:getChildByTag(UITag.ImageSaveTag)
    imageSave:addTouchEventListener(handler(self, self.onClickSave))

    local imageTake = bg:getChildByTag(UITag.ImageTakeTag)
    imageTake:addTouchEventListener(handler(self, self.onClickTake))

    local imageExit = bg:getChildByTag(UITag.ImageExitTag)
    imageExit:addTouchEventListener(handler(self, self.onClickExit))

    self.workflow = workflow
    --发送查询银行信息请求
    self.workflow:sendQueryBankInfoRequest()
end

function TransferBattleBankView:onEdit(event, editbox)
    if event == "changed" then
        
    elseif event == "began" then
        if editbox.number then
            editbox:setText(tostring(editbox.number))
        end
    elseif event == "ended" then
        local gold = checknumber(editbox:getText())
        local maxScore = GlobalUserInfo.lUserInsure
        if maxScore <  GlobalUserInfo.lUserScore then
            maxScore =GlobalUserInfo.lUserScore
        end 
        -- 赠送输入金币变化 
        if gold > maxScore then
            gold = maxScore
        end
        self:updateGoldEditAndUpperCase(editbox,self.labelUpperScore,gold)
        if editbox.number then
            editbox:setText(string.formatnumberthousands(editbox.number))
        end
    end
end


function TransferBattleBankView:updateGoldEditAndUpperCase(edit,labUppser,number)
    if not edit or not labUppser then
        return
    end
    number = number or 0
    if number < 1 then
        edit:setText("")
        labUppser:setString("")
    else
        edit:setText(string.formatnumberthousands(number))
        labUppser:setString(self:SwitchScoreString(number)) 
    end
    edit.number = number > 0 and number or nil
end

function TransferBattleBankView:onClickChips(pSender,touchType)
	if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        for k ,v in pairs(UITag) do
            if type(v) == "table" and v.tag == pSender:getTag() then
                local gold = v.value

                local maxScore = GlobalUserInfo.lUserInsure
                if maxScore <  GlobalUserInfo.lUserScore then
                    maxScore =GlobalUserInfo.lUserScore
                end 
                -- 赠送输入金币变化 
                if gold > maxScore then
                    gold = maxScore
                end
                --[[if gold > GlobalUserInfo.lUserInsure then
                    gold = GlobalUserInfo.lUserInsure
                end]]
                self.st_GoldEdit:setText(string.formatnumberthousands(gold))
                self.labelUpperScore:setString(self:SwitchScoreString(gold)) 
                self.st_GoldEdit.number = gold
            end
        end
    end  
end

function TransferBattleBankView:onClickAll(pSender,touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end
    if touchType == TOUCH_EVENT_ENDED then
        local maxScore = GlobalUserInfo.lUserInsure
        if maxScore <  GlobalUserInfo.lUserScore then
            maxScore =GlobalUserInfo.lUserScore
        end          
        self.st_GoldEdit:setText(string.formatnumberthousands(maxScore))
        self.labelUpperScore:setString(self:SwitchScoreString(maxScore)) 
        self.st_GoldEdit.number = maxScore
    end  
end

function TransferBattleBankView:onClickSave(pSender,touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        local strOrgPwd = self.PwdEditPwd:getText()
        if string.len(strOrgPwd) <= 0 then
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="保险柜密码不能为空!"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
            return
        end

        local lScore = checknumber(self.st_GoldEdit.number and self.st_GoldEdit.number or self.st_GoldEdit:getText())
        if not (lScore > 0) then
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="游戏币数量不能为空，请重新输入游戏币数量！"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
            return
        end
        self.workflow:sendSaveScoreRequest(self.st_GoldEdit.number)
        self:unregisterEvents()
        self:removeFromParent()
    end  
end

function TransferBattleBankView:onClickTake(pSender,touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then local strOrgPwd = self.PwdEditPwd:getText()
        if string.len(strOrgPwd) <= 0 then
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="保险柜密码不能为空!"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
            return
        end

        local lScore =checknumber(self.st_GoldEdit.number and self.st_GoldEdit.number or self.st_GoldEdit:getText())
        if not (lScore > 0) then
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="游戏币数量不能为空，请重新输入游戏币数量！"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
            return
        end

        self.workflow:sendTakeScoreRequest(self.st_GoldEdit.number, cc.Crypto:MD5( self.PwdEditPwd:getText(),false))
        self:unregisterEvents()
        self:removeFromParent()
    end  
end

function TransferBattleBankView:onClickExit(pSender,touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        self:unregisterEvents()
        self:removeFromParent()
    end  
end

function TransferBattleBankView:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    eventListeners[self.app.Message.InsureInfo] = handler(self,self.receiveInsureInfoMessage)
    self.eventHandles = self.app.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function TransferBattleBankView:unregisterEvents( )
    -- 移除所有lua层事件
    self.app.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function TransferBattleBankView:receiveInsureInfoMessage(evt)
    print("receiveInsureInfoMessage")
    self.labelInsure:setString(string.formatnumberthousands(evt.para.lUserInsure))
    self.labelUserScore:setString(string.formatnumberthousands(evt.para.lUserScore))
end

function TransferBattleBankView:SwitchScoreString(lScore)
    local pszNumber = {"零","壹","贰","叁","肆","伍","陆","柒","捌","玖"}
    local pszWeiName = {"拾","佰","仟","万","拾","佰","仟","亿","拾","佰","仟","万"}
    local szSwitchScore = checknumber(lScore)
    local bNeedFill = false
    local bNeedZero = false
    local uSwitchLength = string.len(szSwitchScore)
    local szReturn = ""
    for i=1,uSwitchLength do
        local wNumberIndex = string.byte(szSwitchScore,i) - string.byte("0")
        -- 补零操作
        if bNeedZero and wNumberIndex ~= 0 then
            bNeedZero=false
            szReturn = szReturn..pszNumber[1]
        end
        -- 拷贝数字
        if wNumberIndex ~= 0 then
            szReturn = szReturn..pszNumber[wNumberIndex+1]
        end
        -- 拷贝位名
        if wNumberIndex ~= 0 and uSwitchLength-i > 0 then
            bNeedZero=false
            szReturn = szReturn..pszWeiName[uSwitchLength-i]
        end
        -- 补零判断
        if not bNeedZero and wNumberIndex == 0 then
            bNeedZero=true
        end

        -- 补位判断
        if not bNeedFill and wNumberIndex ~= 0 then
            bNeedFill=true
        end

        -- 填补位名
        if (uSwitchLength-i) == 4 or (uSwitchLength-i)==8 then
            -- 拷贝位名
            if bNeedFill and wNumberIndex == 0 then
                szReturn = szReturn..pszWeiName[uSwitchLength-i]
            end

            --设置变量
            bNeedZero = false
            bNeedFill = false
        end
    end

    return szReturn
end

return TransferBattleBankView

