local Matcthresultlost=class("Matcthresultlost", function()
	return cc.uiloader:load("errenlandmatch/matchlose.json")end) 

function Matcthresultlost:ctor()
    self:setTouchEnabled(false)

    self.text=cc.uiloader:seekNodeByName(self,"LastText")
    self.Buttonfanhui=cc.uiloader:seekNodeByName(self,"btfanhui")
    self.Buttonjixu=cc.uiloader:seekNodeByName(self,"btjixu")

    self.Buttonfanhui:onButtonClicked(function () self:CloseGame() end)--离开按钮事件
    self.Buttonjixu:onButtonClicked(function () self:singupnextGame() end)--继续按钮事件
    
    self:buttonTouchEvent(self.Buttonfanhui)--按钮
    self:buttonTouchEvent(self.Buttonjixu)--按钮
    self.text:setString("经过激战，你遗憾的败下阵来，什么战利品都没有，此仇不报非君子，屡战屡败是好汉！赶快报名下一场复仇吧！")
    self.Event = { EXIT_MATCH_GAME = "EXIT_MATCH_GAME",SING_UP_NEXT = "SING_UP_NEXT",}--触摸牌消息
end
--离开
function Matcthresultlost:CloseGame(btn)
    --通知到场景
    AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
    name = self.Event.EXIT_MATCH_GAME,
    })
end
--继续
function Matcthresultlost:singupnextGame(btn)
    --通知到场景
    AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
    name = self.Event.SING_UP_NEXT,
    })
end
--定义按钮缩放动画函数
function Matcthresultlost:buttonTouchEvent(btn)
    if btn then
        btn:onButtonPressed(function ()
            btn:scaleTo(0.1,0.9)
        end)
        btn:onButtonRelease(function ()
            btn:scaleTo(0.1,1)
        end)
    end
end
return Matcthresultlost