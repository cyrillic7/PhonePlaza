local NotificationCenter = class("NotificationCenter")

function NotificationCenter:ctor()
	-- 注册消息模块
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

-- 传入listener的定义信息 
-- {name = listener, ..}
-- 返回所有handle
function NotificationCenter:addAllEventListenerByTable(listeners)
	if listeners and type(listeners) == "table" then
		self.result_handles = {}
		for name, listener in pairs(listeners) do
			table.insert(self.result_handles, self:addEventListener(name, listener))
		end
		return self.result_handles
	end
	
end

-- 传入所有handles，删除所有listener
function NotificationCenter:removeAllListenerByTable(handles)
	if handles and type(handles) == "table" then
		for i, v in pairs(handles) do
			self:removeEventListener(v)
			handles[i] = nil
		end
	end
end

return NotificationCenter