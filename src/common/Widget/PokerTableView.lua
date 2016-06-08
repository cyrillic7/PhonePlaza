-- 牌桌
-- Author: tjl
-- Date: 2015-11-06 09:19:38
--

local PokerTableView = class("PokerTableView", function()
	local lay = ccui.Layout:create()
	lay:setContentSize(cc.size(display.cx*2, display.cy*2))
	lay:ignoreContentAdaptWithSize(false)
	return lay
end)

-- 游戏桌子的左边, 右边, 中间方向表
PokerTableSide = {left = -1, middle = 0, right = 1}

-- positions 桌子对应的所有座位坐标点, 以自己座位坐标点为首个元素, 其他元素以顺时针(BJ)或者逆时针或者其他规则形成的座位坐标点数组
function PokerTableView:ctor( positions )
	-- 所有座位坐标点数组
	self.allPositions = positions or {}

	-- 玩家座位数组, key为玩家id, value为座位坐标点
	self.playerPositions = self.playerPositions or {}

	-- 自己的id
	self.myselfId = nil

	self.seatViews = {}
	self.playerIds = {}
end

-- 设置坐下来的玩家id数组
-- playerIds 传入玩家id数组, 只包括坐下来的玩家的id
function PokerTableView:setPlayerIds( playerIds )
	-- 玩家id数组
	self.playerIds = playerIds or {}
	-- 排序
	self:sortPlayers()
end

-- 对玩家id从小到大进行排序
function PokerTableView:sortPlayers( )
	table.sort(self.playerIds)
end

-- 座位排序
-- myselfId 自己的id, 为nil时表示自己没有坐下, 否则表示坐下了
function PokerTableView:sortPlayerSeats( myselfId )
	self:clearAllPlayerPositions()
	self.myselfId = myselfId

	if myselfId then -- 自己坐下来了
		self:sortPlayerSeatsWithMyself(myselfId)		
	else -- 自己没有坐下来
		self:sortPlayerSeatsWithoutMyself()	
	end	
end

-- 座位排序, 自己坐下了
function PokerTableView:sortPlayerSeatsWithMyself( myselfId )
	local pid = myselfId
	for i = 1, #self.allPositions do
		if pid then
			-- self.playerPositions[pid] = self.allPositions[i]
			self.playerPositions[pid] = self:getPlayerPosition(pid)
			pid = self:getNextPlayer(pid)
		end

		if nil == pid or tonumber(pid) == tonumber(myselfId) then
			break
		end
	end
end

-- 根据playerId获取座位, 只适应自己坐下来的情况
function PokerTableView:getPlayerPosition( playerId )
	if playerId and playerId >= 1 and playerId <= #self.allPositions then
		local index = 1
		if playerId < self.myselfId then
			index = #self.allPositions - (self.myselfId - playerId - 1)
		elseif playerId > self.myselfId then
			index = playerId - self.myselfId + 1
		end
		return self.allPositions[index]
	end
end

-- 座位排序, 自己没有坐下来
function PokerTableView:sortPlayerSeatsWithoutMyself(  )
	for i = 1, #self.playerIds do
		local pid = self.playerIds[i]
		self.playerPositions[pid] = self.allPositions[i]
	end
end

-- 根据指定玩家id来获取这个玩家下手玩家的id
function PokerTableView:getNextPlayer( playerId )
	if playerId then
		local index = 0
		for i = 1, #self.playerIds do
			if tonumber(playerId) == tonumber(self.playerIds[i]) then
				index = i
				break
			end
		end

		if index > 0 then
			if index < #self.playerIds then
				return self.playerIds[index + 1]
			else
				return self.playerIds[1]		
			end	
		end
	end
end

-- 清除所有玩家的位置信息
function PokerTableView:clearAllPlayerPositions( )
	for i = 1, #self.playerIds do
		self.playerPositions[self.playerIds[i]] = nil
	end
end

-- 加入玩家
-- playerId 加入桌子的玩家id
-- isMyself 这个玩家是不是自己
function PokerTableView:addPlayer( playerId, isMyself )
	if playerId then
		if tonumber(playerId) > #self.allPositions then
			print("[error!], [桌子], [玩家的playerId大于桌子的席位数]")
		elseif self.playerPositions[playerId] then
		 	print("[error!], [桌子], [玩家已经坐下了]")
		else
			table.insert(self.playerIds, playerId)
			self:sortPlayers()

			-- 重新排座位
			if isMyself then
				self:sortPlayerSeats(playerId)
			else
				self:sortPlayerSeats(self.myselfId)
			end
		end
	end
end

-- 玩家走了
function PokerTableView:removePlayer( playerId )
	if playerId then
		--移除的是自己时清空myselfId
		if self.myselfId and self.myselfId == playerId then
			self.myselfId = nil
		end
		-- 先从玩家位置表中删除这个玩家的位置信息
		self.playerPositions[playerId] = nil


		-- 再删除玩家id，从玩家数组中
		local index = table.indexof(self.playerIds, playerId)
		if index then
			table.remove(self.playerIds, index)
		end
	end
end

-- 获取玩家位置信息表
-- key为玩家id, value为座位坐标点
function PokerTableView:getPlayerPositionTable( )
	return self.playerPositions
end

return PokerTableView