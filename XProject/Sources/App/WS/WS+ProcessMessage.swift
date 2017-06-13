//
//  WebSocketClients+ProcessMessage.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/15.
//
//

import Vapor

enum WSCustomCommandType:Int {
    case onlyResp                       = 0
    case respAndPushToRoomStudents      = 1
    case respAndPushToRoomOtherUsers    = 2
    case respAndPushToAllRoomUsers      = 3
    case respAndPushToCustomUser        = 4
    case respAndPushToRoomTeacher       = 5
}

let kWebsocketCommandName = "cmd"
let kWebsocketDataName = "data"
let kWebsocketCodeName = "code"
let kWebsocketMsgName = "msg"

extension WS {
    func processRequestMessage(_ socket:WebSocket, text:String) {
        guard let d = text.toDict() else {
            return
        }
        
    
        guard let cmd = d[kWebsocketCommandName] as? String, let data = d[kWebsocketDataName] as? Dictionary<String,Any>  else {
            print("data error: \(text)")
            return
        }
        print("cmd:\(cmd)")
        guard let command = WebSocketCommand(rawValue: Int(cmd)!) else {
            print("<---Client(\(self.socketMemoryAddress(socket))):command\(cmd) not found, skip!")
            return
        }
        print("<---Client(\(self.socketMemoryAddress(socket)))# command:\(cmd) data:\(data)")

        
        
        switch command {
        case .reqCustom:
            reqCustom(socket, cmd: command, data: data)
        case .reqDeviceAdmin:
            reqDeviceAdmin(socket,  cmd:command, data: data)
        case . reqUserAnswerQuestion:
            reqUserAnswerQuestion(socket,  cmd:command, data: data)
        case .reqUserStatusChange:
            reqUserStatusChange(socket,  cmd:command, data: data)
        case .reqCoursewareOpen:
            reqCoursewareOpen(socket,  cmd:command, data: data)
        case .reqCoursewareClose:
            reqCoursewareClose(socket,  cmd:command, data: data)
        case .reqCoursewareSizeChange:
            reqCoursewareSizeChange(socket,  cmd:command, data: data)
        case .reqMessagewSend:
            reqMessagewSend(socket,  cmd:command, data: data)
        case .reqQuestionCreate:
            reqQuestionCreate(socket,  cmd:command, data: data)
        case .reqSpecifyStudentAnswerQuestion:
            reqSpecifyStudentAnswerQuestion(socket,  cmd:command, data: data)
        case .reqAnswerCheck:
            reqAnswerCheck(socket,  cmd:command, data: data)
        case .reqAnswerSubmit:
            reqAnswerSubmit(socket,  cmd:command, data: data)
        case .reqCreditChange:
            reqCreditChange(socket,  cmd:command, data: data)
        case .reqPlayMediaSynchronously:
            reqPlayMediaSynchronously(socket,  cmd:command, data: data)
        case .reqMediaReady:
            reqMediaReady(socket,  cmd:command, data: data)
        case .reqMediaControl:
            reqMediaControl(socket,  cmd:command, data: data)
        case .reqMediaControlStatus:
            reqMediaControlStatus(socket,  cmd:command, data: data)
        case .reqDocumentOpenClose:
            reqDocumentOpenClose(socket,  cmd:command, data: data)
        case .reqDocumentOpenCloseStatus:
            reqDocumentOpenCloseStatus(socket, cmd: command, data: data)
        case .reqDocumentControl:
            reqDocumentControl(socket,  cmd:command, data: data)
        case .reqDocumentControlStatus:
            reqDocumentControlStatus(socket,  cmd:command, data: data)
        case .reqRoomJoin:
            reqRoomJoin(socket, cmd: command, data: data)
        case .reqRoomLeave:
            reqRoomLeave(socket, cmd: command, data: data)
        case .reqRoomStart:
            reqRoomStart(socket, cmd: command, data: data)
        case .reqRoomEnd:
            reqRoomEnd(socket, cmd: command, data: data)
        default:
            print("command:\(command) error")
        }

    }
    
    private func reqCustom(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "customCommand":.string, "type":.int, "uid":.string, "json":.string])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        let type = data?["type"] as! Int
        let userSid = data?["uid"] as! String
        guard let cmdType = WSCustomCommandType(rawValue: type) else {
            printLog("unknown command type:\(type)")
            sendMsg(socket, command: respCmd, code: false, msg: "type error", data: data)
            return
        }
        
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        switch cmdType {
        case .onlyResp:
            break
        case .respAndPushToRoomStudents:
            sendMsgToRoomStudents(socket, command: pushCmd, roomSid: roomSid, data: data)
            break
        case .respAndPushToRoomOtherUsers:
            sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: roomSid, data: data)
            break
        case .respAndPushToAllRoomUsers:
            sendMsgToRoomUsers(socket, command: pushCmd, roomSid: roomSid, data: data)
            break
        case .respAndPushToCustomUser:
            sendMsgToUser(userSid, command: pushCmd, data: data, callback: { (_) in
            })
            break
        case .respAndPushToRoomTeacher:
            sendMsgToRoomTeacher(socket, command: pushCmd, roomSid: roomSid, data: data)
        default:
            break
        }
        
    }
    
    private func reqDeviceAdmin(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }

        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "uid":.string, "deviceId":.int, "open":.bool])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: roomSid, data: data)
    }
    
    private func reqUserAnswerQuestion(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "uid":.string, "type":.int])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: roomSid, data: data)

    }
    
    private func reqUserStatusChange(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        let status = DataTypeCheck.dataCheck(data, types: ["sessionId":.string, "uid":.string, "nickname":.string, "avatar":.string, "online":.bool])
        //let status = DataTypeCheck.dataCheck(data, types: ["uid":.string, "online":.bool])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        
        guard let userInfo = UserInfo.fromDict(data) else {
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let deviceToken:String? = data?["deviceToken"] as? String
        updateUserInfo(socket, userInfo: userInfo, deviceToken: deviceToken) { (isSuccess) in
            self.sendMsg(socket, command: respCmd, code: isSuccess, msg: "", data: data)
        }
        
        userRoom(userInfo.userSid) { (room) in
            if let r = room {
                var d = data
                d?.removeValue(forKey: "deviceToken")
                self.sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: r.sid, data: d)
            }
        }

    }
    
    private func reqCoursewareOpen(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "url":.string])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: roomSid, data: data)
    }
    
    private func reqCoursewareClose(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: roomSid, data: data)
    }
    
    private func reqCoursewareSizeChange(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "type":.int])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: roomSid, data: data)

    }
    
    private func reqMessagewSend(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "message":.string])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String

        socketUserSid(socket) { (sendUserSid) in
            if let s = sendUserSid {
                self.sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
                
                var pushData:[String:Any]? = data
                pushData?["uid"] = s
                
                self.sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: roomSid, data: pushData)
            } else {
                self.sendMsg(socket, command: respCmd, code: false, msg: "send user not online", data: data)
            }
        }
    }
    
    private func reqQuestionCreate(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "questionId":.string])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: data)
    }
    
    private func reqSpecifyStudentAnswerQuestion(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "questionId":.string, "uidArr":.arrayString])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: data)
    }
    
    private func reqAnswerCheck(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "uid":.string, "result":.bool])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
    
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: data)

    }
    
    private func reqAnswerSubmit(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "questionId":.string, "answerArr":.arrayString])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String

        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: data)
    }
    
    private func reqCreditChange(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "uid":.string, "type":.int, "count":.int])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: data)
    }
    
    private func reqPlayMediaSynchronously(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "type":.int, "url":.string])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String

        socketUserSid(socket) { (userSid) in
            if let sid = userSid {
                self.sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
                var pushData:[String:Any]? = data
                pushData?["uid"] = sid
                self.sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: pushData)
            } else {
                self.sendMsg(socket, command: respCmd, code: false, msg: "", data: data)
            }
        }
    }
    
    private func reqMediaReady(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "mediaId":.string, "type":.int, "status":.bool])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: data)
        
    }
    
    private func reqMediaControl(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "mediaId":.string, "type":.int, "status":.bool])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: data)

    }
    
    private func reqMediaControlStatus(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "mediaId":.string, "type":.int, "status":.bool])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String

        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: data)
    }
    
    private func reqDocumentOpenClose(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "documentId":.string, "type":.bool, "url":.string])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: data)
    }
    
    private func reqDocumentOpenCloseStatus(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "documentId":.string, "status":.int])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String

        socketUserSid(socket) { (userSid) in
            if let sid = userSid {
                self.sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
                var pushData:[String:Any]? = data
                pushData?["uid"] = sid
                self.sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: pushData)
            } else {
                self.sendMsg(socket, command: respCmd, code: false, msg: "", data: data)
            }
        }
    }
    
    private func reqDocumentControl(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "documentId":.string, "control":.dictStringAny])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: data)
    }
    
    private func reqDocumentControlStatus(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "coursewareId":.string, "documentId":.string, "control":.dictStringAny])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String

        socketUserSid(socket) { (userSid) in
            if let sid = userSid {
                self.sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
                var pushData:[String:Any]? = data
                pushData?["uid"] = sid
                self.sendMsgToRoomOtherUsers(socket , command: pushCmd, roomSid: roomSid, data: pushData)
            } else {
                self.sendMsg(socket, command: respCmd, code: false, msg: "", data: data)
            }
        }
    }
    
    private func reqRoomJoin(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string, "roleId":.int])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        let roleId = data?["roleId"] as! Int
        
        isClientExist(socket) { (clientInfo) in
            if let u = clientInfo?.userInfo {
                self.joinRoom(socket, roomSid: roomSid, roleId: roleId, callback: { (room) in
                    if let r = room {
                        var users:Array<Dictionary<String,Any>> = Array()
                        for user in r.userList {
                            users.append(user.toDict())
                        }
                        var respData = data
                        respData?["users"] = users
                        self.printLog("#####################################")
                        self.printLog("userNum:\(users.count) users:\(users)")
                        self.printLog("#####################################")
                        self.sendMsg(socket, command: respCmd, code: true, msg: "", data: respData)
                        
                        var pushData:[String:Any] = [:]
                        pushData["courseId"] = roomSid
                        pushData["uid"] = u.userSid
                        pushData["roleId"] = roleId
                        pushData["nickname"] = u.nickName
                        pushData["avatar"] = u.avatarUrl
                        
                        self.sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: r.sid, data: pushData)
                    } else {
                        self.sendMsg(socket, command: respCmd, code: false, msg: "joinRoom failed", data: data)
                    }
                })
            } else {
                self.sendMsg(socket, command: respCmd, code: false, msg: "", data: data)
            }
        }
        
        socketUserSid(socket) { (userSid) in
            
            if let _ = userSid {
            } else {
                self.sendMsg(socket, command: respCmd, code: false, msg: "", data: data)
            }
        }

    }
    
    private func reqRoomLeave(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        
        isClientExist(socket, callback: { (clientInfo) in
            if let u = clientInfo?.userInfo {
                self.leaveRoom(socket, roomSid: roomSid) { (isSuccess) in
                    let msg = isSuccess ? "":"completeWithError"
                    self.sendMsg(socket, command: respCmd, code: true, msg: msg, data: data)
                    
                    var pushData = data
                    pushData?["uid"] = u.userSid
                    self.sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: roomSid, data: pushData)
                }
            } else {
                self.sendMsg(socket, command: respCmd, code: false, msg: "clientInfo not found", data: data)
            }
        })

    }
    
    private func reqRoomStart(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        
        sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: roomSid, data: data)
    }

    
    private func reqRoomEnd(_ socket: WebSocket, cmd:WebSocketCommand, data:[String:Any]?) {
        guard let respCmd = commandFor(cmd, isResp: true), let pushCmd = commandFor(cmd, isResp: false) else {
            printLog("reqCmd:\(cmd.rawValue) resp/push command not found! ")
            return
        }
        
        let status = DataTypeCheck.dataCheck(data, types: ["courseId":.string])
        if !status {
            printLog("data error! data:\(String(describing: data))")
            sendMsg(socket, command: respCmd, code: false, msg: "data error!", data: data)
            return
        }
        let roomSid = data?["courseId"] as! String
        
        sendMsg(socket, command: respCmd, code: true, msg: "", data: data)
        
        sendMsgToRoomOtherUsers(socket, command: pushCmd, roomSid: roomSid, data: data)

    }
}

extension WS {
    fileprivate func sendMsgToRoomUsers(_ socket:WebSocket, command:WebSocketCommand, roomSid:String, data:[String:Any]?) {
        roomUsers(socket, roomSid: roomSid) { (userList) in
            for u in userList {
                self.sendMsgToUser(u.userSid, command: command, data: data, callback: { (isSuccess) in
                    //self.printLog("sendMsgToUser:\(u.userSid) command:\(command) status:\(isSuccess)")
                })
            }
        }
    }
    
    fileprivate func sendMsgToRoomTeacher(_ socket:WebSocket, command:WebSocketCommand, roomSid:String, data:[String:Any]?) {
        roomUsers(socket, roomSid: roomSid) { (userList) in
            for u in userList {
                if u.role == 1 {
                    self.sendMsgToUser(u.userSid, command: command, data: data, callback: { (isSuccess) in
                        //self.printLog("sendMsgToUser:\(u.userSid) command:\(command) status:\(isSuccess)")
                    })
                }
            }
        }
    }
    
    fileprivate func sendMsgToRoomStudents(_ socket:WebSocket, command:WebSocketCommand, roomSid:String, data:[String:Any]?) {
        roomUsers(socket, roomSid: roomSid) { (userList) in
            for u in userList {
                if u.role == 3 {
                    self.sendMsgToUser(u.userSid, command: command, data: data, callback: { (isSuccess) in
                        //self.printLog("sendMsgToUser:\(u.userSid) command:\(command) status:\(isSuccess)")
                    })
                }
            }
        }
    }
    
    fileprivate func sendMsgToRoomOtherUsers(_ socket:WebSocket, command:WebSocketCommand, roomSid:String, data:[String:Any]?) {
        roomOtherUsers(socket, roomSid: roomSid) { (userList) in
            self.isClientExist(socket, callback: { (clientInfo) in
                if let ownerUserInfo = clientInfo?.userInfo {
                    for u in userList {
                        if u.userSid != ownerUserInfo.userSid {
                            self.sendMsgToUser(u.userSid, command: command, data: data, callback: { (isSuccess) in
                                self.printLog("sendMsgToUser:\(u.userSid) command:\(command) status:\(isSuccess)")
                            })
                        }
                    }
                }
            })
            
        }
    }
    
    fileprivate func sendMsgToUser(_ userSid:String, command:WebSocketCommand, data:[String:Any]?, callback:@escaping (_ isSuccess:Bool)->()) {
        self.userOwnerSocket(userSid, callback: { (userSocket) in
            if let _ = userSocket {
                self.sendMsg(userSocket!, command: command, code: true, msg: "", data: data)
                callback(true)
            } else {
                callback(false)
            }
        })
    }

    fileprivate func sendMsg(_ socket: WebSocket, command:WebSocketCommand, code:Bool, msg:String, data:[String:Any]?) {
        var dict:[String:Any] = [:]
        dict[kWebsocketCommandName] = command.rawValue
        dict[kWebsocketCodeName] = code ? 0:1
        dict[kWebsocketMsgName] = msg
        dict[kWebsocketDataName] = data
        
        guard let jsonStr = dict.toJson() else {
            print("dict to str failed")
            return
        }
        
        do {
            print("--->Client(\(self.socketMemoryAddress(socket)))#(\(command)) \(jsonStr)")
            try socket.send(jsonStr)
        } catch  {
            print("sendMsg failed")
        }
        
        
    }
    
    fileprivate func commandFor(_ reqCmd:WebSocketCommand, isResp:Bool) -> WebSocketCommand? {
        switch reqCmd {
        case .reqCustom:
            if isResp {
                return .respCustom
            }
            return .pushCustom
        case .reqDeviceAdmin:
            if isResp {
                return .respDeviceAdmin
            }
            return .pushDeviceAdmin
        case . reqUserAnswerQuestion:
            if isResp {
                return .respUserAnswerQuestion
            }
            return .pushUserAnswerQuestion
        case .reqUserStatusChange:
            if isResp {
                return .respUserStatusChange
            }
            return .pushUserStatusChange
        case .reqCoursewareOpen:
            if isResp {
                return .respCoursewareOpen
            }
            return .pushCoursewareOpen
        case .reqCoursewareClose:
            if isResp {
                return .respCoursewareClose
            }
            return .pushCoursewareClose
        case .reqCoursewareSizeChange:
            if isResp {
                return .respCoursewareSizeChange
            }
            return .pushCoursewareSizeChange
        case .reqMessagewSend:
            if isResp {
                return .respMessageSend
            }
            return .pushMessageSend
        case .reqQuestionCreate:
            if isResp {
                return .respQuestionCreate
            }
            return .pushQuestionCreate
        case .reqSpecifyStudentAnswerQuestion:
            if isResp {
                return .respSpecifyStudentAnswerQuestion
            }
            return .pushSpecifyStudentAnswerQuestion
        case .reqAnswerCheck:
            if isResp {
                return .respAnswerCheck
            }
            return .pushAnswerCheck
        case .reqAnswerSubmit:
            if isResp {
                return .respAnswerSubmit
            }
            return .pushAnswerSubmit
        case .reqCreditChange:
            if isResp {
                return .respCreditChange
            }
            return .pushCreditChange
        case .reqPlayMediaSynchronously:
            if isResp {
                return .respPlayMediaSynchronously
            }
            return .pushPlayMediaSynchronously
        case .reqMediaReady:
            if isResp {
                return .respMediaReady
            }
            return .pushMediaReady
        case .reqMediaControl:
            if isResp {
                return .respMediaControl
            }
            return .pushMediaControl
        case .reqMediaControlStatus:
            if isResp {
                return .respMediaControlStatus
            }
            return .pushMediaControlStatus
        case .reqDocumentOpenClose:
            if isResp {
                return .respDocumentOpenClose
            }
            return .pushDocumentOpenClose
        case .reqDocumentOpenCloseStatus:
            if isResp {
                return .respDocumentOpenCloseStatus
            }
            return .pushDocumentOpenCloseStatus
        case .reqDocumentControl:
            if isResp {
                return .respDocumentControl
            }
            return .pushDocumentControl
        case .reqDocumentControlStatus:
            if isResp {
                return .respDocumentControlStatus
            }
            return .pushDocumentControlStatus
        case .reqRoomJoin:
            if isResp {
                return .respRoomJoin
            }
            return .pushRoomJoin
        case .reqRoomLeave:
            if isResp {
                return .respRoomLeave
            }
            return .pushRoomLeave
        case .reqRoomStart:
            if isResp {
                return .respRoomStart
            }
            return .pushRoomStart
        case .reqRoomEnd:
            if isResp {
                return .respRoomEnd
            }
            return .pushRoomEnd
        default:
            return nil
        }
    }

}
