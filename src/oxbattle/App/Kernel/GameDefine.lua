

OxBattleDefine=
    {
        KIND_ID						=30,									--游戏 I D
        GAME_PLAYER					=5,										--游戏人数
        GAME_NAME					="百人牛牛",  						--游戏名字
        VERSION_SERVER				=8,										--程序版本
        VERSION_CLIENT				=8,										--程序版本
        MYSELF_VIEW_ID              =4,
        GAME_GENRE					="gold",								--游戏类型
        MAXCOUNT					=5,										--扑克数目 
        --结束原因
        GER_NO_PLAYER				=100000,									--没有玩家 
        --用户状态
        USEX_NULL                   =0,                                       --用户状态
        USEX_PLAYING                =1,                                       --用户状态
        USEX_DYNAMIC                =2,                                       --用户状态

        --------------------------------------------------------------------------
        --服务器命令结构
        GAME_SCENE_FREE = 0,	--空闲状态
        GAME_SCENE_PLACE_JETTON = 100	,--下注状态
        GAME_SCENE_GAME_END               = 101,                      --游戏状态
        GAME_SCENE_MOVECARD_END             = 102,                     --游戏进行

        ID_TIAN_MEN                 =1                                   ,--天
        ID_DI_MEN                   =2                                   ,--地
        ID_XUAN_MEN                 =3                                   ,--玄
        ID_HUANG_MEN                =4                                   ,--黄


        SUB_S_GAME_FREE             =99                                  ,--游戏空闲
        SUB_S_GAME_START            =100                                 ,--游戏开始
        SUB_S_PLACE_JETTON          =101                                 ,--用户下注
        SUB_S_GAME_END              =102                                 ,--游戏结束
        SUB_S_APPLY_BANKER          =103                                 ,--申请庄家
        SUB_S_CHANGE_BANKER         =104                                 ,--切换庄家
        SUB_S_CHANGE_USER_SCORE     =105                                 ,--更新积分
        SUB_S_SEND_RECORD           =106                                 ,--游戏记录
        SUB_S_PLACE_JETTON_FAIL     =107                                 ,--下注失败
        SUB_S_CANCEL_BANKER         =108                                 ,--取消申请
        SUB_S_SEND_ACCOUNT          =109                                 ,--发送账号
        SUB_S_ADMIN_CHEAK           =111                                 ,--查询账号
        SUB_S_QIANG_ZHUAN           =112                                 ,--抢庄
        SUB_S_USER_SIT          =113                                 ,--坐下
        SUB_S_USER_LEAVE            =114                                 ,--离开

        SUB_S_AMDIN_COMMAND         =130                                 ,--管理员命令

        GAME_SCENCE                ="OXBATTLE_SCENEME",             -- 场景的消息
        GAME_FREE                  ="OXBATTLE_GAME_FREE"                                  ,--游戏空闲
        GAME_START                 ="OXBATTLE_GAME_START"                                 ,--游戏开始
        GAME_PLACE_JETTON          ="OXBATTLE_PLACE_JETTON"                                 ,--用户下注
        GAME_END                   ="OXBATTLE_GAME_END"                                 ,--游戏结束
        GAME_APPLY_BANKER          ="OXBATTLE_APPLY_BANKER"                                 ,--申请庄家
        GAME_CHANGE_BANKER         ="OXBATTLE_CHANGE_BANKER"                                 ,--切换庄家
        GAME_CHANGE_USER_SCORE     ="OXBATTLE_CHANGE_USER_SCORE"                                 ,--更新积分
        GAME_SEND_RECORD           ="OXBATTLE_SEND_RECORD"                                 ,--游戏记录
        GAME_PLACE_JETTON_FAIL     ="OXBATTLE_PLACE_JETTON_FAIL"                                 ,--下注失败
        GAME_CANCEL_BANKER         ="OXBATTLE_CANCEL_BANKER"                                 ,--取消申请
        GAME_SEND_ACCOUNT          ="OXBATTLE_SEND_ACCOUNT"                                 ,--发送账号
        GAME_ADMIN_CHEAK           ="OXBATTLE_ADMIN_CHEAK"                                 ,--查询账号
        GAME_QIANG_ZHUAN           ="OXBATTLE_QIANG_ZHUAN"                                 ,--抢庄
        GAME_USER_SIT              ="OXBATTLE_USER_SIT"                                 ,--坐下
        GAME_USER_LEAVE            ="OXBATTLE_USER_LEAVE"                                 ,--离开
        GAME_AMDIN_COMMAND         ="OXBATTLE_AMDIN_COMMAND"                                 ,--管理员命令
        
        
        GS_TK_FREE                  = 1,                       --休息一下 
        GS_TK_SCORE                 =2,                     --请下注
        GS_TK_PLAY               =3,                     --即将开始
        
        
        TIME_INTERVAL       =1,                                  --时间间隔
        TIME_USER_CALL_BANKER       =10,                                  --叫庄定时器
        TIME_USER_START_GAME        =10,                                  --开始定时器
        TIME_USER_ADD_SCORE         =10,                                  --放弃定时器
        TIME_USER_OPEN_CARD         =10,                                  --摊牌定时器
        TIME_USER__CARD       =10,                                  --换牌定时器
        TIME_USER_OPEN_ING   = 10,

        OX_VALUE                    =0                                   ,--混合牌型
        OX_THREE_SAME               =102                                 ,--三条牌型
        OX_FOUR_SAME                =103                                 ,--四条牌型
        OX_FOURKING                 =104                                 ,--天王牌型
        OX_FIVEKING                 =105                                 ,--天王牌型

        --客户端命令结构
        SUB_C_PLACE_JETTON         =1                                  ,--用户下注
        SUB_C_APPLY_BANKER          =2                                  ,--申请庄家
        SUB_C_CANCEL_BANKER         =3                                  ,--取消申请
        SUB_C_CONTINUE_CARD         =4                                  ,--继续发牌
        SUB_C_AMDIN_COMMAND         =6                                  ,--管理员命令

        SUB_C_HIDDEN_ANDROID        =5                                   ,--屏蔽机器
        SUB_S_GET_ACCOUNT           =7                                   ,--获取昵称
        SUB_S_CHEAK_ACCOUNT         =8                                   ,--获取昵称
        SUB_S_SCORE_RESULT          =9                                   ,--积分结果
        SUB_S_ACCOUNT_RESULT        =10                                  ,--帐号结果

        SUB_C_QIANG_ZHUAN           =11                                  ,--抢庄

        SUB_C_USER_SIT          =12                                      ,--用户坐下

        mp3 = 1,
        m4a = 2,
        wav = 3,

        animStartAddSource = 0,
        animWhiteCloud = 1,
        animRedCloud = 2,
        animHead = 3,
    }