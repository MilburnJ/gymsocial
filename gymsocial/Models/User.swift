//
//  User.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/5/25.
//

import Foundation

struct User: Identifiable {
    var id: String
    var displayName: String
    var email: String
    var photoURL: URL? //Optional, will add later
    //add more fields later
}
