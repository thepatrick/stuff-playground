//
//  Future.swift
//  StuffPlayground
//
//  Created by Patrick Quinn-Graham on 28/5/2022.
//  Copyright © 2022 Patrick Quinn-Graham. All rights reserved.
//

import Foundation
import Combine

// TODO: Properly credit https://www.swiftbysundell.com/articles/creating-combine-compatible-versions-of-async-await-apis/

extension Future where Failure == Error {
    convenience init(operation: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let output = try await operation()
                    promise(.success(output))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
