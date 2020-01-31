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

extension NFCNDEFReaderSession {
  func connectAsync(to tag: NFCNDEFTag) -> Future<Void, Error> {
    Future { promise in
      self.connect(to: tag) { error in
        if let error = error {
          promise(.failure(error))
          return
        }
        
        promise(.success(()))
      }
    }
  }
}

struct NFCNDEFSessionAndTag {
  let session: NFCNDEFReaderSession
  let tag: NFCNDEFTag
}

/// A custom subscription to capture UIControl target events.
final class CombinedNFCNDEFReaderSessionSubscription<SubscriberType: Subscriber>: NSObject, Subscription, NFCNDEFReaderSessionDelegate where SubscriberType.Input == NFCNDEFSessionAndTag, SubscriberType.Failure == Error {
    private var subscriber: SubscriberType?
    private var readerSession: NFCNDEFReaderSession?

    init(subscriber: SubscriberType) {
      self.subscriber = subscriber
      super.init()
      self.readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
      print("CombinedNFCNDEFReaderSessionSubscription.startNDEFScan() \(self) \(String(describing: self.readerSession))")
    }

    func request(_ demand: Subscribers.Demand) {
      print("CombinedNFCNDEFReaderSessionSubscription request! \(demand)")
      
      self.readerSession!.alertMessage = "Hold your iPhone near an NFC tag"
      self.readerSession!.begin()
    }

    func cancel() {
      print("CombinedNFCNDEFReaderSessionSubscription cancelled! \(String(describing: self.readerSession))")
      readerSession?.invalidate()
      readerSession = nil
      subscriber = nil
    }

    // This function is here to silence a message that gets logged if it isn't. YOLO.
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
      print("NFCNDEFReaderSession did invalidate with error! \(error)")
      if let readerError = error as? NFCReaderError {
         if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                   && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
          subscriber?.receive(completion: .failure(readerError))
         } else {
          subscriber?.receive(completion: .finished)
        }
      } else {
        subscriber?.receive(completion: .failure(error))
      }
    }

    // This function will not be invoked because `readerSession(_:didDetect:)` is implemented, but is required so must be present. Yay!
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
      print("readerSession(didDetect:) with \(tags.count)")
      if tags.count > 1 {
          session.invalidate(errorMessage: "More than 1 tag was found. Please present only 1 tag.")
          return
      }

      guard let firstTag = tags.first else {
          session.invalidate(errorMessage: "Unable to get first tag")
          return
      }

      _ = subscriber?.receive(NFCNDEFSessionAndTag(session: session, tag: firstTag))
    }
}

class CombinedNFCNDEFReaderSessionPublisher: Publisher {
  typealias Output = NFCNDEFSessionAndTag
  typealias Failure = Error
  
  func receive<S>(subscriber: S) where S : Subscriber, S.Failure == CombinedNFCNDEFReaderSessionPublisher.Failure, S.Input == CombinedNFCNDEFReaderSessionPublisher.Output {
    let subscription = CombinedNFCNDEFReaderSessionSubscription(subscriber: subscriber)
    subscriber.receive(subscription: subscription)
  }
}

class CombinedNFCNDEFReaderSession2 {
  func generateTagID() -> (String, NFCNDEFPayload) {
    let tagID = UUID().uuidString
    let payload = NFCNDEFPayload.wellKnownTypeURIPayload(string: String(format: "https://%@/%@", "a.twopats.live", tagID))!
    return (tagID, payload)
  }
  
  func invalidateMessage(forError error: Error) -> String {
    if let error = error as? TagErrors {
      return error.localizedDescription
    }
    
    return "Connection error. Please try again."
  }
  
  func startNDEFScan() -> AnyPublisher<String, Error> {
    print("startNDEFScan2!")
    return CombinedNFCNDEFReaderSessionPublisher()
      .flatMap(maxPublishers: .max(1)) { sessionAndTag -> AnyPublisher<String, Error> in
        let session = sessionAndTag.session
        let tag = sessionAndTag.tag
        
        return session.connectAsync(to: tag)
        .flatMap { nothing -> Future<NFCNDEFQueryResponse, Error> in
          print("Connected to tag! \(tag)")
          return tag.queryNDEFStatusAsync()
        }
        .flatMap { ndefStatus -> AnyPublisher<NFCNDEFMessage, Error> in
          switch ndefStatus.status {
          case .notSupported:
            return Fail(error: TagErrors.TagNotSupported).eraseToAnyPublisher()
          case .readOnly:
            return Fail(error: TagErrors.TagNotWritable).eraseToAnyPublisher()
          default:
            print("Tag has capacity \(ndefStatus.capacity)")
            return tag.readNDEFAsync().eraseToAnyPublisher()
          }
        }
        .flatMap { message -> AnyPublisher<NFCNDEFPayload, Error> in
          print("\(message.records.count) records:")
          
          return message.records.publisher
            .setFailureType(to: Error.self)
            .first().eraseToAnyPublisher()
        }
        .flatMap { record -> AnyPublisher<String, Error> in
          if record.typeNameFormat == NFCTypeNameFormat.empty {
            let (tagID, tagURL) = self.generateTagID()
            return tag.writeNDEFAsync(NFCNDEFMessage(records: [tagURL]))
              .map { tagID }
              .eraseToAnyPublisher()
          }
          guard let uri = record.wellKnownTypeURIPayload() else {
            print("* Something else: identifier: \(record.identifier); typeNameFormat: \(record.typeNameFormat.rawValue); type: \(record.type); payload: \(record.payload)")
            return Fail(error: TagErrors.TagNotEmpty).eraseToAnyPublisher()
          }
          return Just(uri.pathComponents[1]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        .catch { error -> Fail<String, Error> in
          session.invalidate(errorMessage: self.invalidateMessage(forError: error))
          return Fail(error: error)
        }.map { (tagId: String) -> String in
          session.invalidate()
          return tagId
        }.eraseToAnyPublisher()
    }.eraseToAnyPublisher()
  }
}
