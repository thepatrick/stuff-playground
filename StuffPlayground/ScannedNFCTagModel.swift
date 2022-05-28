//
//  ScannedNFCTagModel.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 28/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import SwiftUI
import CoreNFC
import Combine

class ScannedNFCTagModel : ObservableObject {
  private(set) var objectWillChange = PassthroughSubject<ScannedNFCTagModel, Never>()
  
  @Published var tagID: String? {
    willSet {
      objectWillChange.send(self)
    }
  }
  
  private var lastNDEFScanner: CombinedNFCNDEFReaderSession2?
  private var tagThing: AnyCancellable?
  
  func claimNFCTag() {
    print("* claimNFCTag!")
    lastNDEFScanner = CombinedNFCNDEFReaderSession2()
    
    tagThing = lastNDEFScanner!.startNDEFScan()
      .receive(on: RunLoop.main)
      .sink(receiveCompletion: { completion in
      switch completion {
      case .finished:
        print("Tag done")
        self.lastNDEFScanner = nil
      case let .failure(error):
        print("Maybe Could Not Get Tag? \(error)")
      }
    }, receiveValue: { tagId in
      print("Got tag \(tagId)")
      self.tagID = tagId
    })
  }
}
