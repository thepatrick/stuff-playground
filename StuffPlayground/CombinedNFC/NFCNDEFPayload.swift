//
//  NFCNDEFPayload.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 29/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import CoreNFC
import Combine

extension NFCNDEFPayload {
  
  static func emptyPayload() -> NFCNDEFPayload {
    NFCNDEFPayload(format: NFCTypeNameFormat.empty, type: Data(), identifier: Data(), payload: Data())
  }
  
}
