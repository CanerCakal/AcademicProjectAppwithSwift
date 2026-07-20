import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                VStack(spacing: 12) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.appPrimary)
                    
                    Text("Akademik Sistem")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Projelerini takip et, yönet, tamamla")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                VStack(spacing: 14) {
                    inputField(icon: "envelope", placeholder: "E-posta Adresi", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    secureInputField(icon: "lock", placeholder: "Şifre", text: $password)
                }
                .padding(.horizontal, 28)
                
                if let errorMessage = authViewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text(errorMessage)
                    }
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 28)
                    .padding(.top, 16)
                    .transition(.opacity)
                }
                
                Button {
                    Task {
                        await authViewModel.login(email: email, password: password)
                    }
                } label: {
                    Group {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Giriş Yap")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(BouncyButtonStyle())
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                
                HStack(spacing: 4) {
                    Text("Hesabın yok mu?")
                        .foregroundStyle(.secondary)
                    Button("Kayıt Ol") {
                        showRegister = true
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appPrimary)
                }
                .font(.footnote)
                .padding(.top, 20)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppBackground())
        .scrollDismissesKeyboard(.interactively)
        .animation(.easeOut(duration: 0.2), value: authViewModel.errorMessage)
        .sheet(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(authViewModel)
        }
    }
    
    private func inputField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            TextField(placeholder, text: text)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func secureInputField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            SecureField(placeholder, text: text)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}
