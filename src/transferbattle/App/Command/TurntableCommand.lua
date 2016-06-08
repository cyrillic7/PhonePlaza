
import("..MsgDefine.turnTableServerDef")

local TurntableCommand = class("TurntableCommand")

function  TurntableCommand:ctor(client)
	self.client = client
end

function TurntableCommand:bet(area,score)
	local CMD_C_PlaceJetton = {}
	CMD_C_PlaceJetton.cbJettonArea = area
	CMD_C_PlaceJetton.lJettonScore = score
	
	print("TurntableCommand:bet")
	self.client:requestCommand(MDM_GF_GAME,SUB_C_PLACE_JETTON,CMD_C_PlaceJetton,"CMD_C_PlaceJetton")
end

function  TurntableCommand:standUp()
	self.client:standUp()
end

function  TurntableCommand:applyBanker()
	self.client:requestCommand(MDM_GF_GAME,SUB_C_APPLY_BANKER)
end

function TurntableCommand:cancelBanker()
	self.client:requestCommand(MDM_GF_GAME,SUB_C_CANCEL_BANKER)
end

function TurntableCommand:qiangBanker()
	print("send qiangBanker")
	self.client:requestCommand(MDM_GF_GAME,SUB_C_QIANG_ZHUAN)
end

function TurntableCommand:PerformQueryInfo()
	local CMD_GR_C_QueryInsureInfoRequest = {
		cbActivityGame=0,
		szInsurePass=GlobalUserInfo.szPassword,
	}
    self.client:requestCommand(MDM_GR_INSURE, SUB_GR_QUERY_INSURE_INFO, 
    	CMD_GR_C_QueryInsureInfoRequest,"CMD_GR_C_QueryInsureInfoRequest")
end

function TurntableCommand:PerformTakeScore(lTakeScore,strMd5Pwd)
	self.m_lScore = lTakeScore
	local CMD_GR_C_TakeScoreRequest = {
		cbActivityGame=0,
		lTakeScore=lTakeScore,
		szInsurePass=strMd5Pwd,
	}

	self.client:requestCommand(MDM_GR_INSURE, SUB_GR_TAKE_SCORE_REQUEST, 
    	CMD_GR_C_TakeScoreRequest,"CMD_GR_C_TakeScoreRequest")
end

function TurntableCommand:PerformSaveScore(lSaveScore)
	self.m_lScore = lSaveScore

	local CMD_GR_C_SaveScoreRequest = {
		cbActivityGame=0,
		lSaveScore=lSaveScore,
	}

	self.client:requestCommand(MDM_GR_INSURE, SUB_GR_SAVE_SCORE_REQUEST, 
    	CMD_GR_C_SaveScoreRequest,"CMD_GR_C_SaveScoreRequest")
end

return TurntableCommand