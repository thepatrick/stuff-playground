//
//  ContentView.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 23/9/19.
//  Copyright © 2019 Patrick Quinn-Graham. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
 
    var body: some View {
        TabView(selection: $selection){
            ItemsListTabView()
              .tabItem {
                VStack {
                  Image("first")
                  Text("Items")
                }
              }
              .tag(0)
            AddItemView()
                .tabItem {
                    VStack {
                        Image("second")
                        Text("Add Item")
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      return ContentView().environment(\.managedObjectContext, context)
    }
}
