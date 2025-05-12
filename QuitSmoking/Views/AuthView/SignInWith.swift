//
//  AuthView.swift
//  QuitSmoking (iOS)
//
//  Created by Mac on 11.05.2025.
//

import _AuthenticationServices_SwiftUI
import CryptoKit
import FirebaseAuth
import SwiftUI

@Observable class SessionData {
    var isUserLoggedIn: Bool = false
}

class SignInWithAppleViewModel {
    fileprivate var currentNonce: String?
    fileprivate var errorMessage: String?

    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }

    func handleSignInWithAppleComplete(_ result: Result<ASAuthorization, Error>) {
        if case let .failure(failure) = result {
            errorMessage = failure.localizedDescription
            print("Sign in with Apple failed: \(failure.localizedDescription)")
        } else if case let .success(success) = result {
            if let appleIdCredential = success.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state in AppleSignInViewModel")
                }
                guard let appleIdToken = appleIdCredential.identityToken else {
                    errorMessage = "Apple ID token unavailable"
                    return
                }
                guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
                    errorMessage = "Unable to convert Apple ID token to string"
                    return
                }

                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)

                Task {
                    do {
                        _ = try await Auth.auth().signIn(with: credential)
                    } catch {
                        print("Error authenticating with Apple: \(error)")
                    }
                }
            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

struct SignInWith: View {
    var sessionData: SessionData = SessionData()
    var viewModel: SignInWithAppleViewModel

    @State var isUserLoggedIn: Bool = false

    init() {
        viewModel = SignInWithAppleViewModel()
    }

    var body: some View {
        NavigationStack {
            VStack {
                TopBarView()
                Spacer()
                SignInWithAppleButton {
                    request in viewModel.handleSignInWithAppleRequest(request)
                } onCompletion: {
                    result in viewModel.handleSignInWithAppleComplete(result)
                    if case .success = result {
                        isUserLoggedIn.toggle()
                    }
                }
                .frame(width: 300, height: 50)
                .cornerRadius(8)
            }
            .navigationDestination(isPresented: $isUserLoggedIn) {
                ContentView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    SignInWith()
        .padding(20)
}
