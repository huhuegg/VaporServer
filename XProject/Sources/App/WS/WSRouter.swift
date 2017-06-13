//
//  WSRouter.swift
//  XProject
//
//  Created by huhuegg on 2017/6/13.
//
//

import Vapor
import SwiftMD5

let kWebsocketSubProtocol = "X"
extension Droplet {
    func xProjectRouter() throws {
        self.socket("websocket") { (req, ws) in
            print("New connect")
            
//            //检查协议是否匹配
//            guard self.checkProtocol(req.headers.secWebProtocol) else {
//                print("protocols error, disconnect!")
//                try? ws.close()
//                return
//            }
            
            WS.instance.addClientIfNeed(ws) { (isSuccess) in
                
            }
            try background {
                while ws.state == .open {
                    try? ws.ping()
                    self.console.wait(seconds: 2)
                }
            }
            
            ws.onText = { ws,text in
                WS.instance.processRequestMessage(ws, text: text)
            }
            
            ws.onClose = { ws, _ , _, _ in
                print("client disconnected!")
            }
        }
    }
    
    func checkProtocol(_ protocols:[String]?)->Bool {
        
        // 检查客户端协议是否匹配
        guard let subProtocol = protocols?.first else {
            print("subProtocol check failed! (protocols is nil)")
            return false
        }
        let checkItems = subProtocol.characters.split(separator: "_")
        guard checkItems.count == 2 else {
            print("subProtocol check failed! (protocols error!)")
            return false
        }
        
        let sessionId = String(checkItems[0])
        let md5 = String(checkItems[1])
        
        let checkStr = sessionId + "_" + kWebsocketSubProtocol
        let md5sum = SwiftMD5.md5(bytesFromString(string: checkStr)).checksum
        
        
        guard md5 == md5sum else {
            print("subProtocol check failed! (protocols checksum error!)")
            return false
        }
        print("subProtocol check ok!")
        return true
    }
    
    func socketMemoryAddress(_ socket:WebSocket) -> Int {
        return unsafeBitCast(socket, to: Int.self)
    }
    
    // Convert String to UInt8 bytes
    func bytesFromString(string: String) -> [UInt8] {
        return Array(string.utf8)
    }
    
    // Convert UInt8 bytes to String
    func stringFromBytes(bytes: [UInt8], count: Int) -> String {
        return String((0..<count).map ({Character(UnicodeScalar(bytes[$0]))}))
    }
}
