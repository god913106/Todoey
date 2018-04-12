//
//  Item.swift
//  Todoey
//
//  Created by 洋蔥胖 on 2018/4/10.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import Foundation

class Item : Codable {
    //a type that can encode ifself to an external representation
    var title : String  = ""
    var done : Bool = false
    }
