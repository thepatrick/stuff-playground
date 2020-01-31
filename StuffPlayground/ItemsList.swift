//
//  ItemsList.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 24/9/19.
//  Copyright © 2019 Patrick Quinn-Graham. All rights reserved.
//

import SwiftUI

struct ItemsList: View {
  @Environment(\.managedObjectContext) var managedObjectContext
  
  // NSPredicate(format: "name == %@", "Python")
//  @FetchRequest(
//      entity: ProgrammingLanguage.entity(),
//      sortDescriptors: [
//          NSSortDescriptor(keyPath: \ProgrammingLanguage.name, ascending: true),
//      ],
//      predicate: NSPredicate(format: "name == %@", "Python")
//  ) var languages: FetchedResults<ProgrammingLanguage>
  
  @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)]) var items: FetchedResults<Item>
  
  var body: some View {
    List(items, id: \.self) { item in
      Text(item.name ?? "(no name)")
    }
  }
}

struct ItemsList_Previews: PreviewProvider {
  static var previews: some View {
      let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      return ItemsList().environment(\.managedObjectContext, context)
  }
}
