
import("..MsgDefine.ninePieceServerDef")

local NinePiecesCommand = class("NinePiecesCommand")

function  NinePiecesCommand:ctor(client)
	self.client = client
end

function  NinePiecesCommand:ready()
	print("NinePiecesCommand:ready")
	self.client:ready()
end

function  NinePiecesCommand:standUp()
	self.client:standUp()
end

function NinePiecesCommand:playCard(cards)
	local CMD_C_OutCard = {}
	CMD_C_OutCard.cbTimeOut = 1
	CMD_C_OutCard.cbCardCount = #cards
	CMD_C_OutCard.cbCardData = cards
	dump(CMD_C_OutCard)
	self.client:requestCommand(MDM_GF_GAME,SUB_C_OUT_CARD,CMD_C_OutCard,"CMD_C_OutCard")
end

--过牌
--1不超时，0超时
function NinePiecesCommand:pass(timeOut)
	local CMD_C_PassCard = { cbTimeOut = timeOut}
	self.client:requestCommand(MDM_GF_GAME,SUB_C_PASS_CARD,CMD_C_PassCard,"CMD_C_PassCard")
end

return NinePiecesCommand