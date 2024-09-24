//
//  AuthenticationService.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 18.09.24.
//

import Foundation
@testable import IdFramework

class MockAuthenticationService: AuthenticationService {
    var resultToReturn: Result<Void, IDError>?

    func authenticateUser(completion: @escaping (Result<Void, IDError>) -> Void) {
        if let result = resultToReturn {
            completion(result)
        } else {
            completion(.success(()))
        }
    }
}
