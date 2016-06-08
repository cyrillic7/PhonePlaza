local BaseGameScene = require("common.BaseGameScene")
local LoginScene = class("LoginScene", BaseGameScene)

cc.Device:setKeepScreenOn(true)

require "cocos.ui.DeprecatedUIEnum"
require "common.GlobleFunc"
require "plazacenter.controllers.StatisticsController"

function LoginScene:ctor()
    -- 判断是否发送安装统计
    if SessionManager:sharedManager():getIsFirstRun() then
        dump("第一次运行，发送安装统计数据")
        StatisticsController:sendStatisticsData(0)
    end
    LoginScene.super.ctor(self,CLIENT_TYPE_LOGIN_POINT)

    self.LoginNetWork = require("plazacenter.controllers.LoginNetWork").new(self.scriptHandler,self.serviceClient)

    display.addSpriteFrames("UIHallSundry.plist", "UIHallSundry.png")

    -- add bkimg
    local bkSprite = display.newSprite("pic/plazacenter/u_login_bg.jpg")
    bkSprite:align(display.CENTER, display.cx, display.cy)
    bkSprite:scale(display.height/bkSprite:getContentSize().height)
    bkSprite:addTo(self)
    -- add animation
    --[[local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo(ANIMATION_LOGIN_CSB_FILE)
    self.armature = ccs.Armature:create("AnimationLogin")
    self.armature:align(display.CENTER, display.left+330, display.cy+10)
    self:addChild(self.armature)
    self.armature:getAnimation():play("Animation1")]]
end

function LoginScene:initAccountPwdEdits(parentNode)
    local imgAccountBg =cc.uiloader:seekNodeByName(parentNode, "Image_Account")
    local imgPasswordBg =cc.uiloader:seekNodeByName(parentNode, "Image_Password")
    local lastAcount = SessionManager:sharedManager():getLastAcount()
    if imgAccountBg then
        local bgSize = imgAccountBg:getContentSize()
        self.EditAcount = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_null.png",
                        x=bgSize.width/2,y=bgSize.height/2,
                        size=cc.size(bgSize.width*0.74,bgSize.height)
                        ,listener=handler(self, self.onEdit)})
        self.EditAcount:setFontColor(cc.c3b(112,55,10))
        self.EditAcount:setFontSize(28)
        self.EditAcount:setFontName("微软雅黑")
        self.EditAcount:setPlaceHolder("点击输入帐号")  
        self.EditAcount:setPlaceholderFont("微软雅黑",28)
        self.EditAcount:setMaxLength(32)
        if lastAcount then
            self.EditAcount:setText(lastAcount.acount)
        end        
        imgAccountBg:addChild(self.EditAcount)
    end
    if imgPasswordBg then
        local bgSize = imgPasswordBg:getContentSize()
        self.EditPwd = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_null.png",
                        x=bgSize.width/2,y=bgSize.height/2,
                        size=cc.size(bgSize.width*0.74,bgSize.height)
                        ,listener=handler(self, self.onEdit)})
        self.EditPwd:setInputFlag(0)
        self.EditPwd:setFontColor(cc.c3b(112,55,10))
        self.EditPwd:setFontSize(28)
        self.EditPwd:setFontName("微软雅黑")
        self.EditPwd:setPlaceHolder("点击输入密码")
        self.EditPwd:setPlaceholderFont("微软雅黑",28)
        self.EditPwd:setMaxLength(32)
        if lastAcount then
            self.EditPwd:setText(lastAcount.password)
            self.EditPwd.orgPassword = lastAcount.password
        end   
        imgPasswordBg:addChild(self.EditPwd)
    end
end

function LoginScene:onEdit(event, editbox)
    if event == "began" then
        -- 输入开始
        editbox.preText=editbox:getText()
        if editbox == self.EditPwd then
            editbox:setText("")
        end
    elseif event == "changed" then
        -- 输入框内容发生变化
        if editbox == self.EditAcount then
            if editbox.preText ~= editbox:getText() then
                self.EditPwd:setText("")
            end
        end
    elseif event == "ended" then
        -- 输入结束
        if editbox == self.EditPwd then
            if string.len(editbox:getText())<1 then
                editbox:setText(editbox.preText)
            end            
        end
    elseif event == "return" then
        -- 从输入框返回
    end
end

function LoginScene:gameName()
    return LOGIN_SERVER_CLIENT_NAME
end

function LoginScene:hideAcountsListView()
    if self.acountsListView then
        --self.acountsListView:removeSelf()
        --self.acountsListView = nil
        self.acountsListView:hide()
        self:updateAcountDlgCtrlStatus(true)
    end
end

function LoginScene:updateAcountDlgCtrlStatus(bEnabled)
    if self.acountLoginNode then
        local node = self.acountLoginNode
        if bEnabled then
            node:setTouchEnabled(false)
            node:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)

            self.EditAcount:setEnabled(true)
            self.EditPwd:setEnabled(true)
        else
            node:setTouchEnabled(true)
            node:addNodeEventListener(cc.NODE_TOUCH_EVENT,function (event)
                self:hideAcountsListView()
            end)

            self.EditAcount:setEnabled(false)
            self.EditPwd:setEnabled(false)
        end
        -- 按钮屏蔽
        local moreAccountsBtn = cc.uiloader:seekNodeByName(node, "ButtonMoreAccount")
        local forgetPwdBtn = cc.uiloader:seekNodeByName(node, "ButtonForgetPwd")
        local accountLoginBtn = cc.uiloader:seekNodeByName(node, "Button_LoginAccount")
        local qqLoginBtn = cc.uiloader:seekNodeByName(node, "Button_LoginQQ")
        local registerBtn = cc.uiloader:seekNodeByName(node, "Button_Register")
        if moreAccountsBtn then
            moreAccountsBtn:setTouchEnabled(bEnabled)
        end
        if forgetPwdBtn then
            forgetPwdBtn:setTouchEnabled(bEnabled)
        end
        if accountLoginBtn then
            accountLoginBtn:setTouchEnabled(bEnabled)
        end
        if qqLoginBtn then
            qqLoginBtn:setTouchEnabled(bEnabled)
        end
        if registerBtn then
            registerBtn:setTouchEnabled(bEnabled)
        end
    end
    
end

function LoginScene:showAllAcountsListView(bgnode)
    self.acountLoginNode = bgnode
    local allAcounts,count = SessionManager:sharedManager():getAllAcounts()
    if count < 1 then
        allAcounts = {}
        count = 1
    else if count > 4 then
        count = 4
    end
        
    end
    local acountPosCtrl = cc.uiloader:seekNodeByName(bgnode,"Image_Account")
    local itemSize = acountPosCtrl:getContentSize()
    itemSize.height = 40
    self.acountsListView = self.acountsListView or cc.ui.UIListView.new {
        bg = "#pic/plazacenter/Login/u_login_bg_xl2.png",
        bgScale9 = true,
        viewRect = cc.rect(acountPosCtrl:getPositionX()-(itemSize.width/2),acountPosCtrl:getPositionY()-21-count*40, itemSize.width, count*40),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :onTouch(function (event)
            if event.name == "clicked" and event.item then
                self.EditAcount:setText(event.item.acount)
                self.EditPwd:setText(event.item.password)
                self.EditPwd.orgPassword = event.item.password
                self:hideAcountsListView()
            end
        end)
        :addTo(acountPosCtrl:getParent())
    self.acountsListView:removeAllItems()
    for k,v in pairs(allAcounts) do
        local item = self.acountsListView:newItem()
        item.acount = k
        item.password = v
        local content = display.newNode()
        -- 创建Item
        content:setContentSize(itemSize)
        content.labAcount = cc.ui.UILabel.new(
                        {text = k,
                        font = "微软雅黑",
                        size = 28,
                        align = cc.ui.TEXT_ALIGNMENT_LEFT,
                        valign = cc.ui.VERTICAL_TEXT_ALIGNMENT_CENTER,
                        color = cc.c3b(255, 255, 255),
                        dimensions = cc.size(340, 40),
                        x = 55,
                        y = 20 })
                        :addTo(content)
        content.btnDelAcount = cc.ui.UIPushButton.new({normal="#pic/plazacenter/Login/u_login_text_x.png"})
                :setButtonSize(21, 21)
                :onButtonPressed(function ()
                    content.btnDelAcount:scale(0.9)
                end)
                :onButtonRelease(function ()
                    content.btnDelAcount:scale(1)
                end)
                :onButtonClicked(function()
                    SessionManager:sharedManager():deleteAcount({acount=k,password=v})
                    self:hideAcountsListView()
                end)
                :align(display.CENTER, itemSize.width-40, 20)
                :addTo(content)
        item:addContent(content)
        item:setItemSize(itemSize.width,itemSize.height)
        self.acountsListView:addItem(item)
    end
    self.acountsListView:reload()
    self.acountsListView:show()
    
    self:updateAcountDlgCtrlStatus(false)
end

function LoginScene:isCheckService()
    if self.checkBoxService and self.checkBoxService:isButtonSelected() then
        return true
    end
    local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="您未勾选用户服务条款，无法进行此操作！"
        }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function LoginScene:onAcountLoginBtnClicked()
    if not self:isCheckService() then
        return
    end
    if string.len(self.EditAcount:getText())<1 or string.len(self.EditPwd:getText())<1 then
        print("帐号或密码不能为空！")
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="帐号或密码不能为空！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end
    if self.serviceClient then
        self:showLoadingWidget()
        self.LoginNetWork:setLoginType(self.LoginNetWork.ACCOUNT_LOGIN)
        self.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
    end
end

function LoginScene:onQQLoginBtnClicked()
    if not self:isCheckService() then
        return
    end
    require("plazacenter.widgets.QQLoginWidget").new(self,function (id,pwd)
        if id then
            self.qqAccount = id
            self.qqPwd = pwd
            if self.serviceClient then
                self:showLoadingWidget()
                self.LoginNetWork:setLoginType(self.LoginNetWork.QQ_LOGIN)
                self.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
                self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
            end
        end
    end)
end

function LoginScene:onRegisterBtnClicked()
    if not self:isCheckService() then
        return
    end
    if self.EditAcount then
        self.EditAcount:setEnabled(false)
        self.EditPwd:setEnabled(false)
    end
    require("plazacenter.widgets.RegisterWidget").new(self,function (CMD_GP_RegisterAccounts)
        if CMD_GP_RegisterAccounts then
            self.RegisterAccounts = CMD_GP_RegisterAccounts
            if self.serviceClient then
                self:showLoadingWidget()
                self.LoginNetWork:setLoginType(self.LoginNetWork.ACCOUNT_REGISTER)
                self.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
                self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
            end
        end

        if self.EditAcount then
            self.EditAcount:setEnabled(true)
            self.EditPwd:setEnabled(true)
        end
    end)
end

function LoginScene:onWeixinLoginBtnClicked()
    if not self:isCheckService() then
        return
    end
    local wxLoginCallBack = function (token)
        self:performWithDelay(function ()
            local CMD_MB_AccessToken = {
                dwSessionID=111113,
                szUMId=GlobalChannelDef.k_session_id,
                dwSex=0,
                szNickName="",
                szMachineID=GlobalPlatInfo.szMachineID,
                szAccessToken=token,
            }

            self:sendQuickLoginMsg(SUB_MB_ACCESSTOKEN,CMD_MB_AccessToken,"CMD_MB_AccessToken")
        end, 1)
    end
    if device.platform == "android" then
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "WXLogin", {wxLoginCallBack}, "(I)V")
    elseif device.platform == "ios" then
        local ok,ret = luaoc.callStaticMethod("LuaCallObjcFuncs", "isWXAppSupported",{})
        if ok and ret == 1 then
            luaoc.callStaticMethod("LuaCallObjcFuncs", "WXLogin", 
                {listener=wxLoginCallBack})
        else
            local dataMsgBox = {
                    nodeParent=self,
                    msgboxType=MSGBOX_TYPE_OK,
                    msgInfo="当前设备未安装微信或不支持微信登录，无法使用微信进行登录！"
                }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        end
    end
end

function LoginScene:sendQuickLoginMsg(subCmdID,request,structName)
    self.subCmdID = subCmdID
    self.loginRequest = request
    self.structName = structName

    self:showLoadingWidget()
    self.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
    self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
end

function LoginScene:onQuickLoginBtnClicked()
    if not self:isCheckService() then
        return
    end
    local CMD_MB_Quick_Logon = {
        dwOpTerminal=GlobalPlatInfo.dwTerminal,
        dwSessionID=tonumber(GlobalChannelDef.k_session_id),
        szStatisCode=cc.Crypto:MD5("server"..GlobalChannelDef.k_session_id..GlobalChannelDef.k_session_verion.."lmyspread", false),
        szMachineID=GlobalPlatInfo.szMachineID,
    }

    self:sendQuickLoginMsg(SUB_MB_QUICK_LOGIN,CMD_MB_Quick_Logon,"CMD_MB_Quick_Logon")
end

function LoginScene:onServiceBtnClicked()
    if device.platform == "android" then
        local params = {"http://www.719you.com/service-terms-app.html",
            function (...)
                dump(...)
            end}
        luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "openWebview", params, "(Ljava/lang/String;I)V")
    elseif device.platform == "ios" then
        luaoc.callStaticMethod("LuaCallObjcFuncs", "openWebview", 
            {url="http://www.719you.com/service-terms-app.html"})
    end
end

function LoginScene:onForgetPwdBtnClicked()
    if self.EditAcount then
        self.EditAcount:setEnabled(false)
        self.EditPwd:setEnabled(false)
    end
    require("plazacenter.widgets.ForgetAccountPwdWidget").new(self,function (CMD_GP_RegisterAccounts)
        --[[if CMD_GP_RegisterAccounts then
            self.RegisterAccounts = CMD_GP_RegisterAccounts
            if self.serviceClient then
                self:showLoadingWidget()
                self.LoginNetWork:setLoginType(self.LoginNetWork.ACCOUNT_REGISTER)
                self.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
                self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
            end
        end]]

        if self.EditAcount then
            self.EditAcount:setEnabled(true)
            self.EditPwd:setEnabled(true)
        end
    end)
end

function LoginScene:getNextLoginPointIP()
    if not self.loginList then
        local resinfo = G_RequireFile("resinfo.txt")
        if resinfo and resinfo.url_logon_list then
            self.loginList = resinfo.url_logon_list
        else
            dump("getNextLoginPointIP resinfo nil")
            return nil
        end
    end
    if self.loginList then
        self.curIPIndex = self.curIPIndex and (self.curIPIndex+1) or 1
        if self.curIPIndex > #self.loginList then
            self.curIPIndex = nil
            return nil
        end
        -- 判断是否为IP
        local ipSubs = string.split(self.loginList[self.curIPIndex],".")
        if #ipSubs == 4 and tonumber(ipSubs[1]) and tonumber(ipSubs[2])
         and tonumber(ipSubs[3]) and tonumber(ipSubs[4]) then
            return self.loginList[self.curIPIndex]
        end
        local ip = require("socket").dns.toip(self.loginList[self.curIPIndex])
        if not ip then
            print("loginPoint failed:",self.loginList[self.curIPIndex])
            return self:getNextLoginPointIP()
        end
        print("loginPoint succ:",self.loginList[self.curIPIndex],ip)
        return ip
    end
end

function LoginScene:onEnter()
    self.super.onEnter(self)
    print("LoginScene:onEnter")

    self:registerHandlers()
    -- 初始化登陆点
    local ip = SessionManager:sharedManager():getLastServerIP()
    if not ip then
        ip = self:getNextLoginPointIP()
    end
    if ip then
        GlobalLogonServerInfo.szServerIP = ip
    end
    -- 初始化渠道ID
    local resinfo = G_RequireFile("resinfo.txt")
    if resinfo and resinfo.dwTerminal then
        GlobalPlatInfo.dwTerminal = tonumber(resinfo.dwTerminal)
    end
    -- 初始化显示游戏种类
    if resinfo and resinfo.game_list then
        GlobalKindGroups = clone(resinfo.game_list)
    end
    -- 初始化是否处于IOS审核
    if device.platform == "ios" then
        if resinfo and resinfo.isInReview then
            GlobalPlatInfo.isInReview = (resinfo.isInReview == 1)
        end
    end
    -- 清空保存的银行密码
    GlobalUserInfo.szBankPassword = ""
    GlobalUserInfo.lPreBankTimeTick = 0

    -- add prelayout
    local node = cc.uiloader:load(LOGIN_SCENE_CSB_FILE)
    if not node then
        return
    end
    if node then
        self:addChild(node)
        
        local moreAccountsBtn = cc.uiloader:seekNodeByName(node, "ButtonMoreAccount")
        local forgetPwdBtn = cc.uiloader:seekNodeByName(node, "ButtonForgetPwd")
        local accountLoginBtn = cc.uiloader:seekNodeByName(node, "Button_LoginAccount")
        local qqLoginBtn = cc.uiloader:seekNodeByName(node, "Button_LoginQQ")
        local registerBtn = cc.uiloader:seekNodeByName(node, "Button_Register")
        local weixinLoginBtn = cc.uiloader:seekNodeByName(node, "Button_LoginWeixin")
        local quickLoginBtn = cc.uiloader:seekNodeByName(node, "Button_LoginQuick")
        self.checkBoxService = cc.uiloader:seekNodeByName(node, "CheckBox_Service")
        local serviceBtn = cc.uiloader:seekNodeByName(node, "Button_Service")
        if moreAccountsBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(moreAccountsBtn)
            moreAccountsBtn:onButtonClicked(function ()
                self:showAllAcountsListView(node)
            end)
        end
        if forgetPwdBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(forgetPwdBtn)
            forgetPwdBtn:onButtonClicked(handler(self,self.onForgetPwdBtnClicked))
        end
        if accountLoginBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(accountLoginBtn)
            accountLoginBtn:onButtonClicked(handler(self,self.onAcountLoginBtnClicked))
        end
        if qqLoginBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(qqLoginBtn)
            qqLoginBtn:onButtonClicked(handler(self,self.onQQLoginBtnClicked))
        end
        if registerBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(registerBtn)
            registerBtn:onButtonClicked(handler(self,self.onRegisterBtnClicked))
        end
        if weixinLoginBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(weixinLoginBtn)
            weixinLoginBtn:onButtonClicked(handler(self,self.onWeixinLoginBtnClicked))
            if GlobalPlatInfo.isInReview and device.platform == "ios" then
                -- 判断是否安装微信
                local ok,ret = luaoc.callStaticMethod("LuaCallObjcFuncs", "isWXAppSupported",{})
                if not (ok and ret == 1) then
                    weixinLoginBtn:hide()
                end
            end
        end
        if GlobalPlatInfo.isInReview then
            if weixinLoginBtn then
                weixinLoginBtn:hide()
            end
            if qqLoginBtn then
                qqLoginBtn:hide()
            end
        end
        if quickLoginBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(quickLoginBtn)
            quickLoginBtn:onButtonClicked(handler(self,self.onQuickLoginBtnClicked))
        end
        if serviceBtn then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(serviceBtn)
            serviceBtn:onButtonClicked(handler(self,self.onServiceBtnClicked))
        end
        if self.checkBoxService then
            self.checkBoxService:setButtonSelected(true)
            if GlobalPlatInfo.isInReview then
                self.checkBoxService:setButtonSelected(false)
            end
        end
        self:initAccountPwdEdits(node)
    end
end

function LoginScene:onExit( )
    self.super.onExit(self)
    
    print("LoginScene:onExit")
    self:unRegisterHandlers()
    self:removeServiceClient()

    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo(ANIMATION_LOGIN_CSB_FILE)
    display.removeSpriteFrameByImageName("pic/plazacenter/u_login_bg.jpg")
    display.removeSpriteFramesWithFile("UILogin.plist", "UILogin.png")
end

function LoginScene:showLoadingWidget()
    if self.EditAcount then
        self.EditAcount:setEnabled(false)
        self.EditPwd:setEnabled(false)
    end
    if not self.loadingWidget then
        self.loadingWidget = require("plazacenter.widgets.CommonLoadingWidget").new(self)
    end
end

function LoginScene:hideLoadingWidget()
    if self.EditAcount then
        self.EditAcount:setEnabled(true)
        self.EditPwd:setEnabled(true)
    end
    if self.loadingWidget ~= nil then
        self.loadingWidget:hideLoadingWidget()
        self.loadingWidget = nil
    end
end

function LoginScene:updateStatusLabel(statusText)
    if self.loadingWidget ~= nil then
        self.loadingWidget:updateStatusLabel(statusText)
    end
end

function LoginScene:registerHandlers()
   self.LoginNetWork:registerDataHandlers()
   self:registerEvents()
end

function LoginScene:unRegisterHandlers()
   self.LoginNetWork:unRegisterDataHandlers()
   self:unregisterEvents()
end

function LoginScene:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.LP_LinkConnect] = handler(self, self.receiveConnectMessage)
    eventListeners[appBase.Message.LP_LinkShutDown] = handler(self, self.receiveGameShutDownMessage)
    eventListeners[appBase.Message.LP_LoginSuccess] = handler(self, self.receiveGameLoginSuccessMessage)
    eventListeners[appBase.Message.LP_LoginFailure] = handler(self, self.receiveGameLoginFailedMessage)
    eventListeners[appBase.Message.LP_LoginFinish] = handler(self, self.receiveGameLoginFinishMessage)
    eventListeners[appBase.Message.LP_QuickLoginSuccess] = handler(self, self.receiveQuickLoginSuccessMessage)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function LoginScene:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function LoginScene:receiveConnectMessage(event)
   if event.para.bConnectSucc then
        print("bConnectSucc: 连接成功！")
        -- 判断快速登录
        if self.subCmdID ~= nil then
            self.serviceClient:requestCommand(MDM_MB_LOGON, self.subCmdID, self.loginRequest, self.structName)
            self.subCmdID = nil
            self.loginRequest = nil
            self.structName = nil
            return
        end
        if self.LoginNetWork.loginType == self.LoginNetWork.ACCOUNT_LOGIN then
            local pwd = self.EditPwd:getText()
            local pwdIsMD5 = false
            if self.EditPwd.orgPassword then
                if self.EditPwd.orgPassword == pwd then
                    pwdIsMD5 = true
                end
            end
            self.LoginNetWork:sendLoginMsg(self.EditAcount:getText(),pwd,pwdIsMD5,self.authenNumber)
            self.authenNumber = nil
        elseif self.LoginNetWork.loginType == self.LoginNetWork.ACCOUNT_REGISTER then
            if self.RegisterAccounts then
                self.LoginNetWork:sendRegisterMsg(self.RegisterAccounts)
            end
        else
            if self.qqAccount and self.qqPwd then
                self.LoginNetWork:sendLoginMsg(self.qqAccount,self.qqPwd,false,self.authenNumber)
                self.authenNumber = nil
            end
        end
        
        self:updateStatusLabel("正在验证用户登录信息")

        -- 保存登录IP
        SessionManager:sharedManager():setLastServerIP(GlobalLogonServerInfo.szServerIP)
    else
        local ip = self:getNextLoginPointIP(GlobalLogonServerInfo.szServerIP)
        if not ip then
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="尝试了所有连接点，连接失败，请稍后重试！",
                callBack=function()
                    self:hideLoadingWidget()
                end
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        else
            GlobalLogonServerInfo.szServerIP = ip
            self.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
        end        
    end
end

function LoginScene:receiveGameShutDownMessage(event)
   print("LoginScene:receiveGameShutDownMessage")
   local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="与服务器断开连接",
            callBack=function()
                self:hideLoadingWidget()
            end
        }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function LoginScene:receiveGameLoginSuccessMessage(event)
    local Params = event.para
    for k,v in pairs(Params) do
        print(k,v)
    end
    self:updateStatusLabel("正在获取游戏列表")
    if self.LoginNetWork.loginType == self.LoginNetWork.ACCOUNT_REGISTER then
        -- 发送注册web统计数据
    StatisticsController:sendStatisticsData(1)
    end
    -- 发送登录web统计数据
    StatisticsController:sendStatisticsData(2)
end

function LoginScene:receiveGameLoginFailedMessage(event)
    local Params = event.para

    -- 验证身份证号码
    if Params.lResultCode == 9 then
        require("plazacenter.widgets.AuthenWidget").new(self,function (authenNumber)
            self:hideLoadingWidget()
            if authenNumber then
                self.authenNumber = authenNumber
                if self.serviceClient then
                    self:showLoadingWidget()
                    self.LoginNetWork:setLoginType(self.LoginNetWork.ACCOUNT_LOGIN)
                    self.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
                    self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
                end
            end
        end)
        return
    end
    local dataMsgBox = {
        nodeParent=self,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString,
        callBack=function()
            self:hideLoadingWidget()
        end
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function LoginScene:receiveGameLoginFinishMessage(event)
    local Params = event.para
    for k,v in pairs(Params) do
        print(k,v)
    end
    self:hideLoadingWidget()
    AppBaseInstanse.PLAZACENTER_APP:enterScene("FrameBaseScene")
end

function LoginScene:receiveQuickLoginSuccessMessage(event)
    -- 快速登录借用QQ登录功能
    local CMD_MB_Quick_Logon_Success = event.para
    --    szAccounts="",
    --    szLogonPass="",
    --    lResultCode= ,
    --    szDescribeString="",
    --}
    if CMD_MB_Quick_Logon_Success.lResultCode == 0 then
        self.qqAccount = CMD_MB_Quick_Logon_Success.szAccounts
        self.qqPwd = CMD_MB_Quick_Logon_Success.szLogonPass
        if self.serviceClient then
            self:showLoadingWidget()
            self.LoginNetWork:setLoginType(self.LoginNetWork.QQ_LOGIN)
            self.serviceClient:Connect(GlobalLogonServerInfo.szServerIP,GlobalLogonServerInfo.dwServerPort)
            self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
        end
    else
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo=CMD_MB_Quick_Logon_Success.szDescribeString
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    end
end

return LoginScene
