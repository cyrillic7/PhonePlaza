SUB_GP_LOGON_SUCCESS=100


local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

MainScene.gamename = "MainSceneTest"

function MainScene:ctor()
    cc.ui.UIPushButton.new()
    	:setButtonSize(240, 60) --设置大小
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "This is a PushButton",
            size = 18
        }))-- 设置各个状态的按钮显示文字
        :setButtonLabel("pressed", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "Button Pressed",
            size = 18,
            color = cc.c3b(255, 64, 64)
        }))
        :setButtonLabel("disabled", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "Button Disabled",
            size = 18,
            color = cc.c3b(0, 0, 0)
        }))
        :onButtonClicked(function(event) -- 按钮的clicked事件处理
            GameServiceClientManager:sharedInstance():serviceClientForName(self.gamename):Connect("125.88.145.41",8100)
        end) 
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)
        :addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event,x,y)
        	if "began" == event.name then
				self.prevX_ = 0
				self.prevY_ = 0
				self.orgX_ = math.round(event.x)
				self.orgY_ = math.round(event.y)
			elseif "moved" == event.name then
				if self.prevX_ == math.round(event.x) and self.prevY_ == math.round(event.y) then
					return true
				end
				self.prevX_ = math.round(event.x)
				self.prevY_ = math.round(event.y)

				local pos = cc.size(event.x - self.orgX_,event.y - self.orgY_)
				local orgPos = cc.Director:getInstance():getGLViewPos()
				cc.Director:getInstance():setGLViewPos(orgPos.width+pos.width+0.5,orgPos.height-pos.height+0.5)
			elseif "ended" == event.name then
				
			end
			return true
        	end)

    GameServiceClientManager:sharedInstance():registerServiceClient(3, self.gamename)
    self.scriptHandler = GameServiceClientManager:sharedInstance():responseHandlerForName(self.gamename)
    self:registerPlayHandlers()
        
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

function MainScene:registerPlayHandlers()
    self.scriptHandler:registerResponseHandler(-1, 1, handler(self, self.OnEventTCPSocketLink))
    self.scriptHandler:registerResponseHandler(-1, 2, handler(self, self.OnEventTCPSocketShut))
    self.scriptHandler:registerResponseHandler(100, SUB_GP_LOGON_SUCCESS, handler(self, self.OnSocketSubLogonSuccess))
end

function MainScene:OnEventTCPSocketLink( Params )
    if Params.bConnectSucc then
        print("bConnectSucc: 连接成功！")
        -- 发送登录包
        local request = {
        wModuleID={260},
        cbDeviceType=2,
        dwPlazaVersion=17235969,
        szAccounts="bbbbbbbb@qq.com",
        szMachineID="12",
        szMobilePhone="32",
        szPassPortID="12",
        szPhoneVerifyID="1",
        szPassword=cc.Crypto:MD5("abc#1234",false)
        }
        GameServiceClientManager:sharedInstance():serviceClientForName(self.gamename):requestCommand(100,2,request)
    else            
        print("bConnectSucc: 连接失败！")
    end
end

function MainScene:OnEventTCPSocketShut( Params )
    print("OnEventTCPSocketShut: cbShutReason:"..Params.cbShutReason)
end

function MainScene:OnSocketSubLogonSuccess(Params)
    print("OnSocketSubLogonSuccess ")
    --for i,v in ipairs(Params.arytest) do
    --    print(i,v)
    --end
    for k,v in pairs(Params) do
        print(k,v)
    end

    for k,v in pairs(Params.nameInfo) do
        print("     nameInfo:",k,v)
    end

    local request = {
        wFaceID=10,
        cbGender=12,
        cbInsurePwd=1,
        dwUserID=10002,        
        dwGameID=22221,
        dwExperience=133232332,
        lLoveLiness=13333333333333333333,
        dwVipLevel=13,
        lIngot=222222222223423,
        lUserScore=3331,
        lIngotScore=4234234241,
        lUserInsure=32423421,
        nameInfo={
                    {szNickName="秦天霹雳啊",szPhone="13357999999"},
                    {szNickName="1秦天霹雳啊",szPhone="23357999992"}
                },     
        szPassPortID="13341243"
    }

    GameServiceClientManager:sharedInstance():serviceClientForName(self.gamename):requestCommand(100,100,request)
end

return MainScene
