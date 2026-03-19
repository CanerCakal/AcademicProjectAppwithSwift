import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sisteme Başarıyla Giriş Yaptınız! 🎉")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            // Giriş yapan kullanıcının verilerini ekrana yazdırıyoruz
            if let user = authViewModel.currentUser {
                Text("Hoş geldin, \(user.fullName)")
                    .font(.headline)
                
                // Role göre metin gösterimi
                let roleName = user.roleId == 1 ? "Admin" : (user.roleId == 2 ? "Öğretmen" : "Öğrenci")
                Text("Yetkiniz: \(roleName)")
                    .foregroundColor(.secondary)
            }
            
            // Çıkış Butonu
            Button(action: {
                authViewModel.logout()
            }) {
                Text("Çıkış Yap")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
