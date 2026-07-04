import SwiftUI

struct RegisterView: View {
    // AuthViewModel'i login ekranıyla paylaşıyoruz ki kayıt sonrası
    // isAuthenticated true olunca uygulama otomatik Dashboard'a geçsin.
    @EnvironmentObject var authViewModel: AuthViewModel

    // Bu ekran bir sheet olarak açılacak; kapatmak için dismiss kullanacağız.
    @Environment(\.dismiss) var dismiss

    // Formdaki üç alanın canlı değerlerini tutan state değişkenleri.
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // --- Başlık bölümü ---
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)

                        Text("Hesap Oluştur")
                            .font(.title).bold()

                        Text("Akademik projelerini yönetmeye başla")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)

                    // --- Form alanları ---
                    VStack(spacing: 16) {
                        // Her alanı küçük bir yardımcı görünümle çiziyoruz (aşağıda tanımlı).
                        labeledField(icon: "person", placeholder: "Ad Soyad", text: $fullName)

                        labeledField(icon: "envelope", placeholder: "E-posta", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)

                        labeledSecureField(icon: "lock", placeholder: "Şifre", text: $password)
                    }
                    .padding(.horizontal)

                    // --- Hata mesajı (varsa) ---
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // --- Kayıt ol butonu ---
                    Button {
                        // Butona basınca register'ı çağırıyoruz. async olduğu için Task içinde.
                        Task {
                            await authViewModel.register(
                                fullName: fullName,
                                email: email,
                                password: password,
                                departmentId: nil   // Bölüm seçimini şimdilik boş geçiyoruz
                            )
                            // Kayıt başarılıysa isAuthenticated true olur; ekranı kapat.
                            if authViewModel.isAuthenticated {
                                dismiss()
                            }
                        }
                    } label: {
                        // isLoading true ise çark, değilse "Kayıt Ol" yazısı göster.
                        if authViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Kayıt Ol")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal)
                    // Alanlar boşken butonu pasif yap (basit doğrulama).
                    .disabled(fullName.isEmpty || email.isEmpty || password.isEmpty || authViewModel.isLoading)

                    Spacer()
                }
            }
            .navigationTitle("Kayıt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Sağ üstte kapatma butonu.
                ToolbarItem(placement: .topBarTrailing) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }

    // --- Yardımcı görünümler ---
    // Aynı stildeki alanları tekrar tekrar yazmamak için küçük fonksiyonlara böldük.
    // Bu, "kendini tekrar etme" (DRY) prensibinin SwiftUI'daki pratik hali.

    private func labeledField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            TextField(placeholder, text: text)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func labeledSecureField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            SecureField(placeholder, text: text)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
