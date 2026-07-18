import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogoutConfirm = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                if let user = authViewModel.currentUser {
                    VStack(spacing: 24) {
                        
                        VStack(spacing: 16) {
                            Circle()
                                .fill(Color.appPrimary.opacity(0.15))
                                .frame(width: 96, height: 96)
                                .overlay(
                                    Text(initials(for: user.fullName))
                                        .font(.system(size: 34, weight: .semibold))
                                        .foregroundStyle(Color.appPrimary)
                                )
                            
                            VStack(spacing: 6) {
                                Text(user.fullName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(RoleResolver.roleName(for: user.roleId))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color.appPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 5)
                                    .background(Color.appPrimary.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 0) {
                            infoRow(icon: "envelope.fill", label: "E-posta", value: user.email)
                            Divider().padding(.leading, 56)
                            infoRow(
                                icon: "person.text.rectangle.fill",
                                label: "Hesap Türü",
                                value: RoleResolver.roleName(for: user.roleId)
                            )
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        Button {
                            showLogoutConfirm = true
                        } label: {
                            Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.statusRejected)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.statusRejected.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(BouncyButtonStyle())
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Profilim")
            .alert("Çıkış Yap", isPresented: $showLogoutConfirm) {
                Button("Çıkış Yap", role: .destructive) {
                    authViewModel.logout()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Hesabınızdan çıkmak istediğinize emin misiniz?")
            }
        }
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 42, height: 42)
                .background(Color.appPrimary.opacity(0.12))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.medium))
            }
            
            Spacer()
        }
        .padding(14)
    }
    
    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
