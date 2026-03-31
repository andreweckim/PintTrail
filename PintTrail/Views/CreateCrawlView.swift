import SwiftUI
import SwiftData

struct CreateCrawlView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Crawl Details") {
                    TextField("Crawl Name (e.g. Friday Night Crawl)", text: $name)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section {
                    Text("Once created, you'll get an invite code and QR to share with friends.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Pub Crawl")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let crawl = PubCrawl(name: name, date: date)
                        modelContext.insert(crawl)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CreateCrawlView()
        .modelContainer(for: PubCrawl.self, inMemory: true)
}
