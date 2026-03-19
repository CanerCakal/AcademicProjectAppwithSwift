import SwiftUI

struct LoginView: View {
    // Çevreden (Environment) AuthViewModel'i alıyoruz ki fonksiyonlarına ulaşalım
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Ekranda kullanıcının yazdıklarını tutacak anlık değişkenler (State)
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 25) {
            
            Text("Akademik Sistem")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            VStack(spacing: 15) {
                // E-posta alanı
                TextField("E-posta Adresi", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never) // İlk harfi otomatik büyütmesini engeller
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                // Şifre alanı (yazılanları gizler)
                SecureField("Şifre", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            
            // Eğer bir hata varsa (şifre yanlış vs.) kırmızı yazıyla ekrana bas
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Giriş Butonu
            Button(action: {
                // async bir fonksiyonu tetiklediğimiz için Task { } içine alıyoruz
                Task {
                    await authViewModel.login(email: email, password: password)
                }
            }) {
                Text("Giriş Yap")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding(.top, 80)
    }
}
