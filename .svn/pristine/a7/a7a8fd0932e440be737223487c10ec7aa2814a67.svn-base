require("common.BitMethodEx")
--产品版本
BULID_VER = 0				--授权版本
PRODUCT_VER = 1				--产品版本
function PROCESS_VERSION(cbMainVer,cbSubVer,cbBuildVer)
	return (bitEx:_lshift(PRODUCT_VER,24)+
		bitEx:_lshift(cbMainVer,16)+
		bitEx:_lshift(cbSubVer,8)+
		cbBuildVer)
end
--程序版本
VERSION_FRAME = PROCESS_VERSION(0,0,1)				--框架版本
VERSION_PLAZA = PROCESS_VERSION(7,0,1)				--大厅版本
VERSION_MOBILE_ANDROID = PROCESS_VERSION(0,0,1)		--手机版本
VERSION_MOBILE_IOS = PROCESS_VERSION(0,0,1)			--手机版本
VERSION_GAME = PROCESS_VERSION(5,0,1)				--游戏版本


--游戏状态
GAME_STATUS_FREE = 0 	--空闲状态
GAME_STATUS_PLAY = 100	--游戏状态
--阳山九张游戏状态
GAME_STATUS_9zhangPLAY = 101	--游戏状态
GAME_STATUS_WAIT = 200	--等待状态

--人数定义
MAX_CHAIR = 100			--最大椅子
MAX_TABLE = 512			--最大桌子
MAX_COLUMN = 32			--最大列表
MAX_ANDROID = 256		--最大机器
MAX_PROPERTY = 128		--最大道具
MAX_WHISPER_USER = 16	--最大私聊
HUNDRRED_GAME_NUM = 40  --百人游戏人数

--列表定义
MAX_KIND = 128			--最大类型
MAX_SERVER = 1024		--最大房间

--参数定义
INVALID_CHAIR = 0xFFFF	--无效椅子
INVALID_TABLE = 0xFFFF	--无效桌子

--性别定义
GENDER_FEMALE = 0					--女性性别
GENDER_MANKIND = 1					--男性性别

--////////////////////////////////////////////////////////////////////////////////

--游戏模式
GAME_GENRE_GOLD = 0x0001			--金币类型
GAME_GENRE_SCORE = 0x0002			--点值类型
GAME_GENRE_MATCH = 0x0004			--比赛类型
GAME_GENRE_EDUCATE = 0x0008			--训练类型

--分数模式
SCORE_GENRE_NORMAL = 0x0100			--普通模式
SCORE_GENRE_POSITIVE = 0x0200		--非负模式

--用户状态
US_NULL = 0x00			--没有状态
US_FREE = 0x01			--站立状态
US_SIT = 0x02			--坐下状态
US_READY = 0x03			--同意状态
US_LOOKON = 0x04		--旁观状态
US_PLAYING = 0x05		--游戏状态
US_OFFLINE = 0x06		--断线状态

--////////////////////////////////////////////////////////////////////////////////

--比赛状态
MS_NULL = 0x00			--没有状态
MS_SIGNUP = 0x01		--报名状态
MS_MATCHING = 0x02		--比赛状态
MS_OUT = 0x03			--淘汰状态
MS_LEAVE = 0x04			--退赛状态
MS_WIN = 0x05			--胜出状态
MS_OFFLINE = 0x06		--离线状态

--////////////////////////////////////////////////////////////////////////////////

--房间规则
SRL_LOOKON = 0x00000001			--旁观标志
SRL_OFFLINE = 0x00000002		--断线标志
SRL_SAME_IP = 0x00000004		--同网标志

--房间规则
SRL_ROOM_CHAT = 0x00000100		--聊天标志
SRL_GAME_CHAT = 0x00000200		--聊天标志
SRL_WISPER_CHAT = 0x00000400	--私聊标志
SRL_HIDE_USER_INFO = 0x00000800	--隐藏标志


--聊天规则
SR_FORFEND_GAME_CHAT = 0x00000001			--禁止公聊
SR_FORFEND_ROOM_CHAT = 0x00000002			--禁止公聊
SR_FORFEND_WISPER_CHAT = 0x00000004			--禁止私聊
SR_FORFEND_WISPER_ON_GAME = 0x00000008		--禁止私聊

--高级规则
SR_ALLOW_DYNAMIC_JOIN = 0x00000010			--动态加入
SR_ALLOW_OFFLINE_TRUSTEE = 0x00000020		--断线代打
SR_ALLOW_AVERT_CHEAT_MODE = 0x00000040		--隐藏信息

--游戏规则
SR_RECORD_GAME_SCORE = 0x00000100			--记录积分
SR_RECORD_GAME_TRACK = 0x00000200			--记录过程
SR_DYNAMIC_CELL_SCORE = 0x00000400			--动态底分
SR_IMMEDIATE_WRITE_SCORE = 0x00000800		--即时写分

--房间规则
SR_FORFEND_ROOM_ENTER = 0x00001000			--禁止进入
SR_FORFEND_GAME_ENTER = 0x00002000			--禁止进入
SR_FORFEND_GAME_LOOKON = 0x00004000			--禁止旁观

--银行规则
SR_FORFEND_TAKE_IN_ROOM = 0x00010000		--禁止取款
SR_FORFEND_TAKE_IN_GAME = 0x00020000		--禁止取款
SR_FORFEND_SAVE_IN_ROOM = 0x00040000		--禁止存钱
SR_FORFEND_SAVE_IN_GAME = 0x00080000		--禁止存款

--其他规则
SR_FORFEND_GAME_RULE = 0x00100000			--禁止配置
SR_FORFEND_LOCK_TABLE = 0x00200000			--禁止锁桌
SR_ALLOW_ANDROID_ATTEND = 0x00400000		--允许陪玩
SR_ALLOW_ANDROID_SIMULATE = 0x00800000		--允许占位


SR_NO_WIN_LOSE = 0x01000000					--不列入输赢
SR_SAME_IP = 0x02000000						--禁止同ip同桌
SR_IS_TRAIN_ROOM = 0x04000000				--是否是体验场


--////////////////////////////////////////////////////////////////////////////////

--用户权限
UR_CANNOT_PLAY = 0x00000001					--不能进行游戏
UR_CANNOT_LOOKON = 0x00000002				--不能旁观游戏
UR_CANNOT_WISPER = 0x00000004				--不能发送私聊
UR_CANNOT_ROOM_CHAT = 0x00000008			--不能大厅聊天
UR_CANNOT_GAME_CHAT = 0x00000010			--不能游戏聊天
UR_CANNOT_BUGLE = 0x00000020				--不能发送喇叭

--会员权限
UR_GAME_DOUBLE_SCORE = 0x00000100			--游戏双倍积分
UR_GAME_KICK_OUT_USER = 0x00000200			--游戏踢出用户
UR_GAME_ENTER_VIP_ROOM = 0x00000400			--进入VIP房间 

--用户身份
UR_GAME_MATCH_USER = 0x10000000				--游戏比赛用户
UR_GAME_CHEAT_USER = 0x20000000				--游戏作弊用户

--////////////////////////////////////////////////////////////////////////////////

--普通管理
UR_CAN_LIMIT_PLAY = 0x00000001				--允许禁止游戏
UR_CAN_LIMIT_LOOKON = 0x00000002			--允许禁止旁观
UR_CAN_LIMIT_WISPER = 0x00000004			--允许禁止私聊
UR_CAN_LIMIT_ROOM_CHAT = 0x00000008			--允许禁止聊天
UR_CAN_LIMIT_GAME_CHAT = 0x00000010			--允许禁止聊天

--用户管理
UR_CAN_KILL_USER = 0x00000100				--允许踢出用户
UR_CAN_SEE_USER_IP = 0x00000200				--允许查看地址
UR_CAN_DISMISS_GAME = 0x00000400			--允许解散游戏
UR_CAN_LIMIT_USER_CHAT = 0x00000800			--允许禁止玩家聊天
--高级管理
UR_CAN_CONFINE_IP = 0x00001000				--允许禁止地址
UR_CAN_CONFINE_MAC = 0x00002000				--允许禁止机器
UR_CAN_SEND_WARNING = 0x00004000			--允许发送警告
UR_CAN_MODIFY_SCORE = 0x00008000			--允许修改积分
UR_CAN_FORBID_ACCOUNTS = 0x00010000			--允许封锁帐号

--绑定管理
UR_CAN_BIND_GAME = 0x00100000				--允许游戏绑定
UR_CAN_BIND_GLOBAL = 0x00200000				--允许全局绑定

--配置管理
UR_CAN_ISSUE_MESSAGE = 0x01000000			--允许发布消息
UR_CAN_MANAGER_SERVER = 0x02000000			--允许管理房间
UR_CAN_MANAGER_OPTION = 0x04000000			--允许管理配置
UR_CAN_MANAGER_ANDROID = 0x08000000			--允许管理机器

--类型掩码
SMT_CHAT = 0x0001							--聊天消息
SMT_EJECT = 0x0002							--弹出消息
SMT_GLOBAL = 0x0004							--全局消息
SMT_PROMPT = 0x0008							--提示消息
SMT_TABLE_ROLL = 0x0010						--滚动消息
SMT_NOGOLD = 0x0020							--金币不足             

--控制掩码
SMT_CLOSE_ROOM = 0x0100						--关闭房间
SMT_CLOSE_GAME = 0x0200						--关闭游戏
SMT_CLOSE_LINK = 0x0400						--中断连接
SMT_CLOSE_HALL = 0x0800						--中断连接

-- IPC_GameFrame.h
IPC_CMD_GF_SOCKET = 1						--网络消息

IPC_SUB_GF_SOCKET_SEND = 1					--网络发送
IPC_SUB_GF_SOCKET_RECV = 2					--网络接收
--////////////////////////////////////////////////////////////////////////////////
--控制消息

IPC_CMD_GF_CONTROL = 2						--控制消息

IPC_SUB_GF_CLIENT_READY = 1					--准备就绪
IPC_SUB_GF_CLIENT_CLOSE = 2					--进程关闭

IPC_SUB_GF_CLOSE_PROCESS = 100				--关闭进程
IPC_SUB_GF_ACTIVE_PROCESS = 101				--激活进程

IPC_SUB_GF_BOSS_COME = 200					--老板来了
IPC_SUB_GF_BOSS_LEFT = 201					--老板走了
--////////////////////////////////////////////////////////////////////////////////
--配置消息

IPC_CMD_GF_CONFIG = 3						--配置消息

IPC_SUB_GF_LEVEL_INFO = 100					--等级信息
IPC_SUB_GF_COLUMN_INFO = 101				--列表信息
IPC_SUB_GF_SERVER_INFO = 102				--房间信息
IPC_SUB_GF_PROPERTY_INFO = 103				--道具信息
IPC_SUB_GF_CONFIG_FINISH = 104				--配置完成
IPC_SUB_GF_USER_RIGHT = 107					--玩家权限
--////////////////////////////////////////////////////////////////////////////////
--用户消息

IPC_CMD_GF_USER_INFO = 4					--用户消息

IPC_SUB_GF_USER_ENTER = 100					--用户进入
IPC_SUB_GF_USER_SCORE = 101					--用户分数
IPC_SUB_GF_USER_STATUS = 102				--用户状态
IPC_SUB_GF_USER_ATTRIB = 103				--用户属性
IPC_SUB_GF_CUSTOM_FACE = 104				--自定头像
IPC_SUB_GF_KICK_USER = 105                  --用户踢出
IPC_SUB_GF_QUICK_TRANSPOS = 106             --用户换位
IPC_SUB_GF_MATCH_USER_ENTER = 110			--用户进入比赛
IPC_SUB_GF_MATCH_USER_LEAVE = 111			--用户离开比赛
IPC_SUB_GF_MATCH_USER_STATUS = 112			--用户比赛状态

--////////////////////////////////////////////////////////////////////////////////
--比赛消息
IPC_CMD_GF_MATCH_INFO = 6					--比赛消息

IPC_SUB_GF_EXIT_MATCH = 100					--离开比赛

IPC_SUB_GF_SINGUP_NEXT_MATCH = 110			--报名下一场比赛



MsgPositionType = {
	Position_Top = 1,		-- 上面
	Position_Under = 2,			-- 下面
	Position_Right = 3,			-- 右面
}

MsgType = {
	Msg_Delta = 1,			-- 充值			（只弹一次，在线）
	Msg_Rewards = 2,			-- 任务完成		（只弹一次，在线）
	Msg_Sell = 3,				-- 拍卖			（只弹一次，在线）
	Msg_Rolling = 4,			-- 滚动消息		 (发送一次，实时显示）
	Msg_Notice = 5,				-- 公告			（登录或在线，都发送）
	Msg_Building = 6,			-- 抢楼			 只弹一次，在线）
	Msg_Sell_Success = 7,		-- 拍卖成功
	Msg_Vip = 8,				-- vip			（只弹一次，在线
	Msg_9 = 9,
	Msg_10 = 10,
	Msg_11 = 11,
	Msg_12 = 12,
}