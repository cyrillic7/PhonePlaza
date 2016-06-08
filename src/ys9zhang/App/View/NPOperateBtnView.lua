--
-- NPOperateBtnView
-- Author: tjl
-- Date: 2015-11-17 14:48:01
--
--[[
NPOperateBtnView
]]

--界面右下操作菜单
local  UIOperateMenuTag = {
    panelOperateTag = 6,      
    BtnPassTag = 7,           --不出
    BtnPromptTag = 11,         --提示
    BtnPlayCardTag = 15,       --出牌

    TextPassTag = 8,
    TextPlayCardTag = 16,
}


NPOperateBtnView = class("NPOperateBtnView")

NPOperateBtnView.tagToCommand ={
	{tag = 7 , command ="pass" } ,
	{tag = 11 , command ="prompt" },
	{tag = 15 , command ="outCard" },
}



-- args {
--    parent : 父控件(mainWidget)
--	  operateBtnHandler : 当前操作处理句柄
--    preOperateBtnHandler : 预操作处理句柄
-- }

function NPOperateBtnView:ctor(args)
	self.parent = args.parent 
	self.operateBtnHandler = args.operateBtnHandler

    local panelOperate = self.parent:getChildByTag(UIOperateMenuTag.panelOperateTag)
	
    self.btnPass = panelOperate:getChildByTag(UIOperateMenuTag.BtnPassTag)
    self.btnPass:addTouchEventListener(handler(self, self.onBtnPressed))

    self.btnPrompt = panelOperate:getChildByTag(UIOperateMenuTag.BtnPromptTag)
    self.btnPrompt:addTouchEventListener(handler(self, self.onBtnPressed))

    self.btnOutCard = panelOperate:getChildByTag(UIOperateMenuTag.BtnPlayCardTag)
    self.btnOutCard:addTouchEventListener(handler(self, self.onBtnPressed))
    self.btnOutCard:setEnabled(false)

    self.textPass = self.btnPass:getChildByTag(UIOperateMenuTag.TextPassTag)
    self.textOutCard = self.btnOutCard:getChildByTag(UIOperateMenuTag.TextPlayCardTag)
end

--黄色按扭点击事件处理
function NPOperateBtnView:onBtnPressed(sender ,touchType )
    
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, sender)
    else
        GameUtil:playScaleAnimation(false, sender)
    end

	if TOUCH_EVENT_ENDED == touchType then
		for k,v in pairs(NPOperateBtnView.tagToCommand) do 
			if type(v) == "table" and v.tag == sender:getTag() then 
				self.operateBtnHandler(v.command)
				break
			end
		end
	end
end


function NPOperateBtnView:setShowBlueBarFalg( flag )
   self.isShowBlueBar = flag
end

--重置已选项
function NPOperateBtnView:reSet()
    print("NPOperateBtnView:reSet()")
    if not self.btnPass:isEnabled() then
        self.btnPass:setEnabled(true)
        self.btnPass:loadTextureNormal("ys9zhang/u_game_btn_yellow.png",0)

        self.textPass:loadTexture("ys9zhang/u_game_text_nomal.png",0)
    end

    if self.btnOutCard:isEnabled() then
        self.btnOutCard:setEnabled(false)
        self.btnOutCard:loadTextureNormal("ys9zhang/u_game_btn_gray.png",0)
        self.textOutCard:loadTexture("ys9zhang/u_game_text_playno.png",0)
    end
end

-- arg :
-- {
--  isShow :        操作栏是否显示
--  isCanPass :     是否能过牌
--  isCanPlay :     是否能出牌
--  isCanPrompt  :  是否能提示
-- }
function NPOperateBtnView:setBottomBtnBarShow(args)

    local panel = self.parent:getChildByTag(UIOperateMenuTag.panelOperateTag)
    panel:setVisible(args.isShow)
    if args.isShow then
        --轮到自已出牌，不能不出 置灰不出按扭
        if not args.isCanPass then
            self.btnPass:setEnabled(false)
            self.btnPass:loadTextureNormal("ys9zhang/u_game_btn_gray.png",0)
            self.textPass:loadTexture("ys9zhang/u_game_text_passgray.png",0)
        end

        if args.isCanPlay then
            self.btnOutCard:setEnabled(true)
            self.btnOutCard:loadTextureNormal("ys9zhang/u_game_btn_outCard.png",0)
            self.textOutCard:loadTexture("ys9zhang/u_game_text_play.png",0)
        else
            self.btnOutCard:setEnabled(false)
            self.btnOutCard:loadTextureNormal("ys9zhang/u_game_btn_gray.png",0)
            self.textOutCard:loadTexture("ys9zhang/u_game_text_playno.png",0)
        end
    end
end

function NPOperateBtnView:modifyOprateStatus(args)
    if args.isCanPlay then
        self.btnOutCard:setEnabled(true)
        self.btnOutCard:loadTextureNormal("ys9zhang/u_game_btn_outCard.png",0)
        self.textOutCard:loadTexture("ys9zhang/u_game_text_play.png",0)
    else
        self.btnOutCard:setEnabled(false)
        self.btnOutCard:loadTextureNormal("ys9zhang/u_game_btn_gray.png",0)
        self.textOutCard:loadTexture("ys9zhang/u_game_text_playno.png",0)
    end
end

return NPOperateBtnView

