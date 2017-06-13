//
//  WS+MessageManage.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/15.
//
//

import Vapor

extension WS {
    func loadFromRedis() {
        
    }
    
    func findRoomIfExist(_ roomSid:String, callback:@escaping (_ room:Room?)->()) {
        q.async {
            if let room = self.rooms[roomSid] {
                callback(room)
            } else {
                callback(nil)
            }
        }
    }
    
    func joinRoom(_ socket:WebSocket, roomSid:String, roleId:Int, callback:@escaping (_ room:Room?)->()) {
        isClientExist(socket) { (clientInfo) in
            if let u = clientInfo?.userInfo {
                self.q.async {
                    self.userInRoom[u.userSid] = roomSid
                    self.findRoomIfExist(roomSid, callback: { (room) in
                        self.q.async {
                            if let existRoom = room {
                                var isUserInRoom:Bool = false
                                for (idx,_) in existRoom.userList.enumerated() {
                                    if existRoom.userList[idx].userSid == u.userSid {
                                        existRoom.userList[idx].role = roleId
                                        isUserInRoom = true
                                        self.printLog("updateUser:\(u.userSid) role:\(roleId) in room:\(roomSid)")
                                        break
                                    }
                                }
                                
                                if !isUserInRoom {
                                    let userInfo = u
                                    userInfo.role = roleId
                                    self.printLog("addUser:\(userInfo.userSid) role:\(roleId) into Room:\(roomSid)")
                                    existRoom.userList.append(userInfo)
//                                    self.redisSetUserRoomSid(userInfo.userSid, roomSid: roomSid, callback: { (setUserRoomStatus) in
//                                    })
//                                    self.redisAddUserToRoom(roomSid, userSid: userInfo.userSid, callback: { (addUserStatus) in
//                                        
//                                    })
                                }
                                callback(existRoom)
                                
                            } else {
                                self.q.async {
                                    let newRoom = Room()
                                    newRoom.sid = roomSid
                                    let userInfo = u
                                    userInfo.role = roleId
                                    newRoom.userList.append(userInfo)
                                    self.rooms[roomSid] = newRoom
                                    callback(newRoom)
                                    self.printLog("create new room:\(roomSid) with user:\(userInfo.userSid)")
                                    self.printLog("after createRoom, rooms count:\(self.rooms.keys.count)")
//                                    self.redisCreateRoomAndAddUser(roomSid, userSid: userInfo.userSid, callback: { (status) in
//                                        self.printLog("redisCreateRoom \(status)")
//                                    })
//                                    self.redisSetUserRoomSid(userInfo.userSid, roomSid: roomSid, callback: { (setUserRoomStatus) in
//                                    })
                                }
                            }

                        }
                    })
                }
            } else {
                callback(nil)
            }
        }
    }
    
    func leaveRoom(_ socket:WebSocket, roomSid:String, callback:@escaping (_ isSuccess:Bool)->()) {
        isClientExist(socket) { (clientInfo) in
            if let c = clientInfo {
                if let u = c.userInfo {
                    self.removeUserFormRoomIfExist(roomSid, userSid: u.userSid) { (isSuccess) in
                        if isSuccess {
                            self.q.async {
                                if let _ = self.userInRoom.removeValue(forKey: u.userSid) {
                                    self.printLog("remove user:\(u.userSid) from room:\(roomSid) success!")
                                    callback(true)
                                } else {
                                    callback(false)
                                }
//                                self.redisRemoveUserFromRoom(roomSid, userSid: u.userSid, callback: { (status) in
//                                    self.printLog("redisRemoveUser \(status)")
//                                })
//                                self.redisRemoveUserRoomSid(u.userSid, callback: { (removeUserRoomSidStatus) in
//                                    
//                                })
                            }
                        } else {
                            self.printLog("removeUserFromRoom failed")
                            callback(false)
                        }
                    }
                } else {
                    callback(false)
                }
            } else {
                callback(false)
            }
        }

    }

    func userRoom(_ userSid:String, callback:@escaping (_ room:Room?)->()) {
        q.async {
            if let roomSid = self.userInRoom[userSid] {
                if let room = self.rooms[roomSid] {
                    callback(room)
                } else {
                    self.printLog("user:\(userSid) is not in any room")
                    callback(nil)
                }
            } else {
                self.printLog("user:\(userSid) is not in any room")
                callback(nil)
            }
        }
    }
    
    func roomUsers(_ socket:WebSocket, roomSid:String, callback:@escaping (_ users:[UserInfo])->()) {
        findRoomIfExist(roomSid) { (room) in
            if let room = room {
                callback(room.userList)
            } else {
                callback([])
            }
        }
    }

    func roomOtherUsers(_ socket:WebSocket, roomSid:String, callback:@escaping (_ users:[UserInfo])->()) {
        roomUsers(socket, roomSid: roomSid) { (users) in
            var userArr = users
            for u in users {
                if u.userSid != u.userSid {
                    userArr.append(u)
                }
            }
            callback(userArr)
        }

    }
    
}

extension WS {
    
    
    fileprivate func removeUserFormRoomIfExist(_ roomSid:String, userSid:String, callback:@escaping (_ isSuccess:Bool) -> ()) {
        findRoomIfExist(roomSid) { (room) in
            if let room = room {
                var userIndex:Int = -1
                for (idx,value) in room.userList.enumerated() {
                    if value.userSid == userSid {
                        userIndex = idx
                        break
                    }
                }
                if (userIndex >= 0) {
                    self.q.async {
                        self.printLog("remove user:\(userSid) from room:\(roomSid)")
                        room.userList.remove(at: userIndex)
                        if room.userList.count == 0 {
                            self.destroyRoom(roomSid, callback: { (isSuccess) in
                            })
                        }
                        callback(true)
                    }
                } else {
                    self.printLog("can't find user:\(userSid) in room:\(roomSid), removeUser failed!")
                    callback(false)
                }
            } else {
                self.printLog("room not existed!")
                callback(false)
            }
        }

    }

    private func destroyRoom(_ roomSid:String, callback:@escaping (_ isSuccess:Bool) -> ()) {
        printLog("destroyRoom:\(roomSid)")
        q.async {
//            RedisService.instance.getClient(callback: { (_, client) in
//                let key = "Room_" + roomSid
//                client?.delete(keys: key, callback: { (resp) in
//
//                })
//            })
            
            if let _ = self.rooms.removeValue(forKey: roomSid) {
                callback(true)
            } else {
                callback(false)
            }
            self.printLog("after destroyRoom, rooms count:\(self.rooms.keys.count)")
        }
    }
}
