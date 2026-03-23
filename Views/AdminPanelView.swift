import SwiftUI

struct AdminPanelView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .padding()
                
                Text("Burası çok gizli bir Admin panelidir.")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .navigationTitle("Yönetim Paneli")
        }
    }
}
