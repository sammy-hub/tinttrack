import AuthenticationServices
import SwiftUI

struct SignInWithAppleRow: View {
    @Environment(AuthService.self) private var authService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if authService.isSignedIn {
                HStack {
                    Label("Signed in with Apple", systemImage: "checkmark.circle")
                    Spacer()
                }

                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                }
            } else {
                SignInWithAppleButton(.signIn) { request in
                    authService.clearError()
                    request.requestedScopes = []
                } onCompletion: { result in
                    authService.handleAuthorization(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(maxWidth: .infinity, minHeight: 44)
            }

            if let errorMessage = authService.lastErrorMessage, errorMessage.isEmpty == false {
                Text(errorMessage)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
