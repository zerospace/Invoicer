//
//  CustomerView.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 21.01.2025.
//

import SwiftUI
import SwiftData

struct CustomerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismissWindow) private var dismissWindow
    private var customer: Customer
    
    init(customer: Customer) {
        self.customer = customer
    }
    
    @State private var hover: Bool = false
    
    var body: some View {
        VStack {
            Form() {
                Section(header:
                    ZStack(alignment: .bottom) {
                        HStack {
                            Spacer()
                            Button {
                                chooseImage()
                            } label: {
                                Image(nsImage: customer.image)
                                    .resizable()
                                    .scaledToFit()
                            }
                            .onHover { hover in
                                self.hover = hover
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            Spacer()
                        }
                        
                        if hover {
                            HStack {
                                Spacer()
                                Text("Edit")
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .frame(height: 25.0)
                            .background(.black.opacity(0.7))
                        }
                    }
                    .frame(height: 100.0)
                    .background(.gray)
                    .clipShape(Circle())
                ) {
                    TextField("Name", text: Binding(get: {
                        return customer.name ?? ""
                    }, set: { customer.name = $0 }))
                    .frame(minWidth: 500.0, idealWidth: 500.0)
                    
                    TextField("Country", text: Binding(get: {
                        return customer.country ?? ""
                    }, set: { customer.country = $0 }))
                    .frame(minWidth: 500.0, idealWidth: 500.0)
                    
                    TextField("ZIP Code", text: Binding(get: {
                        return customer.zip ?? ""
                    }, set: { customer.zip = $0 }))
                    .frame(minWidth: 500.0, idealWidth: 500.0)
                    
                    TextField("City", text: Binding(get: {
                        return customer.city ?? ""
                    }, set: { customer.city = $0 }))
                    .frame(minWidth: 500.0, idealWidth: 500.0)
                    
                    TextField("Street", text: Binding(get: {
                        return customer.street ?? ""
                    }, set: { customer.street = $0 }))
                    .frame(minWidth: 500.0, idealWidth: 500.0)
                    
                    TextField("Region", text: Binding(get: {
                        return customer.region ?? ""
                    }, set: { customer.region = $0 }))
                    .frame(minWidth: 500.0, idealWidth: 500.0)
                    
                    TextField("District", text: Binding(get: {
                        return customer.district ?? ""
                    }, set: { customer.district = $0 }))
                    .frame(minWidth: 500.0, idealWidth: 500.0)
                    
                    Toggle("Represented", isOn: Binding(get: { customer.represented != nil }, set: { customer.represented = $0 ? Represented() : nil }))
                    
                    Toggle("Payer", isOn: Binding(get: { customer.payer != nil }, set: { customer.payer = $0 ? Payer() : nil }))
                }
                
                if customer.represented != nil {
                    Section(header: Text("Customer Represented")) {
                        TextField("Name", text: Binding(get: {
                            return customer.represented?.name ?? ""
                        }, set: { customer.represented?.name = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                        
                        TextField("Info", text: Binding(get: {
                            return customer.represented?.info ?? ""
                        }, set: { customer.represented?.info = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                    }
                }
                
                if customer.payer != nil {
                    Section(header: Text("Payer")) {
                        TextField("Name", text: Binding(get: {
                            return customer.payer?.name ?? ""
                        }, set: { customer.payer?.name = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                        
                        TextField("Country", text: Binding(get: {
                            return customer.payer?.country ?? ""
                        }, set: { customer.payer?.country = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                        
                        TextField("ZIP Code", text: Binding(get: {
                            return customer.payer?.zip ?? ""
                        }, set: { customer.payer?.zip = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                        
                        TextField("City", text: Binding(get: {
                            return customer.payer?.city ?? ""
                        }, set: { customer.payer?.city = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                        
                        TextField("Street", text: Binding(get: {
                            return customer.payer?.street ?? ""
                        }, set: { customer.payer?.street = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                        
                        TextField("Region", text: Binding(get: {
                            return customer.payer?.region ?? ""
                        }, set: { customer.payer?.region = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                        
                        TextField("District", text: Binding(get: {
                            return customer.payer?.district ?? ""
                        }, set: { customer.payer?.district = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                        
                        Toggle("Represented", isOn: Binding(get: { customer.payer?.represented != nil }, set: { customer.payer?.represented = $0 ? Represented() : nil }))
                    }
                }
                
                if customer.payer?.represented != nil {
                    Section(header: Text("Payer Represented")) {
                        TextField("Name", text: Binding(get: {
                            return customer.payer?.represented?.name ?? ""
                        }, set: { customer.payer?.represented?.name = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                        
                        TextField("Info", text: Binding(get: {
                            return customer.payer?.represented?.info ?? ""
                        }, set: { customer.payer?.represented?.info = $0 }))
                        .frame(minWidth: 500.0, idealWidth: 500.0)
                    }
                }
            }
            .formStyle(.grouped)
            .padding(.horizontal)
            
            Button {
                modelContext.insert(customer)
                dismissWindow()
            } label: {
                Label("Add", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
    
    // MARK: - Private
    private func chooseImage() {
        let panel = NSOpenPanel()
        panel.prompt = "Select Image"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        Task {
            let result = await panel.begin()
            if result == .OK, let url = panel.url {
                customer.imageData = try? Data(contentsOf: url)
            }
        }
    }
}
