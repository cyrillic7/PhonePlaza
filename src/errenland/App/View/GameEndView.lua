local GameEndView =class("GameEndView", function()
	return display.newLayer()end) 

--构造
function GameEndView:ctor()

	 --读取json 文件
    self.jsonnode = cc.uiloader:load("errenland/JieSuan.json")
    self.jsonnode:addTo(self)

--    self.Viewback=cc.uiloader:seekNodeByName(self.jsonnode,"Image_Back")
    self.WinHead=cc.uiloader:seekNodeByName(self.jsonnode,"Image_Win")
    self.WinHeadScore=cc.uiloader:seekNodeByName(self.jsonnode,"WinNum")
    self.LoseHead=cc.uiloader:seekNodeByName(self.jsonnode,"Image_Lose")
    self.LoseHeadScore=cc.uiloader:seekNodeByName(self.jsonnode,"LoseNum")

    --self.chuntianNum=cc.uiloader:seekNodeByName(self.jsonnode,"chuntiannum")
   -- self.huojianNum=cc.uiloader:seekNodeByName(self.jsonnode,"huojiannum")
   -- self.zhadanNum=cc.uiloader:seekNodeByName(self.jsonnode,"zhadannum")
    --self.zongbeishu=cc.uiloader:seekNodeByName(self.jsonnode,"zongbeishu")

    self.Wait=cc.uiloader:seekNodeByName(self.jsonnode,"Image_Wait")

--    self.btReturn=cc.uiloader:seekNodeByName(self.jsonnode,"Button_Return")
   -- self.btContinue=cc.uiloader:seekNodeByName(self.jsonnode,"Button_Continue")


    --self.btReturn:onButtonPressed(function ()self:playScaleAnimation(true,self.btReturn)end)
    --self.btContinue:onButtonPressed(function ()self:playScaleAnimation(true,self.btContinue)end)


    --self.btReturn:onButtonRelease(function ()self:playScaleAnimation(false,self.btReturn)end)
    --self.btContinue:onButtonRelease(function ()self:playScaleAnimation(false,self.btContinue)end)

  -- self.btReturn:onButtonClicked(function () self:BtReturn() end)
   --self.btContinue:onButtonClicked(function () self:BtContinue() end)

self:setTouchEnabled(false)
       -- 消息定义
    self.Event = 
    {
     RETURN_ROOM = "RETURN_ROOM",--
     CONTINUE_GAME = "CONTINUE_GAME",--
     END_VIEW_CLOSE = "END_VIEW_CLOSE",--
    }
   
end

function GameEndView:BtReturn()
	--通知到场景
    AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
    name = self.Event.RETURN_ROOM,
    })
end
function GameEndView:BtContinue()
	--通知到场景
    AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
    name = self.Event.CONTINUE_GAME,
    })
end

function GameEndView:FreeContol()
	self:hide()

    self.WinHeadScore:setString(tostring(0))
    self.LoseHeadScore:setString(tostring(0))
	--self.chuntianNum:setString(tostring(0))
    --self.huojianNum:setString(tostring(0))
   -- self.zhadanNum:setString(tostring(0))
   -- self.zongbeishu:setString(tostring(0))

end
--[[enddb

mescore
chuntian
huojian
zhadan
zongbeishu

servertype



endDB.


]]

function GameEndView:SetGameEndInfo(enddb)

    
	self.WinHead:hide()
	self.LoseHead:hide()
    self.WinHeadScore:hide()
    self.LoseHeadScore:hide()

    self.mewin=false
    self:show()
	if enddb.mescore>=0 then
		local score=":"..enddb.mescore
        self.WinHeadScore:setString(score)
        self.WinHeadScore:show()
        self.WinHead:show()

        self.mewin=true

        self.WinHead:setScale(0.3)
        local action={}
        local m_scale1=cc.ScaleTo:create(0.1,1.2,1.2)
        table.insert(action,m_scale1)
        local m_scale2=cc.ScaleTo:create(0.05,1,1)
        table.insert(action,m_scale2)
        local _show = cc.CallFunc:create(handler(self, self.OnClose))
        table.insert(action,_show)
        local _seq = cc.Sequence:create(action)
        self.WinHead:runAction(_seq)
        
		
	end
	if enddb.mescore<0 then
		local score=":"..-enddb.mescore
		self.LoseHeadScore:setString(score)
        self.LoseHeadScore:show()
        self.LoseHead:show() 
        self.LoseHead:setScale(0.3)
        local action={}
        local m_scale1=cc.ScaleTo:create(0.1,1.2,1.2)
        table.insert(action,m_scale1)
        local m_scale2=cc.ScaleTo:create(0.05,1,1)
        table.insert(action,m_scale2)
        local _show = cc.CallFunc:create(handler(self, self.OnClose))
        table.insert(action,_show)
        local _seq = cc.Sequence:create(action)
        self.LoseHead:runAction(_seq)
	end

	--self.chuntianNum:setString(tostring(enddb.chuntian))
   -- self.huojianNum:setString(tostring(enddb.huojian))
   -- self.zhadanNum:setString(tostring(enddb.zhadan))
    --self.zongbeishu:setString(tostring(enddb.zongbeishu))

    if enddb.servertype==ErRenLandDefine.GAME_GENRE_GOLD then
    	--self.btReturn:show()
    	--self.btContinue:show()
    	self.Wait:hide()
    end
    if enddb.servertype==ErRenLandDefine.GAME_GENRE_MATCH then
        --self.btReturn:hide()
    	--self.btContinue:hide()
    	self.Wait:show()
    end
    
    

    
end

function GameEndView:OnClose()

    self:performWithDelay(function ( )  
         self:FreeContol()
         print("显示结束--------------------")
        --通知到场景
        AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
        name = self.Event.END_VIEW_CLOSE,
        type=self.mewin
        })
    end, 2.5)
end
--定义按钮缩放动画函数
function GameEndView:playScaleAnimation(less, pSender)
    local  scale = less and 0.9 or 1
    pSender:runAction(cc.ScaleTo:create(0.2,scale))
end
return GameEndView