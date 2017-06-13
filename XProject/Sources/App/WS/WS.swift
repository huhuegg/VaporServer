//
//  WS.swift
//  WebServer
//
//  Created by huhuegg on 2017/5/5.
//
//

import Vapor
import Dispatch

class WS {
    static var ws = WS()
    
    static var instance:WS {
        return ws
    }
    
    var clients:Dictionary<Int,ClientInfo> = Dictionary()
    var rooms:Dictionary<String,Room> = Dictionary()
    var userInRoom:Dictionary<String,String> = Dictionary()
    
    let q = DispatchQueue(label: "##WS Thread##")
    
    func printLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
        
        print("\(file)[\(line)], \(method): \(message)")
    }
    
}

