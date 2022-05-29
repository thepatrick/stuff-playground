//
//  CombinedNFCNDEFReaderSessionPublisher.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 29/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import Combine

class CombinedNFCNDEFReaderSessionPublisher: Publisher {
  typealias Output = NFCNDEFSessionAndTag
  typealias Failure = Error
  
  func receive<S>(subscriber: S) where S : Subscriber, S.Failure == CombinedNFCNDEFReaderSessionPublisher.Failure, S.Input == CombinedNFCNDEFReaderSessionPublisher.Output {
    let subscription = CombinedNFCNDEFReaderSessionSubscription(subscriber: subscriber)
    subscriber.receive(subscription: subscription)
  }
}
