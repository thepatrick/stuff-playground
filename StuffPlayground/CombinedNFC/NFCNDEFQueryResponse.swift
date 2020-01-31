//
//  NFCNDEFQueryResponse.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 25/10/19.
//  Copyright © 2019 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import CoreNFC

public struct NFCNDEFQueryResponse {
  let status: NFCNDEFStatus
  let capacity: Int
}
