//
//  Menu.swift
//  Little Lemon
//
//  Created by Ajin on 23/04/23.
//

import SwiftUI
import CoreData

struct Menu: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var startersIsEnabled = true
    @State var mainsIsEnabled = true
    @State var dessertsIsEnabled = true
    @State var drinksIsEnabled = true
    
    @State var searchText = ""
    
    @State var loaded = false
    
    @State var isKeyboardVisible = false
    
    init() {
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    if !isKeyboardVisible {
                        withAnimation() {
                            Hero()
                                .frame(maxHeight: 180)
                        }
                    }
                    TextField("Search menu", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(Color.primaryColor1)
                
                Text("ORDER FOR DELIVERY!")
                    .font(.sectionTitle())
                    .foregroundColor(.highlightColor2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .padding(.leading)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        Toggle("Starters", isOn: $startersIsEnabled)
                        Toggle("Mains", isOn: $mainsIsEnabled)
                        Toggle("Desserts", isOn: $dessertsIsEnabled)
                        Toggle("Drinks", isOn: $drinksIsEnabled)
                    }
                    .toggleStyle(MyToggleStyle())
                    .padding(.horizontal)
                }
                FetchedObjects(predicate: buildPredicate(),
                               sortDescriptors: buildSortDescriptors()) {
                    (dishes: [Dish]) in
                    List(dishes) { dish in
                        NavigationLink(destination: DetailItem(dish: dish)) {
                            FoodItem(dish: dish)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .onAppear {
            if !loaded {
                getMenuData()
                loaded = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            withAnimation {
                self.isKeyboardVisible = true
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            withAnimation {
                self.isKeyboardVisible = false
            }
        }
    }
    
    func buildSortDescriptors() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "title",
                                  ascending: true,
                                  selector:
                                    #selector(NSString.localizedStandardCompare))]
    }
    
    func buildPredicate() -> NSCompoundPredicate {
        let search = searchText == "" ? NSPredicate(value: true) : NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        let starters = !startersIsEnabled ? NSPredicate(format: "category != %@", "starters") : NSPredicate(value: true)
        let mains = !mainsIsEnabled ? NSPredicate(format: "category != %@", "mains") : NSPredicate(value: true)
        let desserts = !dessertsIsEnabled ? NSPredicate(format: "category != %@", "desserts") : NSPredicate(value: true)
        let drinks = !drinksIsEnabled ? NSPredicate(format: "category != %@", "drinks") : NSPredicate(value: true)

        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [search, starters, mains, desserts, drinks])
        return compoundPredicate
    }
    
    func getMenuData(){
        print("get food")
        PersistenceController.shared.clear()
        
        guard let url = URL(string: "https://raw.githubusercontent.com/Meta-Mobile-Developer-PC/Working-With-Data-API/main/menu.json") else { return }
        print("url done")
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, URLResponse, error in
            if let data = data{
                print(data)
                if let menu = try? JSONDecoder().decode(MenuList.self, from: data){
                    print(menu)
                    for item in menu.menu{
                        print(item.title)
                        let dish = Dish(context: viewContext)
                        dish.title = item.title
                        dish.price = item.price
                        dish.image = item.image
                        dish.category = item.category
                        dish.descriptionDish = item.description
                    }
                    try? viewContext.save()
                }
            }
        }.resume()
    }
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

