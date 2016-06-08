--
-- Author: tjl
-- Date: 2016-02-27 16:37:08
--
local baccaratRoundOverView = class("baccaratRoundOverView", function( )
	return ccui.Layout:create()
end)

local UITag = 
{
	ImageBgTag  = 349,
	BtnCloseTag = 450,
	LabelWinTag  = 666,
	imageLabelScoreBg = 658,
	labelScore1 = {tag =667 ,betType = 0},
	labelScore2 = {tag =668 ,betType = 1},
	labelScore3 = {tag = 669,betType = 2},
	labelScore4 = {tag = 670,betType = 3},
	labelScore5 = {tag = 675,betType = 4},
	labelScore6 = {tag = 677,betType = 5},
	labelScore7 = {tag = 679,betType = 6},
	labelScore8 = {tag = 681,betType = 7},
}

function baccaratRoundOverView:ctor( roundInfo )
	self:setContentSize(cc.size(display.width,display.height))
	self:setTouchEnabled(true)
	self:setSwallowTouches(true)

	--加个蒙板
	local shade = cc.LayerColor:create()
	shade:setColor(display.COLOR_BLACK)
	shade:setOpacity(180)
	self:addChild(shade)

	self:loadUI(roundInfo)
end

function baccaratRoundOverView:loadUI(roundInfo)
	self.mainWidget = GameUtil:widgetFromCocostudioFile("baccaratnew/BaccaratGameEndView")
    self.mainWidget:setAnchorPoint(CCPoint(0.5, 0.5))
    self.mainWidget:setPosition(cc.p(display.cx,display.cy))
    self:addChild(self.mainWidget)

    local bg = self.mainWidget:getChildByTag(UITag.ImageBgTag)
    local imageScoreBg = bg:getChildByTag(UITag.imageLabelScoreBg)

    local totalScore = 0
    for k ,v in pairs(UITag) do
    	if type(v) =="table" and v.tag and v.betType then
    		local labelScore = imageScoreBg:getChildByTag(v.tag)
    		labelScore:setString("0")
    		if roundInfo[v.betType+1] > 0 then
    			labelScore:setString(string.format(":%s",tostring(roundInfo[v.betType+1])))
    		elseif roundInfo[v.betType+1] < 0 then
    			labelScore:setString(string.format(";%s",tostring(roundInfo[v.betType+1])))
    		end
    		totalScore = totalScore + roundInfo[v.betType+1]
    	end
    end

    local btnClose = bg:getChildByTag(UITag.BtnCloseTag)
    btnClose:addTouchEventListener(handler(self, self.onClose))

    local labelWin = bg:getChildByTag(UITag.LabelWinTag)
    if totalScore > 0 then
		labelWin:setString(string.format(":%s",tostring(totalScore)))
	else
		labelWin:setString(string.format(";%s",tostring(totalScore)))
	end
	bg:scale(0.5)
	local scale = cc.ScaleTo:create(0.5,1)
	G_ShowNodeWithBackout(bg)

	local dt = cc.DelayTime:create(7)
	local rs = cc.RemoveSelf:create()
	self:runAction(cc.Sequence:create(dt,rs))
end

function baccaratRoundOverView:onClose(pSender,touchType)
	if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        self:removeFromParent()
    end  
end

return baccaratRoundOverView