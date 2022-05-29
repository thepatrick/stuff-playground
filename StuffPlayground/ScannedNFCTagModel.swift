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
  
  func claimNFCTag3() async throws {    
    let tagID = try await CombinedNFCNDEFReaderSession2().startNDEFScan4()
    
    await MainActor.run {
      self.tagID = tagID
    }
  }

}
