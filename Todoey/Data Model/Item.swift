//
//  Item.swift
//  Todoey
//
//  Created by 洋蔥胖 on 2018/4/18.
//  Copyright © 2018年 ChrisYoung. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    /*
     two modifiers basically so that Realm can monitor for changes in the value of this property
     兩個修飾基本上用realm可以監控這屬性的值有什麼變化
    */
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
