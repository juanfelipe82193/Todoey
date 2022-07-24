//
//  Item.swift
//  Todoey
//
//  Created by Juan Felipe Zorrilla Ocampo on 11/07/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Date?
    
    // Define inverse relationship
    // An Item can belong only to one Category
    @Persisted(originProperty: "items") var parentCategory:LinkingObjects<Category>
}
