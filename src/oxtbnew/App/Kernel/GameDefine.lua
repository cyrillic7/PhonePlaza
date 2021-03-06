

OxtbNewDefine=
    {
        KIND_ID						=130,									--游戏 I D
        GAME_PLAYER					=6,										--游戏人数
        GAME_NAME					="通比牛牛",  						--游戏名字
        VERSION_SERVER				=8,										--程序版本
        VERSION_CLIENT				=8,										--程序版本
        MYSELF_VIEW_ID              =4,
        GAME_GENRE					="gold",								--游戏类型
        MAXCOUNT					=5,										--扑克数目

        --结束原因
        GER_NO_PLAYER				=100000,									--没有玩家

        --游戏状态
        GS_TK_FREE					= 1,                       --等待开始
        GS_TK_CALL					=2,						--叫庄状态
        GS_TK_SCORE					=3,						--下注状态
        GS_TK_PLAYING				=4,						--游戏进行

        --用户状态
        USEX_NULL                   =0,                                       --用户状态
        USEX_PLAYING                =1,                                       --用户状态
        USEX_DYNAMIC                =2,                                       --用户状态

        --牌背定义
        CARD_LAND					=0,									--地主底面
        CARD_BOOR					=1,									--农民底面

        --常量定义
        INVALID_ITEM				=0,								--无效子项

        --属性定义
        MAX_CARD_COUNT				=20,									--扑克数目
        SPACE_CARD_DATA				=255,									--间距扑克

        --数值掩码
        CARD_MASK_COLOR				=0,								--花色掩码
        CARD_MASK_VALUE				=1,								--数值掩码
        --间距定义
        DEF_X_DISTANCE				=22	,								--默认间距
        DEF_Y_DISTANCE				=18,									--默认间距
        DEF_SHOOT_DISTANCE			=20,									--默认间距

        --间距定义
        DEF_X_DISTANCE_SMALL		=16,									--默认间距
        DEF_Y_DISTANCE_SMALL		=17,									--默认间距
        DEF_SHOOT_DISTANCE_SMALL	=20,									--默认间距
        IDM_OUT_CARD_FINISH 		=22,									--出牌完成
        --------------------------------------------------------------------------
        --服务器命令结构
        GS_TK_FREE = 0 ,	--空闲状态
        GS_TK_CALL = 100	,--游戏状态
        GS_TK_SCORE               = 101,                      --下注状态
        GS_TK_PLAYING             = 102 ,                     --游戏进行


        SUB_S_GAME_START				=100,									--游戏开始
        SUB_S_ADD_SCORE					=101,									--加注结果
        SUB_S_PLAYER_EXIT				=102,									--用户强退
        SUB_S_SEND_CARD					=103,									--发牌消息
        SUB_S_GAME_END					=104,									--游戏结束
        SUB_S_OPEN_CARD					=105,									--用户摊牌
        SUB_S_CALL_BANKER				=106,									--用户叫庄
        SUB_S_GAME_BASE					=107,									--发送基数
--        SUB_S_CHANGE_CARD               =108,                                 --用户换牌
--        SUB_S_CHANGE_OPEN               =109,                                 --开牌
        SUB_S_USER_OPEN                 =108,                                 --所有用户开完牌
        SUB_S_HANDSEL                   =109,                                 --彩金池
        SUB_S_MY_HANDSEL                =110,                                 --自己累计的彩金
        SUB_S_HANDSEL_LIST              =111,                                 --10人彩金

        GAME_SCENCE                 = "OxbtNew_SCENEME",             -- 场景的消息
        GAME_START                  = "OxbtNew_STARTME",             -- 游戏开始
        GAME_ADD_SCORE         		= "OxbtNew_ADD_SCORE",              -- 加注结果
        GAME_PLAYER_EXIT            = "OxbtNew_PLAYER_EXIT",              -- 玩家退出
        GAME_SEND_CARD           = "OxbtNew_SEND_CARD",         -- 发牌消息
        GAME_CALL_BANKER          = "OxbtNew_CALL_BANKER",         -- 用户叫庄
        GAME_BASE   				 = "OxbtNew_BASE",         -- 发送基数
        GAME_CARD			 = "OxbtNew_CARD",         -- 用户换牌
        GAME_OPEN     		 = "OxbtNew_OPEN",         -- 开牌
        GAME_OPEN_CARD              = "OxbtNew_OPEN_CARD", --
        GAME_OVER 					= "OxbtNew_GAMEOVER",	 -- 结束
        GAME_PLAYER_OPEN                  = "OxbtNew_PLAYER_OPEN ",   --所有玩家卡牌数据
        GAME_HANDSEL                    ="OxbtNew_HANDSEL", --彩金
        GAME_MY_HANDSEL                 ="OxbtNew_MY_HANDSEL", --我的彩金
        GAME_HANDSEL_LIST               ="OxbtNew_HANDSEL_LIST",

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
        SUB_C_CALL_BANKER				=1,									--用户叫庄
        SUB_C_ADD_SCORE					=2,									--用户加注
        SUB_C_OPEN_CARD					=3,									--用户摊牌
        SUB_C_LEAVE						=4,									--机器人离开
        --SUB_C_CHANGE_CARD               =5,                                   --用户换牌
        SUB_C_OPEN_END                 =5,                                  --


        mp3 = 1,
        m4a = 2,
        wav = 3,

        animStartAddSource = 0,
        animWhiteCloud = 1,
        animRedCloud = 2,
        animHead = 3,
    }