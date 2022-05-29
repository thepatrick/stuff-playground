//
//  NFCNDEFTag.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 25/10/19.
//  Copyright © 2019 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import CoreNFC
import Combine

extension NFCNDEFTag {
  
  func readNDEFWithDefault() async throws -> NFCNDEFMessage {
    do {
      let message = try await self.readNDEF()
      
      return message
    } catch let error as NFCReaderError {
      if error.code == NFCReaderError.Code.ndefReaderSessionErrorZeroLengthMessage {
        return NFCNDEFMessage(records: [NFCNDEFPayload.emptyPayload()])
      } else {
        throw error
      }
    }
  }
  
}
