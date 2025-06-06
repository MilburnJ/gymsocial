//
//  SessionViewModel.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/5/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class SessionViewModel: ObservableObject {
    @Published var currentUser: User? = nil
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        handle = Auth.auth().addStateDidChangeListener{_, firebaseUser in
            if let uid = firebaseUser?.uid {
                let db = Firestore.firestore()
                db.collection("users").document(uid).getDocument { snapshot, error in
                    if let snap = snapshot, snap.exists, let data = snap.data() {
                        let id = snap.documentID
                        let displayName = data["displayName"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let photoURL = data["profilePhotoURL"] as? String
                        
                        DispatchQueue.main.async {
                            self.currentUser = User(
                                id: id,
                                displayName: displayName,
                                email: email,
                                profilePhotoURL: photoURL
                            )
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.currentUser = nil
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.currentUser = nil
                }
            }
        }
    }
    
    deinit {
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
        }
    }
}
