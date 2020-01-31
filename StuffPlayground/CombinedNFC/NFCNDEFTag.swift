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
    Future { promise in
      self.queryNDEFStatus { (status, capacity, error) in
        print("Hi")
        if let queryError = error {
          promise(.failure(queryError))
          return
        }

        promise(.success(NFCNDEFQueryResponse(status: status, capacity: capacity)))
      }
    }
  }

  func readNDEFAsync() -> Future<NFCNDEFMessage, Error> {
    Future { promise in
      self.readNDEF { (message, error) in
        if let readError = error {
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
  
  func writeNDEFAsync(_ message: NFCNDEFMessage) -> Future<Void, Error> {
    Future { promise in
      self.writeNDEF(message) { error in
        if let error = error {
//          session.invalidate(errorMessage: "Connection error. Please try again.")
          promise(.failure(error))
          return
        }
        
        promise(.success(()))
      }
    }
  }
}
