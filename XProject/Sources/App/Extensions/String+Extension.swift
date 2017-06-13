//
//  String+Extension.swift
//  XProject
//
//  Created by huhuegg on 2017/6/13.
//
//

import SwiftyJSON

extension String {
    func toDict()->Dictionary<String,Any>? {
        guard self != "" else {
            print("error: is emptyString")
            return nil
        }
        guard let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            print("convert text to data with utf8 failed!")
            return nil
        }
        guard let d = JSON(data:data).dictionaryObject else {
            print("conver data to dictionaryObject failed!")
            return nil
        }
        return d
    }
}
