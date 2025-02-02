//
//  SubjectMatterView.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 31.01.2025.
//

import SwiftUI
import SwiftData

struct SubjectMatterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var subjects: [Subject]
    
    @State private var confirmDeletionFromContextMenu: Bool = false
    @State private var deleteSubject: Subject? = nil
    
    var body: some View {
        NavigationSplitView {
            List(subjects) { item in
                NavigationLink {
                    Form {
                        TextField("Ukrainian", text: Binding(get: {
                            return item.ukrName ?? ""
                        }, set: { item.ukrName = $0 }))
                        
                        TextField("English", text: Binding(get: {
                            return item.engName ?? ""
                        }, set: { item.engName = $0 }))
                    }
                    .formStyle(.grouped)
                } label: {
                    Text(item.engName ?? "Subject Matter")
                }
                .contextMenu {
                    Button("Delete", systemImage: "trash") {
                        deleteSubject = item
                        confirmDeletionFromContextMenu.toggle()
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .confirmationDialog("Do you really want to delete \(deleteSubject?.engName ?? "Subject Matter")?", isPresented: $confirmDeletionFromContextMenu, titleVisibility: .visible) {
                Button("Yes", role: .destructive) {
                    if let item = deleteSubject {
                        modelContext.delete(item)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        withAnimation {
                            let subject = Subject()
                            modelContext.insert(subject)
                        }
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
}
