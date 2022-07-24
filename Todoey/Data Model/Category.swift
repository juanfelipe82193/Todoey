//
//  Category.swift
//  Todoey
//
//  Created by Juan Felipe Zorrilla Ocampo on 11/07/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var colour: String
    
    // A Category can have many items
    @Persisted var items = List<Item>()
}
