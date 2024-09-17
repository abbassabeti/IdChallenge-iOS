//
//  Authentication.swift
//
//
//  Created by Abbas Sabeti on 17.09.24.
//

import LocalAuthentication

protocol AuthenticationService {
    func authenticateUser(completion: @escaping (Result<Void, IDError>) -> Void)
}

final class AuthenticationManager: AuthenticationService {
    static let unauthorizedFaceIDPermissionErrorCode = -6
    static let noIdentitiesAreEnrolledErrorCode = -7
    
    private let contextProvider: () -> LAContext
    
    init(contextProvider: @escaping () -> LAContext = { LAContext() }) {
        self.contextProvider = contextProvider
    }

    func authenticateUser(completion: @escaping (Result<Void, IDError>) -> Void) {
        let context = contextProvider()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access Photos") { success, error in
            if let _error = error as? NSError {
                switch _error.code {
                case Self.unauthorizedFaceIDPermissionErrorCode:
                    completion(.failure(.biometryPermissionDenied))
                case Self.noIdentitiesAreEnrolledErrorCode:
                    completion(.failure(.noIdentitiesEnrolled))
                default:
                    completion(.failure(.notAuthorized))
                }
            } else {
                completion(.success(()))
            }
        }
    }
}
