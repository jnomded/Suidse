//
//  Encryptor.swift
//  Suidse
//
//  Created by James Edmond on 2/5/25.
//

import Foundation
import CryptoKit

class Encryptor {
    static func encrypt(data: Data, password: String) -> Data? {
        let passwordData = Data(password.utf8)
        let salt = Data([0x73, 0x61, 0x6C, 0x74, 0x44, 0x61, 0x74, 0x61]) //random salt for later, this is ai placeholders
        
        let key = SymmetricKey(size: .bits256)
        // ai placeholders
        return try? AES.GCM.seal(data, using: key).combined
    }
}
