RedninebattleDefine=
    {
        KIND_ID                     =105,                                   --游戏 I D 
        GAME_NAME                   ="温州两张",                        --游戏名字 
        GAME_GENRE                  ="gold",                                --游戏类型
        MAXCOUNT                    =5,                                     --扑克数目
        GAME_PLAYER                 = 9999999,
        --结束原因
        GER_NO_PLAYER               =100000,                                    --没有玩家

        SEND_PELS = 0.8 ,-- 发牌速度

        --游戏状态
        GS_TK_FREE                  = 1,                       --等待开始
        GS_TK_CALL                  =2,                     --叫庄状态
        GS_TK_SCORE                 =3,                     --下注状态
        GS_TK_PLAYING               =4,                     --游戏进行

        --用户状态
        USEX_NULL                   =0,                                       --用户状态
        USEX_PLAYING                =1,                                       --用户状态
        USEX_DYNAMIC                =2,                                       --用户状态
        --区域索引
        ID_SHUN_MEN                 =1                                   ,--顺门
        ID_JIAO_L                   =2                                   ,--左边角
        ID_QIAO                     =3                                   ,--桥
        ID_DUI_MEN                  =4                                   ,--对门
        ID_DAO_MEN                  =5                                   ,--倒门
        ID_JIAO_R                   =6                                   ,--右边角
        --常量定义
        INVALID_ITEM                =0,                             --无效子项


        SUB_S_CALL_OTH               =1000,                                   --其他用户叫庄
        SUB_S_CALL_unChange             = 1001,                               --请选择你要的卡牌

        --------------------------------------------------------------------------
        --服务器命令结构
        GS_TK_FREE = 0 ,    --空闲状态
        GS_TK_CALL = 100    ,--游戏状态
        GS_TK_SCORE               = 101,                      --下注状态
        GS_TK_PLAYING             = 102 ,                     --游戏进行

        SUB_S_GAME_FREE                 =99,                                   --游戏空闲
        SUB_S_GAME_START                =100,                                   --游戏开始
        SUB_S_PLACE_JETTON              =101,                                   --用户下注
        SUB_S_GAME_END                  =102,                                   --游戏结束
        SUB_S_APPLY_BANKER              =103,                                   --申请庄家
        SUB_S_CHANGE_BANKER             =104,                                   --切换庄家
        SUB_S_CHANGE_USER_SCORE         =105,                                   --更新积分
        SUB_S_SEND_RECORD               =106,                                   --游戏记录
        SUB_S_PLACE_JETTON_FAIL         =107,                                   --下注失败
        SUB_S_CANCEL_BANKER             =108,                                 --取消申请
        SUB_S_CHEAT                     =109,                                 --作弊信息 
        SUB_S_AMDIN_COMMAND             =110,                                 --管理员命令
        SUB_S_QIANG_ZHUAN               =111,                              --抢庄

        GAME_GAME_FREE                 = "REDNINE_GAME_FREE",             -- 场景的消息
        GAME_START                  = "REDNINE_START",             -- 游戏开始
        GAME_PLACE_JETTON               = "REDNINE_PLACE_JETTON",              -- 加注结果
        GAME_GAME_END            = "REDNINE_GAME_END",              -- 游戏结束
        GAME_APPLY_BANKER           = "REDNINE_APPLY_BANKER",         -- 申请庄家
        GAME_CHANGE_BANKER          = "REDNINE_CHANGE_BANKER",         -- 切换庄家
        GAME_SEND_RECORD                 = "REDNINE_SEND_RECORD",         -- 更新积分
        GAME_PLACE_JETTON_FAIL           = "REDNINE_PLACE_JETTON_FAIL",         -- 下注失败
        GAME_CANCEL_BANKER           = "REDNINE_CANCEL_BANKER",         -- 取消申请
        GAME_CHEAT              = "REDNINE_CHEAT", --作弊信息
        GAME_AMDIN_COMMAND                  = "REDNINE_AMDIN_COMMAND",   -- 作弊信息
        GAME_QIANG_ZHUAN                  = "REDNINE_QIANG_ZHUAN ",   --抢庄

        TIME_INTERVAL       =1,                                  --时间间隔
        TIME_USER_CALL_BANKER       =10,                                  --叫庄定时器

        --客户端命令结构
        SUB_C_PLACE_JETTON              =1,                                 --用户叫庄
        SUB_C_APPLY_BANKER                  =2,                                 --申请庄家
        SUB_C_CANCEL_BANKER                 =3,                                 --取消申请
        SUB_C_CONTINUE_CARD                     =4,                                 --继续发牌
        SUB_C_AMDIN_COMMAND               =5,                                   --管理员命令
        SUB_S_GET_ACCOUNT                 =6,                                  --获取昵称
        SUB_S_CHEAK_ACCOUNT                 =7,                                  --获取昵称
        SUB_S_SCORE_RESULT                 =8,                                  --积分结果
        SUB_S_ACCOUNT_RESULT                 =9,                                  --帐号结果
        SUB_C_QIANG_ZHUAN                 =10,                                  --抢庄

        mp3 = 1,
        m4a = 2,
        wav = 3,

    }