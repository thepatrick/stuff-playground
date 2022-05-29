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
  
  func claimNFCTag3() async throws {
    lastNDEFScanner = CombinedNFCNDEFReaderSession2()
    
    let tagID = try await lastNDEFScanner!.startNDEFScan3().eraseToAnyPublisher().async()
    
    await MainActor.run {
      self.tagID = tagID
    }
  }

}
