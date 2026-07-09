import SwiftUI

struct EditProjectView: View {
    @EnvironmentObject var projectViewModel: ProjectViewModel
    @Environment(\.dismiss) var dismiss

    let project: Project

    @State private var title: String
    @State private var summary: String

    init(project: Project) {
        self.project = project
        _title = State(initialValue: project.title)
        _summary = State(initialValue: project.summary ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Proje Bilgileri") {
                    TextField("Başlık", text: $title)
                    TextField("Özet", text: $summary, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle("Projeyi Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        Task {
                            await projectViewModel.updateProject(
                                projectId: project.id ?? "",
                                title: title,
                                summary: summary
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
