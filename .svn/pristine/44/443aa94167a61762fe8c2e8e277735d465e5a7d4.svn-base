local Matcthwaitstartfull=class("Matcthwaitstartfull", function()
	return cc.uiloader:load("errenlandmatch/waitstartFull.json")end) 

function Matcthwaitstartfull:ctor()
	--读取json 文件
    --self.jsonnode = cc.uiloader:load("errenlandmatch/waitstartFull.json")
    --self.jsonnode:addTo(self)
   -- self.jsonnode:setTouchEnabled(false)
    self:setTouchEnabled(false)


    self.matchname=cc.uiloader:seekNodeByName(self,"HeadName")
    self.jiangli=cc.uiloader:seekNodeByName(self,"jianglitext")
    self.renshu=cc.uiloader:seekNodeByName(self,"Playercount")

end
function Matcthwaitstartfull:SetInfo(enddb)
 
    if not enddb.d_MatchDesc.No1Score then
       return
    end
    self.matchname:setString(enddb.d_MatchDesc.szMatchName)
    local jianglistr=nil
    if enddb.d_MatchDesc.No1Score>0  then
    	jianglistr=enddb.d_MatchDesc.No1Score..enddb.d_MatchDesc.szAward1
    end
    if enddb.d_MatchDesc.No2Score>0 then
    	jianglistr=(jianglistr and (jianglistr.."+") or "")..enddb.d_MatchDesc.No2Score..enddb.d_MatchDesc.szAward2
    end
    if enddb.d_MatchDesc.No3Score>0 then
    	jianglistr=(jianglistr and (jianglistr.."+") or "")..enddb.d_MatchDesc.No3Score..enddb.d_MatchDesc.szAward3
    end
    --local name="buyao"..index..".mp3"
    self.jiangli:setString(jianglistr)

    local renshustr=enddb.dwWaitting..":"..enddb.dwTotal  
    self.renshu:setString(renshustr)
end

return Matcthwaitstartfull