//
//  ItemsListTabView.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 25/9/19.
//  Copyright © 2019 Patrick Quinn-Graham. All rights reserved.
//

import SwiftUI

struct ItemsListTabView: View {
    var body: some View {
      NavigationView {
        ItemsList()
          .navigationBarTitle("Items")
          .navigationBarItems(trailing:
              Button(action: {
                  print("Help tapped!")
              }) {
                  Text("Add Item")
              })
      }
    }
}

struct ItemsListTabView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ItemsListTabView().environment(\.managedObjectContext, context)
    }
}
