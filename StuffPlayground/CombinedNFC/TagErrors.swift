//
//  TagErrors.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 25/10/19.
//  Copyright © 2019 Patrick Quinn-Graham. All rights reserved.
//

import Foundation

public enum TagErrors: LocalizedError, CaseIterable {
  case TagNotSupported
  case TagNotWritable
  case TagNotEmpty
  case TagAlreadyAttached
  case TagEmpty
  case InvalidCallingConvention

  var localizedDescription: String {
      switch self {
      case .TagNotSupported: return "Tag is not supported"
      case .TagNotWritable: return "Tag is not writable"
      case .TagNotEmpty: return "Tag is not empty"
      case .TagAlreadyAttached: return "Tag is attached to another item"
      case .TagEmpty: return "Tag is not initialised for StuffPlayground"
      case .InvalidCallingConvention: return "A closure was called with an invalid calling convention, probably (nil, nil)"
      }
    }
}
