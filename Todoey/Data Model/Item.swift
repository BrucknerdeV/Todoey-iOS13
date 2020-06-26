//
//  Item.swift
//  Todoey
//
//  Created by Bruckner de Villiers on 2020/06/25.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    var parentCategory = LinkingObjects(fromType: Catagory.self, property: "items")
}
