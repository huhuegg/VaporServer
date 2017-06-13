//
//  WS+Private.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/15.
//
//

import Vapor

extension WS {
    func isClientExist(_ socket:WebSocket, callback:@escaping (_ clientInfo:ClientInfo?)->()) {
        q.async {
            self.clientInfo(socket, callback: { (clientInfo) in
                callback(clientInfo)
            })
        }
    }
    
    func addClientIfNeed(_  socket:WebSocket, callback:@escaping (_ isSuccess:Bool)->()) {
        isClientExist(socket) { (clientInfo) in
            if let _ = clientInfo?.userInfo {
//                self.updateClientInfo(socket, callback: { (isSuccess) in
//                    callback(isSuccess)
//                })
                callback(true)
            } else {
                self.addClient(socket, callback: { (isSuccess) in
                    callback(isSuccess)
                })
            }
        }
    }
    
    func removeClient(_ socket:WebSocket, callback:@escaping (_ isSuccess:Bool)->()) {
        let address:Int = socketMemoryAddress(socket)
        if let u = clients[address]?.userInfo {
            print("delClient:\(address) userSid:\(u.userSid)")
            q.async {
                if let _ = self.clients.removeValue(forKey: address) {
                    callback(true)
                } else {
                    callback(false)
                }
                self.userRoom(u.userSid, callback: { (room) in
                    if let roomSid = room?.sid {
                        self.leaveRoom(socket, roomSid: roomSid, callback: { (status) in

                        })
                    }
                })
                
            }
        }

    }
    
    func clientInfo(_ socket:WebSocket, callback:@escaping (_ clientInfo:ClientInfo?)->()) {
        q.async {
            let address:Int = self.socketMemoryAddress(socket)
            if let clientInfo = self.clients[address] {
                callback(clientInfo)
            } else {
                callback(nil)
            }
        }
        
    }
    
    func userOwnerSocket(_ userSid:String, callback:@escaping (_ socket:WebSocket?)->()) {
        q.async {
            for address in self.clients.keys {
                if let userInfo = self.clients[address]?.userInfo {
                    if userInfo.userSid == userSid {
                        if let socket = self.clients[address]?.socket {
                            callback(socket)
                            return
                        } else {
                            self.printLog("Socket not found!")
                        }
                    }
                }
            }
            callback(nil)
        }
    }
    
    func socketUserSid(_ socket:WebSocket, callback:@escaping (_ userSid:String?)->()){
        clientInfo(socket) { (clientInfo) in
            callback(clientInfo?.userInfo?.userSid)
        }
    }
    
    func updateUserInfo(_ socket:WebSocket, userInfo:UserInfo, deviceToken:String?, callback:@escaping (_ isSuccess:Bool)->()) {
        
        clientInfo(socket) { (clientInfo) in
            if let _ = clientInfo {
                self.q.async {
                    self.printLog("updateUserInfo success")
                    clientInfo?.userInfo = userInfo
//                    WS.instance.redisUpdateUserInfo(userInfo: userInfo, deviceToken: deviceToken, callback: { (status) in
//                        self.printLog("update redis userInfo -> userSid:\(userInfo.userSid) status:\(status)")
//                    })
                    callback(true)
                }
            } else {
                self.printLog("updateUserInfo failed")
                callback(false)
            }
        }
    }
}

extension WS {
    
    
    fileprivate func addClient(_ socket:WebSocket, callback:@escaping (_ isSuccess:Bool)->()) {
        let address:Int = socketMemoryAddress(socket)
        let clientInfo = ClientInfo()
        clientInfo.socket = socket
        
        print("addClient:\(address)")
        q.async {
            self.clients[address] = clientInfo
            callback(true)
        }
    }
    
//    fileprivate func updateClientInfo(_ socket:WebSocket, callback:@escaping (_ isSuccess:Bool)->()) {
//        clientInfo(socket) { (clientInfo) in
//            if let client = clientInfo {
//                self.q.async {
//                    
//                    callback(true)
//                }
//            } else {
//                callback(false)
//            }
//        }
//    }
    
    func socketMemoryAddress(_ socket:WebSocket) -> Int {
        return unsafeBitCast(socket, to: Int.self)
    }
}
