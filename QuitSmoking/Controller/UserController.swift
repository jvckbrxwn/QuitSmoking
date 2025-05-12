//
//  UserController.swift
//  QuitSmoking
//
//  Created by Mac on 12.05.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct User {
    var uid: String
    var name: String?
}

@Observable class UserController {
    private var user: User
    
    private let db = Firestore.firestore()
    
    init() {
        self.user = User(uid: "")
        TryGetUserInfo()
    }
    
    private func TryGetUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        user.uid = uid
        print(user.uid)
    }
    
    func GetUser() -> User {
        return user
    }
}
