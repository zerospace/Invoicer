//
//  ContentView.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 07.01.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.modelContext) private var modelContext
    
    @Query private var profiles: [Profile]
    @State private var profile: Profile?
    
    @Query private var customers: [Customer]
    @State private var selected: Customer? = nil
    
    @State private var isProfileVisible: Bool = false
    @State private var confirmDeletionFromContextMenu: Bool = false
    @State private var confirmDeletionFromAppMenu: Bool = false
    @State private var deleteCustomer: Customer? = nil

    var body: some View {
        NavigationSplitView {
            List(customers, selection: $selected) { customer in
                NavigationLink(value: customer) {
                    Label {
                        Text(customer.name ?? "no name")
                    } icon: {
                        Image(nsImage: customer.image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    }
                }
                .contextMenu {
                    Button("Edit", systemImage: "pencil") {
                        openWindow(id: "customer", value: customer.id)
                    }
                    
                    Button("Delete", systemImage: "trash") {
                        deleteCustomer = customer
                        confirmDeletionFromContextMenu.toggle()
                    }
                }
            }
            .confirmationDialog("Do you really want to delete \(deleteCustomer?.name ?? "")?", isPresented: $confirmDeletionFromContextMenu, titleVisibility: .visible) {
                Button("Yes", role: .destructive) {
                    if let customer = deleteCustomer {
                        modelContext.delete(customer)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button {
                        openWindow(id: "customer")
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                
                ToolbarItem {
                    Button(action: { openWindow(id: "subject") }) {
                        Label("Subject Matter", systemImage: "pencil.and.list.clipboard")
                    }
                }
                
                ToolbarItem {
                    Button(action: { isProfileVisible.toggle() }) {
                        Label("Account", systemImage: "person.crop.circle")
                    }
                }
            }
        } detail: {
            Group {
                if let customer = selected {
                    InvoicesView(customer: customer, profile: profile)
                }
                else {
                    Text("Select a customer")
                }
            }
            .inspector(isPresented: $isProfileVisible) {
                ProfileView(profile: $profile)
                    .inspectorColumnWidth(min: 450.0, ideal: 500.0, max: 550.0)
            }
            
                
        }
        .navigationTitle(selected?.name ?? "Invoicer")
        .onAppear {
            if profiles.isEmpty {
                profile = Profile()
                modelContext.insert(profile!)
                return
            }
            profile = profiles.last
        }
    }
}
