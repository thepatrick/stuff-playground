//
//  NFCNDEFSessionAndTag.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 28/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import CoreNFC
import PromiseKit
import Combine

struct NFCNDEFSessionAndTag {
  let session: NFCNDEFReaderSession
  let tag: NFCNDEFTag
}
