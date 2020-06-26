//
//  Catagory.swift
//  Todoey
//
//  Created by Bruckner de Villiers on 2020/06/25.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Catagory: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
