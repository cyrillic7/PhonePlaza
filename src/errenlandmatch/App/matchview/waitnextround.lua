local Matcthwaitnextround=class("Matcthwaitnextround", function()
	return cc.uiloader:load("errenlandmatch/waitnextround.json")end) 

function Matcthwaitnextround:ctor()
	--读取json 文件
    --self.jsonnode = cc.uiloader:load("errenlandmatch/waitstartFull.json")
    --self.jsonnode:addTo(self)
   -- self.jsonnode:setTouchEnabled(false)
    self:setTouchEnabled(false)


    self.matchname=cc.uiloader:seekNodeByName(self,"HeadName")
    self.matchcurname=cc.uiloader:seekNodeByName(self,"curname")
    self.scorenum=cc.uiloader:seekNodeByName(self,"scorenum")
    self.playernum=cc.uiloader:seekNodeByName(self,"playernum")
    self.curplayernum=cc.uiloader:seekNodeByName(self,"curplayernum")

    self.time=cc.uiloader:seekNodeByName(self,"time")
    self.Label_33=cc.uiloader:seekNodeByName(self,"Label_33")


    self.hour=0
    self.min=0
    self.sec=0
end

function Matcthwaitnextround:settime()
    self.sec=self.sec+1
    if self.sec==60 then
        self.sec=0
        self.min=self.min+1
        if self.min==60 then
            self.min=0
            self.hour=self.hour+1
        end
    end

    local timestrsec=""
    local timestrmin=""
    local timestrhour=""

    if self.sec<10 then
        timestrsec="0"..self.sec
    else
        timestrsec=self.sec
    end

    if self.min<10 then
        timestrmin="0"..self.min
    else
        timestrmin=self.min
    end

    if self.hour<10 then
        timestrhour="0"..self.hour
    else
        timestrhour=self.hour
    end

    local time
    time=timestrhour..":"..timestrmin..":"..timestrsec

    self.time:setString(time)
end
function Matcthwaitnextround:SetInfo(enddb)
 
    self.matchname:setString(enddb.szMatchName)

    --local name="buyao"..index..".mp3"
    self.matchcurname:setString(enddb.szMatchRoundName)
    local scorestr
    if enddb.lScore<0 then
        scorestr=":"..tostring(-enddb.lScore)
    end
    if enddb.lScore>=0 then
        scorestr=tostring(enddb.lScore)
    end

    self.scorenum:setString(scorestr)

    self.playernum:setString(enddb.jinjirenshu)

    self.curplayernum:setString(enddb.Bisairenshu)

    local renshustr="还有"..enddb.wPlayingTable.."桌未完成比赛"  
    self.Label_33:setString(renshustr)

    
    ---self.renshu:setString(renshustr)
end

return Matcthwaitnextround