//
//  UserData.swift
//  TransitPal
//
//  Created by Robert Trencheny on 6/6/19.
//  Copyright © 2019 Robert Trencheny. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CoreNFC
import PromiseKit

struct TransitTag {
  let tagId: String
}

final class UserData: NSObject, ObservableObject {
  
  private(set) var willChange = PassthroughSubject<UserData, Never>()

  public var processedTag: String? {
    didSet {
      self.willChange.send(self)
    }
  }
}
