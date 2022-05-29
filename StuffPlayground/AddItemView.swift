//
//  AddItemView.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 24/9/19.
//  Copyright © 2019 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import SwiftUI
import CoreNFC
import Combine

// TODO: Properly credit https://www.swiftbysundell.com/articles/building-an-async-swiftui-button/

struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    @ViewBuilder var label: () -> Label

    @State private var isPerformingTask = false

    var body: some View {
        Button(
            action: {
                isPerformingTask = true
            
                Task {
                    await action()
                    isPerformingTask = false
                }
            },
            label: {
                ZStack {
                    // We hide the label by setting its opacity
                    // to zero, since we don't want the button's
                    // size to change while its task is performed:
                    label().opacity(isPerformingTask ? 0 : 1)

                    if isPerformingTask {
                        ProgressView()
                    }
                }
            }
        )
        .disabled(isPerformingTask)
    }
}

struct AddItemView: View {
  @EnvironmentObject var userData: UserData
  @Environment(\.managedObjectContext) var managedObjectContext

  @State private var lastNDEFScanner: CombinedNFCNDEFReaderSession2?
  @State private var tagThing: AnyCancellable?
  @State private var name = ""
  @StateObject var model = ScannedNFCTagModel()
    
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Name", text: $name)
        }
        Section {
          if !NFCNDEFReaderSession.readingAvailable {
            Text("No NFC Available")
          } else {
            AsyncButton(action: {
              do {
                try await self.model.claimNFCTag3()
              } catch {
                print("Some error ocurred etc etc \(error)")
              }
            }) {
              Text(model.tagID == nil ? "Add NFC Tag" : "Replace NFC Tag (\(self.model.tagID!))")
            }
          }
        }
      }.navigationBarTitle("New Item")
      .navigationBarItems(trailing:
        Button(action: {
          self.save()
        }) {
            Text("Add Item")
        }.disabled(name.count == 0 || model.tagID == nil)
      )
    }
  }
  
  
  func save() {
    let item = Item(context: self.managedObjectContext)
    item.name = name
    item.tagID = model.tagID
    
    // if self.managedObjectContext.hasChanges { } maybe
    do {
      print("Save all the things!")
        try self.managedObjectContext.save()
    } catch {
        // handle the Core Data error
      print("Unable to save core data, sad face :(")
    }
  }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
    }
}

//  @State private var agreedToTerms = false
//  @State private var enableLogging = false
//  @State private var showingAdvancedOptions = false
//
//  @State private var selectedColor = 0
//  @State private var colors = ["Red", "Green", "Blue"]

// Extra sections
//            Section {
//                Picker(selection: $selectedColor, label: Text("Color")) {
//                    ForEach(0 ..< colors.count) {
//                        Text(self.colors[$0])
//
//                    }
//                }
//            }
//
//              Section {
//                  Picker(selection: $selectedColor, label: Text("Select a color")) {
//                      ForEach(0 ..< colors.count) {
//                          Text(self.colors[$0]).tag($0)
//                      }
//                  }.pickerStyle(SegmentedPickerStyle())
//              }
            
//              Section(footer: Text("Note: Enabling advanced options may slow down the app")) {
//                  Toggle(isOn: $showingAdvancedOptions.animation()) {
//                      Text("Show advanced options")
//                  }
//
//                  if showingAdvancedOptions {
//                      Toggle(isOn: $enableLogging) {
//                          Text("Enable logging")
//                      }
//                  }
//              }

//              Section {
////                  Toggle(isOn: $agreedToTerms) {
////                      Text("Agree to terms and conditions")
////                  }
//
//                  Button(action: {
//                    self.save()
//                  }) {
//                      Text("Add Item")
//                  }.disabled(name.count == 0)
//            }
