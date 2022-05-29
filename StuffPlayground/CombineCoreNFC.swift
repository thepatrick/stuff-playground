//
//  PKNFC.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 8/10/19.
//  Copyright © 2019 Patrick Quinn-Graham. All rights reserved.
//


import Foundation
import CoreNFC
import PromiseKit
import Combine

class CombinedNFCNDEFReaderSession2 {
  func generateTagIDRaw() -> String {
    return UUID().uuidString
  }
  
  func generateTagIDURL(_ tagID: String) -> NFCNDEFPayload {
    return NFCNDEFPayload.wellKnownTypeURIPayload(string: String(format: "https://%@/%@", "a.twopats.live", tagID))!
  }
  
  func generateTagID() -> (String, NFCNDEFPayload) {
    let tagID = generateTagIDRaw()
    let payload = generateTagIDURL(tagID)
    return (tagID, payload)
  }
  
  func invalidateMessage(forError error: Error) -> String {
    if let error = error as? TagErrors {
      return error.localizedDescription
    }
    
    return "Connection error. Please try again."
  }
  
  func getTagID(_ record: NFCNDEFPayload) throws -> (String, Bool) {
    if record.typeNameFormat == NFCTypeNameFormat.empty {
      let _tagID = generateTagIDRaw()
      
      return (_tagID, true)
    }
    
    guard let uri = record.wellKnownTypeURIPayload() else {
      print("* Something else: identifier: \(record.identifier); typeNameFormat: \(record.typeNameFormat.rawValue); type: \(record.type); payload: \(record.payload)")
      throw TagErrors.TagNotEmpty
    }
    
    let tagID = uri.pathComponents[1]
    
    return (tagID, false)
  }
  
  func getNDEFTagThing(sessionAndTag: NFCNDEFSessionAndTag) async throws -> String {
    let session = sessionAndTag.session
    let tag = sessionAndTag.tag
    do {
      try await session.connect(to: tag)
      print("Connected to tag! \(tag)")

      let (ndefStatus, capacity) = try await tag.queryNDEFStatus()

      switch ndefStatus {
      case .notSupported:
        throw TagErrors.TagNotSupported
      case .readOnly:
        throw TagErrors.TagNotWritable
      default:
        print("Tag has capacity \(capacity)")
      }
      
      let message = try await tag.readNDEFWithDefault()
      print("\(message.records.count) records:")
      
      let record = message.records.first ?? NFCNDEFPayload.emptyPayload()
      
      let (tagId, needsWrite) = try getTagID(record)
      if needsWrite {
        session.alertMessage = "Writing tag ID..."
        try await tag.writeNDEF(NFCNDEFMessage(records: [generateTagIDURL(tagId)]))
      }
      
      await MainActor.run {
        session.alertMessage = "Found tag"
      }
      
      print("* got tagId \(tagId), invalidating...")
      return tagId
      
    } catch {
      print("* catch error \(error), invalidating...")
      session.invalidate(errorMessage: self.invalidateMessage(forError: error))
      throw error
    }
  }
  
  func startNDEFScan3() -> AnyPublisher<String, Error> {
    print("startNDEFScan3!")
    return CombinedNFCNDEFReaderSessionPublisher()
      .flatMap(maxPublishers: .max(1)) { sessionAndTag -> AnyPublisher<String, Error> in
        Future {
          print("* Future begins...")
          return try await self.getNDEFTagThing(sessionAndTag: sessionAndTag)
        }.catch { error -> Fail<String, Error> in
          print("* Future fail... \(error)")
          return Fail(error: error)
        }.map { (tagId: String) -> String in
          print("* Future got tagId \(tagId), invalidating...")
          return tagId
        }.eraseToAnyPublisher()
    }.eraseToAnyPublisher()
  }
  
  func startNDEFScan4() async throws -> String {
    return try await CombinedNFCNDEFReaderSession2().startNDEFScan3().eraseToAnyPublisher().async()
  }
}
