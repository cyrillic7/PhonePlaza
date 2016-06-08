
import("..MsgDefine.baccaratServerDef")

local baccaratCommand = class("baccaratCommand")

function  baccaratCommand:ctor(client)
	self.client = client
end

function baccaratCommand:bet(area,score)
	local CMD_C_PlaceBet = {
		cbBetArea= area,
		lBetScore= score,
	}
	self.client:requestCommand(MDM_GF_GAME,SUB_C_PLACE_JETTON,CMD_C_PlaceBet,"CMD_C_PlaceBet")
end

function  baccaratCommand:standUp()
	self.client:standUp()
end

function  baccaratCommand:applyBanker()
	self.client:requestCommand(MDM_GF_GAME,SUB_C_APPLY_BANKER)
end

function baccaratCommand:cancelBanker()
	self.client:requestCommand(MDM_GF_GAME,SUB_C_CANCEL_BANKER)
end

function baccaratCommand:qiangBanker()
	print("send qiangBanker")
	self.client:requestCommand(MDM_GF_GAME,SUB_C_QIANG_ZHUAN)
end

function baccaratCommand:PerformQueryInfo()
	local CMD_GR_C_QueryInsureInfoRequest = {
		cbActivityGame=0,
		szInsurePass=GlobalUserInfo.szPassword,
	}
    self.client:requestCommand(MDM_GR_INSURE, SUB_GR_QUERY_INSURE_INFO, 
    	CMD_GR_C_QueryInsureInfoRequest,"CMD_GR_C_QueryInsureInfoRequest")
end

--银行取钱操作
function baccaratCommand:PerformTakeScore(lTakeScore,strMd5Pwd)
	self.m_lScore = lTakeScore
	local CMD_GR_C_TakeScoreRequest = {
		cbActivityGame=0,
		lTakeScore=lTakeScore,
		szInsurePass=strMd5Pwd,
	}

	self.client:requestCommand(MDM_GR_INSURE, SUB_GR_TAKE_SCORE_REQUEST, 
    	CMD_GR_C_TakeScoreRequest,"CMD_GR_C_TakeScoreRequest")
end

--银行存钱请求
function baccaratCommand:PerformSaveScore(lSaveScore)
	self.m_lScore = lSaveScore

	local CMD_GR_C_SaveScoreRequest = {
		cbActivityGame=0,
		lSaveScore=lSaveScore,
	}

	self.client:requestCommand(MDM_GR_INSURE, SUB_GR_SAVE_SCORE_REQUEST, 
    	CMD_GR_C_SaveScoreRequest,"CMD_GR_C_SaveScoreRequest")
end

return baccaratCommand