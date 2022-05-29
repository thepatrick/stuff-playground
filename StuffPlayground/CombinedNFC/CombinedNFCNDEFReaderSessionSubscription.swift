//
//  CombinedNFCNDEFReaderSessionSubscription.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 29/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import Combine
import CoreNFC

final class CombinedNFCNDEFReaderSessionSubscription<SubscriberType: Subscriber>: NSObject, Subscription, NFCNDEFReaderSessionDelegate where SubscriberType.Input == NFCNDEFSessionAndTag, SubscriberType.Failure == Error {
    private var subscriber: SubscriberType?
    private var readerSession: NFCNDEFReaderSession?

    init(subscriber: SubscriberType) {
      self.subscriber = subscriber
      super.init()
      self.readerSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
    }

    func request(_ demand: Subscribers.Demand) {
      print("CombinedNFCNDEFReaderSessionSubscription request! \(demand)")
      
      self.readerSession!.alertMessage = "Hold your iPhone near an NFC tag"
      self.readerSession!.begin()
      
    }

    func cancel() {
      print("CombinedNFCNDEFReaderSessionSubscription cancelled! \(String(describing: self.readerSession))")
//      readerSession?.alertMessage = "Cancelling..."
      readerSession?.invalidate()
      readerSession = nil
      subscriber = nil
    }

    // This function is here to silence a message that gets logged if it isn't. YOLO.
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
      if let readerError = error as? NFCReaderError {
         if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                   && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {

           print("NFCNDEFReaderSession did invalidate with NFCReaderError! \(error)")

           subscriber?.receive(completion: .failure(readerError))
         } else {
          subscriber?.receive(completion: .finished)
        }
      } else {
        print("NFCNDEFReaderSession did invalidate with error! \(error)")
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
