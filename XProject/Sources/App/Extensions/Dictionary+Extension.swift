//
//  Dictionary+Extension.swift
//  XProject
//
//  Created by huhuegg on 2017/6/13.
//
//

import SwiftyJSON

extension Dictionary {
    func toJson() -> String? {
        guard let d = self as? [String:Any] else {
            return nil
        }
        return JSON(d).rawString()
    }
}
