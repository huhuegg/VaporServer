//
//  WebSocketCommand.swift
//  X
//
//  Created by huhuegg on 2017/5/2.
//  Copyright © 2017年 jiangchao. All rights reserved.
//

enum WebSocketCommand: Int {
    case test                       = 0
    case reqCustom                  = 1000
    case respCustom                 = 2000
    case pushCustom                 = 3000
    case reqDeviceAdmin             = 1001
    case respDeviceAdmin            = 2001
    case pushDeviceAdmin            = 3001
    case reqUserAnswerQuestion      = 1002
    case respUserAnswerQuestion     = 2002
    case pushUserAnswerQuestion     = 3002
    case reqUserStatusChange        = 1003
    case respUserStatusChange       = 2003
    case pushUserStatusChange       = 3003
    case reqCoursewareOpen          = 1004
    case respCoursewareOpen         = 2004
    case pushCoursewareOpen         = 3004
    case reqCoursewareClose         = 1005
    case respCoursewareClose        = 2005
    case pushCoursewareClose        = 3005
    case reqCoursewareSizeChange    = 1006
    case respCoursewareSizeChange   = 2006
    case pushCoursewareSizeChange   = 3006
    case reqMessagewSend            = 1007
    case respMessageSend            = 2007
    case pushMessageSend            = 3007
    case reqQuestionCreate          = 1008
    case respQuestionCreate         = 2008
    case pushQuestionCreate         = 3008
    case reqSpecifyStudentAnswerQuestion    = 1009
    case respSpecifyStudentAnswerQuestion   = 2009
    case pushSpecifyStudentAnswerQuestion   = 3009
    case reqAnswerSubmit            = 1010
    case respAnswerSubmit           = 2010
    case pushAnswerSubmit           = 3010
    case reqAnswerCheck             = 1011
    case respAnswerCheck            = 2011
    case pushAnswerCheck            = 3011
    case reqCreditChange            = 1012
    case respCreditChange           = 2012
    case pushCreditChange           = 3012
    case reqPlayMediaSynchronously  = 1013
    case respPlayMediaSynchronously = 2013
    case pushPlayMediaSynchronously = 3013
    case reqMediaReady              = 1014
    case respMediaReady             = 2014
    case pushMediaReady             = 3014
    case reqMediaControl            = 1015
    case respMediaControl           = 2015
    case pushMediaControl           = 3015
    case reqMediaControlStatus      = 1016
    case respMediaControlStatus     = 2016
    case pushMediaControlStatus     = 3016
    case reqDocumentOpenClose       = 1017
    case respDocumentOpenClose      = 2017
    case pushDocumentOpenClose      = 3017
    case reqDocumentOpenCloseStatus = 1018
    case respDocumentOpenCloseStatus = 2018
    case pushDocumentOpenCloseStatus = 3018
    case reqDocumentControl         = 1019
    case respDocumentControl        = 2019
    case pushDocumentControl        = 3019
    case reqDocumentControlStatus   = 1020
    case respDocumentControlStatus  = 2020
    case pushDocumentControlStatus  = 3020
    case reqRoomJoin                = 1021
    case respRoomJoin               = 2021
    case pushRoomJoin               = 3021
    case reqRoomLeave               = 1022
    case respRoomLeave              = 2022
    case pushRoomLeave              = 3022
    case reqRoomStart               = 1023
    case respRoomStart              = 2023
    case pushRoomStart              = 3023
    case reqRoomEnd                 = 1024
    case respRoomEnd                = 2024
    case pushRoomEnd                = 3024
    case pushKickOff                = 3025
}


