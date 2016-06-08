MAX_CHAMPION_TEXT = 64					--冠军显示
LEN_MATCHTYPE = 32
LEN_REMARK = 32
LEN_AWARD = 32
LEN_MATCHITEMAWARD = 10
LEN_MATCHGAMECOUNT = 10
LEN_MATCHGAMETYPE = 5
LEN_MATCHAWARD = 50	
LEN_MATCHINFO = 30	
LEN_MATCHID = 30	
TCP_MAX_CONNECT = 10000
LEN_ADDR = 16
MAX_MATCHSERVERID = 200					--最大服务器id
MAX_ROOM_NUM = 200						--房间最大人数
MAX_ROOM_NUM = 200						--房间最大人数
MAX_ROOM_TYPE_NUM = 20					--一游戏的赛事
	
MDM_GL_C_DATA = 1						--大厅--客户端数据
SUB_GL_C_LOGON_ACCOUNTS = 100			--帐号登录
SUB_GL_C_MATCH_GAME = 101				--比赛的游戏
SUB_GL_C_MATCH_TYPE = 102				--比赛类型（1每天循环赛，2每天定时赛，3定时赛，4满人开赛）
SUB_GL_C_MATCH_INFO = 103				--比赛列表（添加，更新，是否报名）
SUB_GL_C_MATCH_DELETE = 104				--比赛列表删除
SUB_GL_C_MATCH_NUM = 105				--比赛人数
SUB_GL_C_MATCH_SIGNUP = 106				--比赛报名
SUB_GL_C_MATCH_START = 107				--比赛开始（拉人）
SUB_GL_C_MATCH_RANK = 108				--冠军
SUB_GL_C_MATCH_WITHDRAWAL = 109			--比赛退赛
SUB_GL_C_MATCH_COUNTDOWN = 110			--倒计时
SUB_GL_C_UPDATE_NOTIFY = 111			--版本更新
SUB_GL_C_SYSTEM_MESSAGE = 112			--大厅消息
SUB_GL_C_MESSAGE = 113					--消息、公告、弹窗
SUB_GL_C_TASK_LOAD = 114				--加载任务
SUB_GL_C_TASK_REWARD = 115				--领取奖励
SUB_GL_MB_LOGON_ACCOUNTS = 116			--手机登录
SUB_GL_C_WEALTH_RANK = 117				--财富排名
SUB_GL_C_LABA = 118						--喇叭
SUB_GL_C_LABA_LOG = 119					--喇叭返回 
--邀请好友
SUB_GL_C_LOAD_FRIEND = 120				--加载好友 
SUB_GL_C_LEVEL_REWARD = 121				--好友等级奖励
SUB_GL_C_GET_LEVEL_REWARD = 122			--获取等级奖励
SUB_GL_C_GET_FRIEND_COUNT = 123			--获取好友个数
SUB_GL_C_GET_FRIEND_REWARD = 124		--好友个数奖励

--退赛结果
SUB_GL_WITHDRAW_SUCCESS = 157			--退赛成功
SUB_GL_WITHDRAW_FAILURE = 158			--退赛失败

--登录结果
SUB_GL_LOGON_SUCCESS = 150				--登录成功
SUB_GL_LOGON_FAILURE = 151				--登录失败
--操作结果
SUB_GL_OPERATE_SUCCESS = 152			--操作成功
SUB_GL_OPERATE_FAILURE = 153			--操作失败
SUB_GL_LOGON_LOGOUT_GAMEID = 154		--用户退出

SUB_GL_SIGNUP_SUCCESS = 155				--报名成功
SUB_GL_SIGNUP_FAILURE = 156				--报名失败



MDM_GL_S_DATA = 2						--大厅--房间服务器数据
SUB_UM_L_SERVERLOGIN = 200				--服务器登录
SUB_UM_L_USERCOUNT = 201				--房间人数
SUB_UM_L_MATCHCONFIG = 202				--比赛配置
SUB_UM_L_MATCHSTATUS = 203				--房间当前状态

--服务状态
MatchStatus = {
	Free = 1,				
	WaitFor = 2,
	Start = 3,
	Finish = 4
}

SignUpStatus = {
	SignUp = 1,			--已报名 
	NoSignUp = 2,		--没有报名
	NoMatchID = 3,		--没有比赛场次
	NotAllowSignUp = 4  --恶意报名
}

MsgPositionType = {
	Position_Top = 1,		--上面
	Position_Under = 2,		--下面
	Position_Right = 3,		--右面
}

MsgType = {
	Msg_Delta = 1,			--充值			（只弹一次，登录或在线）
	Msg_Rewards = 2,		--任务奖励		（只弹一次，登录或在线）
	Msg_Sell = 3,			--拍卖			（只弹一次，登录或在线）
	Msg_Rolling = 4,		--滚动消息		 (发送一次，实时显示）
	Msg_Notice = 5,			--公告			（登录或在线，都发送）
}