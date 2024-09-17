//
//  MockLAContext.swift
//  IdFrameworkTests
//
//  Created by Abbas Sabeti on 24.09.24.
//

import LocalAuthentication

class MockLAContext: LAContext {
    var shouldSucceed: Bool
    var errorCode: Int?
    
    init(shouldSucceed: Bool, errorCode: Int? = nil) {
        self.shouldSucceed = shouldSucceed
        self.errorCode = errorCode
        super.init()
    }
    
    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void) {
        if shouldSucceed {
            reply(true, nil)
        } else if let errorCode = errorCode {
            let error = NSError(domain: LAError.errorDomain, code: errorCode, userInfo: nil)
            reply(false, error)
        } else {
            let error = NSError(domain: LAError.errorDomain, code: LAError.authenticationFailed.rawValue, userInfo: nil)
            reply(false, error)
        }
    }
}
