--
-- SoundSettingView
-- Author: tjl
-- Date: 2014-09-24 9:20:01
--
--[[

]]
local  SoundSettingView = class("SoundSettingView",function()
	return ccui.Widget:create()
end)

local UISettingTag = {
    ImageBg1Tag = 81,         
    ImageBg2Tag = 84,
    SliderMusicTag  = 85,
    SliderEffectTag  =87,
    BtnOkTag =      88, 

}


function SoundSettingView:ctor()
	self:setContentSize(cc.size(display.width,display.height))
	self:setTouchEnabled(true)
	self:setSwallowTouches(true)

	--加个蒙板
	local shade = cc.LayerColor:create()
	shade:setColor(display.COLOR_BLACK)
	shade:setOpacity(180)
	--shade:setPosition(cc.p(-display.cx,-display.cy))
	self:addChild(shade)

	self:loadUI()
end

function SoundSettingView:loadUI()
	self.mainWidget = GameUtil:widgetFromCocostudioFile("baccaratnew/settingWidget")
    self.mainWidget:setAnchorPoint(CCPoint(0.5, 0.5))
    self.mainWidget:setPosition(cc.p(display.cx,display.cy))
    self:addChild(self.mainWidget)

    local bg1 = self.mainWidget:getChildByTag(UISettingTag.ImageBg1Tag)
    local bg2 = bg1:getChildByTag(UISettingTag.ImageBg2Tag)

     --声量滑动条
    local  _sliderSound = bg2:getChildByTag(UISettingTag.SliderEffectTag)
    _sliderSound:addEventListener(handler(self,self.onSoundVolumeChange))
    local percent = SessionManager:sharedManager():getEffectVolume() * 100
    _sliderSound:setPercent(percent)    
    

    --背景音乐滑动条
    local  _sliderMusic = bg2:getChildByTag(UISettingTag.SliderMusicTag)
    _sliderMusic:addEventListener(handler(self,self.onMusicVolumeChange))
    local percent = SessionManager:sharedManager():getMusicVolume() * 100
    _sliderMusic:setPercent(percent)

    local btnOk = bg2:getChildByTag(UISettingTag.BtnOkTag)
    btnOk:addTouchEventListener(handler(self, self.onClickOk))
end

function SoundSettingView:onSoundVolumeChange(pSender,eventtype)
	if eventtype == 0 then
		local  percent = pSender:getPercent()
		local   volume= percent/100.0
		audio.setSoundsVolume(volume)
		--保存音量
        SessionManager:sharedManager():setEffectVolume(volume)
	end
end

function SoundSettingView:onMusicVolumeChange(pSender,eventtype)
	if eventtype == 0 then
		local  percent = pSender:getPercent()
		local   volume= percent/100.0
		audio.setMusicVolume(volume)
		--保存音量
        SessionManager:sharedManager():setMusicVolume(volume)
        if volume > 5 and SessionManager:sharedManager():getMusicOn()  then
            --todo
            --audio.playBackgroundMusic("GameHall/Audios/background.mp3", true)
        end
	end
end

function SoundSettingView:onClickOk(pSender,touchType)
	if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
    	SessionManager:sharedManager():flush()
        self:removeFromParent()
    end  
end

return SoundSettingView

