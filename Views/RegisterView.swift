import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 52))
                            .foregroundStyle(Color.appPrimary)
                        
                        Text("Hesap Oluştur")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Akademik projelerini yönetmeye başla")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 32)
                    
                    VStack(spacing: 14) {
                        inputField(icon: "person", placeholder: "Ad Soyad", text: $fullName)
                        
                        inputField(icon: "envelope", placeholder: "E-posta", text: $email)
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
                        .padding(.horizontal, 28)
                        .padding(.top, 16)
                        .transition(.opacity)
                    }
                    
                    Button {
                        Task {
                            await authViewModel.register(
                                fullName: fullName,
                                email: email,
                                password: password,
                                departmentId: nil
                            )
                            if authViewModel.isAuthenticated {
                                dismiss()
                            }
                        }
                    } label: {
                        Group {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Kayıt Ol")
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
                    .disabled(fullName.isEmpty || email.isEmpty || password.isEmpty || !RoleResolver.isValidInstitutionalEmail(email) || authViewModel.isLoading)
                    .opacity((fullName.isEmpty || email.isEmpty || password.isEmpty || !RoleResolver.isValidInstitutionalEmail(email)) ? 0.6 : 1.0)
                    
                    Spacer(minLength: 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .animation(.easeOut(duration: 0.2), value: authViewModel.errorMessage)
            .navigationTitle("Kayıt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("İptal") { dismiss() }
                        .foregroundStyle(Color.appPrimary)
                }
            }
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
            if !email.isEmpty && !RoleResolver.isValidInstitutionalEmail(email) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                    Text("Kurumsal üniversite e-postanızı kullanın")
                    Spacer()
                }
                .font(.caption)
                .foregroundStyle(.orange)
            }
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
