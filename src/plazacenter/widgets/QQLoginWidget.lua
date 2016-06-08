--
-- Author: SuperM
-- Date: 2015-11-15 14:38:47
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local QQLoginWidget = class("QQLoginWidget", XWWidgetBase)

function QQLoginWidget:ctor(parentNode,callBack)
	QQLoginWidget.super.ctor(self)

	self.callBack = callBack

	self:addTo(parentNode)
end
function QQLoginWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	QQLoginWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_QQ_LOGIN_CSB_FILE)
    if not node then
        return
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Close")
    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local panelWeb = cc.uiloader:seekNodeByName(node, "Panel_Web")
    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
    		self.callBack()
    		self:removeFromParent()
    	end)
    	
    end
    self:addChild(node)

    if device.platform ~= "android" and device.platform ~= "ios" then
        return
    end

    local code=cc.Crypto:MD5("server"..GlobalChannelDef.k_session_id..GlobalChannelDef.k_session_verion.."lmyspread", false)
    local qqUrl="http://qq.719you.com/QQLogin.aspx?sessionID="..GlobalChannelDef.k_session_id.."&code="..code.."&machineCode="..GlobalPlatInfo.szMachineID
    local web = ccexp.WebView:create()		 
    web:pos(panelWeb:getContentSize().width/2,panelWeb:getContentSize().height/2)
    web:size(panelWeb:getContentSize())
    --web:loadURL("http://www.719you.com/QQLogin.aspx?sessionID=122&code=6d80b7946f80b5301a6bc318183e60fd&machineCode=mobilea3a9ce61a1164a0199bc547dfa")
    web:loadURL(qqUrl)
    --web:setJavascriptInterfaceScheme("http")
    --web:setJsCallback(jsCallback) 
 	web:setOnDidCallback(handler(self,self.jsCallback))
    web:setOnFailCallback(handler(self,self.failCallback))
    panelWeb:addChild(web)

    G_ShowNodeWithBackout(bgnode)
end

function QQLoginWidget:jsCallback(sender, str)
    print("jsCallback ", str)
    local _start,_end,id,pwd = string.find(str,"Id=(.+)&pwd=(.+)")
    if _start then
    	if self.callBack then
            self:performWithDelay(function()
                self.callBack(id,pwd)
                self:removeFromParent()
            end, 0)
    	end
    end
end

function QQLoginWidget:failCallback(sender, str)
    print("failCallback ", str)
end

return QQLoginWidget