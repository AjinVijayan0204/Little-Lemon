//
//  MenuList.swift
//  Little Lemon
//
//  Created by Ajin on 22/04/23.
//

import Foundation
import CoreData

struct MenuList: Codable {
    let menu: [MenuItem]
    
    static func getMenuData(viewContext: NSManagedObjectContext){
        PersistenceController.shared.clear()
        
        guard let url = URL(string: "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json") else { return }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, URLResponse, error in
            if let data = data{
                if let menu = try? JSONDecoder().decode(MenuList.self, from: data){
                    for item in menu.menu{
                        let dish = Dish(context: viewContext)
                        dish.title = item.title
                        dish.price = item.price
                        dish.image = item.image
                        dish.category = item.category
                        dish.descriptionDish = item.descriptionDish
                    }
                    try? viewContext.save()
                }
            }
        }.resume()
    }
}
