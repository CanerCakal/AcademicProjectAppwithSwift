import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authViewModel.currentUser {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.top, 50)
                    
                    Text(user.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(user.email)
                        .foregroundColor(.gray)
                    
                    let roleName = user.roleId == 1 ? "Admin" : (user.roleId == 2 ? "Öğretmen" : "Öğrenci")
                    Text("Yetki: \(roleName)")
                        .font(.subheadline)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                }
                
                Spacer()
                
                Button(action: {
                    authViewModel.logout()
                }) {
                    Text("Sistemden Çıkış Yap")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .navigationTitle("Profilim")
        }
    }
}
