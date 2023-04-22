//
//  MenuItem.swift
//  Little Lemon
//
//  Created by Ajin on 22/04/23.
//

import Foundation

struct MenuItem: Codable, Identifiable {
    var id = UUID()
    let title : String
    let descriptionDish: String
    let price: String
    let image: String
    let category: String
}
