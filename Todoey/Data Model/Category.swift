//
//  Category.swift
//  Todoey
//
//  Created by 洋蔥胖 on 2018/4/18.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let items = List<Item>() //let array = Array<Int>()
    
}
