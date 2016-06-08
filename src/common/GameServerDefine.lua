--登录命令
MDM_GR_LOGON = 1			--登录信息

--登录模式
SUB_GR_LOGON_USERID = 1		--I D 登录
SUB_GR_LOGON_MOBILE = 2		--手机登录
SUB_GR_LOGON_ACCOUNTS = 3	--帐户登录

--登录结果
SUB_GR_LOGON_SUCCESS = 100	--登录成功
SUB_GR_LOGON_FAILURE = 101	--登录失败
SUB_GR_LOGON_FINISH = 102	--登录完成
--升级提示
SUB_GR_UPDATE_NOTIFY = 200	--升级提示

--配置命令

MDM_GR_CONFIG = 2				--配置信息

SUB_GR_CONFIG_COLUMN = 100		--列表配置
SUB_GR_CONFIG_SERVER = 101		--房间配置
SUB_GR_CONFIG_PROPERTY = 102	--道具配置
SUB_GR_CONFIG_FINISH = 103		--配置完成
SUB_GR_CONFIG_USER_RIGHT = 104	--玩家权限

--用户命令

MDM_GR_USER = 3				--用户信息

--用户动作
SUB_GR_USER_RULE = 1				--用户规则
SUB_GR_USER_LOOKON = 2				--旁观请求
SUB_GR_USER_SITDOWN = 3				--坐下请求
SUB_GR_USER_STANDUP = 4				--起立请求
SUB_GR_USER_INVITE = 5				--用户邀请
SUB_GR_USER_INVITE_REQ = 6			--邀请请求
SUB_GR_USER_REPULSE_SIT = 7			--拒绝玩家坐下
SUB_GR_USER_KICK_USER = 8           --踢出用户
SUB_GR_USER_INFO_REQ = 9            --请求用户信息
SUB_GR_USER_CHAIR_REQ = 10          --请求更换位置
SUB_GR_USER_CHAIR_INFO_REQ = 11     --请求椅子用户信息
SUB_GR_USER_WAIT_DISTRIBUTE = 12	--等待分配
SUB_GR_CHECK_IN_GET_SCORE = 13      --签到领币
SUB_GR_MATCHCLIENT_STATUS = 14      --比赛客户端状态

SUB_GR_TERMINAL = 20 				--平台ID

SUB_GR_MATCHUSER_COME = 30			--参赛用户进入

--用户状态
SUB_GR_USER_ENTER = 100				--用户进入
SUB_GR_USER_SCORE = 101				--用户分数
SUB_GR_USER_STATUS = 102			--用户状态
SUB_GR_REQUEST_FAILURE = 103		--请求失败
SUB_GR_TRAIN_USER_SCORE = 104		--新增，体验场用户分数，不更新大厅积分，只更新房间积分
SUB_GR_USER_MATCH_STATUS = 105		--用户比赛状态
SUB_GR_USER_RANK = 106				--用户名次

--状态命令

MDM_GR_STATUS = 4					--状态信息

SUB_GR_TABLE_INFO = 100				--桌子信息
SUB_GR_TABLE_STATUS = 101			--桌子状态

--银行命令

MDM_GR_INSURE = 5					--用户信息

--银行命令
SUB_GR_QUERY_INSURE_INFO = 1		--查询银行
SUB_GR_SAVE_SCORE_REQUEST = 2		--存款操作
SUB_GR_TAKE_SCORE_REQUEST = 3		--取款操作
SUB_GR_TRANSFER_SCORE_REQUEST = 4	--取款操作
SUB_GR_QUERY_USER_INFO_REQUEST = 5	--查询用户
SUB_GR_INSURE_RECORD = 6			--银行记录

SUB_GR_USER_INSURE_INFO = 100		--银行资料
SUB_GR_USER_INSURE_SUCCESS = 101	--银行成功
SUB_GR_USER_INSURE_FAILURE = 102	--银行失败
SUB_GR_USER_TRANSFER_USER_INFO = 103--用户资料

--管理命令

MDM_GR_MANAGE = 6					--管理命令

SUB_GR_SEND_WARNING = 1				--发送警告
SUB_GR_SEND_MESSAGE = 2				--发送消息
SUB_GR_LOOK_USER_IP = 3				--查看地址
SUB_GR_KILL_USER = 4				--踢出用户
SUB_GR_LIMIT_ACCOUNS = 5			--禁用帐户
SUB_GR_SET_USER_RIGHT = 6			--权限设置

--房间设置
SUB_GR_QUERY_OPTION = 7				--查询设置
SUB_GR_OPTION_SERVER = 8			--房间设置
SUB_GR_OPTION_CURRENT = 9			--当前设置

SUB_GR_LIMIT_USER_CHAT = 10			--限制聊天

SUB_GR_KICK_ALL_USER = 11			--踢出用户
SUB_GR_DISMISSGAME = 12				--解散游戏

--比赛命令

MDM_GR_MATCH = 7					--比赛命令

SUB_GR_MATCH_FEE = 400					--报名费用
SUB_GR_MATCH_NUM = 401					--等待人数
SUB_GR_LEAVE_MATCH = 402				--退出比赛
SUB_GR_MATCH_INFO = 403					--比赛信息
SUB_GR_MATCH_WAIT_TIP = 404				--等待提示
SUB_GR_MATCH_RESULT = 405				--比赛结果
SUB_GR_MATCH_STATUS = 406				--比赛状态
SUB_GR_MATCH_DESC = 408					--比赛描述
SUB_GR_MATCH_INFO_START = 410			--开始了
SUB_GR_MATCH_RECOME = 411				--重新回来
SUB_GR_MATCH_USER_LEAVE = 412			--人员状态
SUB_GR_START_MATCHCLIENT = 413			--启动等待界面

SUB_GR_MATCH_SCREEN_FISH = 420			--比赛信息

SUB_GR_MATCHFISH_INFO = 421				--比赛信息

--框架命令

MDM_GF_FRAME = 100						--框架命令

--框架命令

--用户命令
SUB_GF_GAME_OPTION = 1					--游戏配置
SUB_GF_USER_READY = 2					--用户准备
SUB_GF_LOOKON_CONFIG = 3				--旁观配置

--聊天命令
SUB_GF_USER_CHAT = 10					--用户聊天
SUB_GF_USER_EXPRESSION = 11				--用户表情

--游戏信息
SUB_GF_GAME_STATUS = 100				--游戏状态
SUB_GF_GAME_SCENE = 101					--游戏场景
SUB_GF_LOOKON_STATUS = 102				--旁观状态

--系统消息
SUB_GF_SYSTEM_MESSAGE = 200				--系统消息
SUB_GF_ACTION_MESSAGE = 201				--动作消息

--游戏命令

MDM_GF_GAME = 200						--游戏命令

--////////////////////////////////////////////////////////////////////////////////
--携带信息

--其他信息
DTP_GR_TABLE_PASSWORD = 1				--桌子密码

--用户属性
DTP_GR_NICK_NAME = 10					--用户昵称
DTP_GR_GROUP_NAME = 11					--社团名字
DTP_GR_UNDER_WRITE = 12					--个性签名
DTP_GR_CAPACITY_SCORE = 13 			--能力积分

--附加信息
DTP_GR_USER_NOTE = 20					--用户备注
DTP_GR_CUSTOM_FACE = 21					--自定头像

--////////////////////////////////////////////////////////////////////////////////

--请求错误
REQUEST_FAILURE_NORMAL = 0				--常规原因
REQUEST_FAILURE_NOGOLD = 1				--金币不足
REQUEST_FAILURE_NOSCORE = 2				--积分不足
REQUEST_FAILURE_PASSWORD = 3			--密码错误

--///////////////////////////////////////////////////////////////////////////////////
MDM_CM_SYSTEM = 1000					--系统命令
SUB_CM_SYSTEM_MESSAGE = 1				--系统消息
SUB_CM_ACTION_MESSAGE = 2				--动作消息
