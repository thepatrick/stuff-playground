//
//  NFCNDEFReaderSession.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 28/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import CoreNFC
import Combine

extension NFCNDEFReaderSession {
  
  func connectAsync(to tag: NFCNDEFTag) -> Future<Void, Error> {
    Future {
      try await self.connect(to: tag)
    }
  }

}
