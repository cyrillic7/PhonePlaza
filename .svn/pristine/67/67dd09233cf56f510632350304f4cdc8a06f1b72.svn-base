local Matcthresultwin=class("Matcthresultwin", function()
	return cc.uiloader:load("errenlandmatch/matchwin.json")end) 

function Matcthresultwin:ctor()
    self:setTouchEnabled(true)
    self.Buttonfanhui=cc.uiloader:seekNodeByName(self,"btfanhui")
    self.rank=cc.uiloader:seekNodeByName(self,"ranknum")
    self.Buttonjixu=cc.uiloader:seekNodeByName(self,"btjixu")
    self:buttonTouchEvent(self.Buttonfanhui)--按钮
    self:buttonTouchEvent(self.Buttonjixu)--按钮

    self.give1=cc.uiloader:seekNodeByName(self,"give1")
    self.give2=cc.uiloader:seekNodeByName(self,"give2")
    self.give3=cc.uiloader:seekNodeByName(self,"give3")
    self.give4=cc.uiloader:seekNodeByName(self,"give4")

    self.Buttonfanhui:onButtonClicked(function () self:CloseGame() end)--离开按钮事件
    self.Buttonjixu:onButtonClicked(function () self:singupnextGame() end)--继续按钮事件

    self.Event = { EXIT_MATCH_GAME = "EXIT_MATCH_GAME",SING_UP_NEXT = "SING_UP_NEXT",}--触摸牌消息
end
--离开
function Matcthresultwin:CloseGame(btn)
    --通知到场景
    AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
    name = self.Event.EXIT_MATCH_GAME,
    })
end
--继续
function Matcthresultwin:singupnextGame(btn)
    --通知到场景
    AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
    name = self.Event.SING_UP_NEXT,
    })
end
function Matcthresultwin:SetInfo(enddb)
 
    self.rank:setString(enddb.wRankLast)

    --local name="buyao"..index..".mp3"
    --self.matchcurname:setString(enddb.szMatchRoundName)
    local index=0
    local scorestr
    if enddb.dwGold>0 then
        
        scorestr=enddb.dwGold..enddb.szAward1
        self.give1:setString(scorestr)
        self.give1:show()
        index=index+1
    end
    if enddb.dwMedal>0 then

        scorestr=enddb.dwMedal..enddb.szAward2
        if index==0 then
           self.give1:setString(scorestr)
           self.give1:show()
        end
        if index==1 then
           self.give2:setString(scorestr)
           self.give2:show()
        end
        index=index+1
        
    end
    if enddb.dwCansaijuan>0 then
        scorestr=enddb.dwCansaijuan..enddb.szAward3
        if index==0 then
           self.give1:setString(scorestr)
           self.give1:show()
        end
        if index==1 then
           self.give2:setString(scorestr)
           self.give2:show()
        end
        if index==2 then
           self.give3:setString(scorestr)
           self.give3:show()
        end
        index=index+1
    end


    
    ---self.renshu:setString(renshustr)
end
function Matcthresultwin:buttonTouchEvent(btn)
    if btn then
        btn:onButtonPressed(function ()
            btn:scaleTo(0.1,0.9)
        end)
        btn:onButtonRelease(function ()
            btn:scaleTo(0.1,1)
        end)
    end
end

return Matcthresultwin