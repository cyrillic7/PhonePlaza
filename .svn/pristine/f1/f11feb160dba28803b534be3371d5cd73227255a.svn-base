--
-- Author: Your Name
-- Date: 2015-10-26 17:19:11
--
local XWWidgetBase = class("XWWidgetBase", function ()
	return display.newNode()
end)

function XWWidgetBase:ctor()
    self:setNodeEventEnabled(true)
	print("XWWidgetBase:ctor")
	if self.loadPlistRes then
		self:loadPlistRes()
	end

	self.bFirstEnter = true
end

function XWWidgetBase:onEnter()
	print("XWWidgetBase:onEnter")
	self.bFirstEnter = false
end

function XWWidgetBase:onExit()
	print("XWWidgetBase:onExit")
	self:hideLoadingWidget()
end

function XWWidgetBase:onCleanup()
	print("XWWidgetBase:onCleanup")
	if self.cleanPlistRes then
		self:cleanPlistRes()
	end
end

function XWWidgetBase:showLoadingWidget()
    self.loadingWidget = require("plazacenter.widgets.CommonLoadingWidget").new(self)
end

function XWWidgetBase:hideLoadingWidget()
    if self.loadingWidget ~= nil then
        self.loadingWidget:hideLoadingWidget()
        self.loadingWidget = nil
    end
end

function XWWidgetBase:updateStatusLabel(statusText)
    if self.loadingWidget ~= nil then
        self.loadingWidget:updateStatusLabel(statusText)
    end
end

return XWWidgetBase