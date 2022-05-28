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
  
  func queryNDEFStatusAsync() -> Future<NFCNDEFQueryResponse, Error> {
    Future {
      let (status, capacity) = try await self.queryNDEFStatus()
      
      return NFCNDEFQueryResponse(status: status, capacity: capacity)
    }
  }
  
  func readNDEFAsyncA() -> Future<NFCNDEFMessage, Error> {
    Future {
      try await self.readNDEF()
    }
  }

  func readNDEFAsync() -> Future<NFCNDEFMessage, Error> {
    Future { promise in
      self.readNDEF { (message, error) in
        if let readError = error {
          // if .Code == 403 then provide default value from below instead
          print("readNDEFAsyncError: \(readError)")
          promise(.failure(readError))
          return
        }
        
        if let message = message {
          promise(.success(message))
          return
        }
        
        promise(.success(
          NFCNDEFMessage(records: [NFCNDEFPayload(format: NFCTypeNameFormat.empty, type: Data(), identifier: Data(), payload: Data())])
        ))
      }
    }
  }
  
  func writeNDEFAsyncA(_ message: NFCNDEFMessage) -> Future<Void, Error> {
    Future {
      try await self.writeNDEF(message)
    }
  }
  
  func writeNDEFAsync(_ message: NFCNDEFMessage) -> Future<Void, Error> {
    Future { promise in
      self.writeNDEF(message) { error in
        if let error = error {
          promise(.failure(error))
          return
        }
        
        promise(.success(()))
      }
    }
  }
}
