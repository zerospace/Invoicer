//
//  InvoicesView.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 22.01.2025.
//

import SwiftUI
import SwiftData
import PDFKit

struct InvoicesView: View {
    @Environment(\.modelContext) private var modelContext
    
    private let customer: Customer
    private let profile: Profile?
    private let invoices: [Invoice]
    private let numberFormatter: NumberFormatter
    
    @Query private var subjects: [Subject]
    @State private var toEdit: Invoice? = nil
    @State private var toDelete: Invoice? = nil
    @State private var confirmDeletion: Bool = false
    
    @State private var pdf: Data? = nil
    
    init(customer: Customer, profile: Profile?) {
        self.customer = customer
        self.profile = profile
        self.invoices = customer.invoices?.sorted(by: { $0.number < $1.number }) ?? []
        
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .decimal
        self.numberFormatter.minimumFractionDigits = 2
        self.numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View {
        List(invoices.reversed()) { invoice in
            HStack {
                VStack(alignment: .leading) {
                    Text("Invoice #\(invoice.number)")
                        .font(.headline)
                    Text(invoice.startDate, style: .date)
                        .font(.subheadline)
                }
                .padding()
                
                Spacer()
                
                Text(Decimal(Double(invoice.quantity) * invoice.price), format: .currency(code: invoice.currency.rawValue))
                    .font(.title2)
                    .padding()
                
                Menu("", systemImage: "ellipsis") {
                    Button("Delete", systemImage: "trash") {
                        toDelete = invoice
                        confirmDeletion.toggle()
                    }
                    
                    if let profile = profile {
                        Button("Export to PDF", systemImage: "document.fill") {
                            pdf = PDFCreator().generate(invoice: invoice, customer: customer, profile: profile)
                            let panel = NSSavePanel()
                            panel.allowedContentTypes = [.pdf]
                            panel.canCreateDirectories = true
                            panel.isExtensionHidden = false
                            panel.title = "Save Invoice #\(invoice.number) as PDF"
                            panel.nameFieldLabel = "PDF file name:"
                            let response = panel.runModal()
                            if response == .OK, let url = panel.url {
                                try? pdf?.write(to: url)
                            }
                        }
                    }
                }
                .menuStyle(.button)
                .buttonStyle(.borderless)
                .menuIndicator(.hidden)
                .padding(.trailing)

            }
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.gray.opacity(toEdit == invoice ? 1.0 : 0.3), lineWidth: 1)
            }
            .listRowSeparator(.hidden)
            .contentShape(Rectangle())
            .onTapGesture {
                toEdit = invoice
            }
            .confirmationDialog("Do you really want to delete Invoice #\(toDelete?.number ?? 0)?", isPresented: $confirmDeletion, titleVisibility: .visible) {
                Button("Yes", role: .destructive) {
                    if let item = toDelete {
                        modelContext.delete(item)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    let last = invoices.last
                    let invoice = Invoice(number: (last?.number ?? 0) + 1, place: last?.place)
                    customer.invoices?.append(invoice)
                    modelContext.insert(invoice)
                    toEdit = invoice
                } label: {
                    Label("Add Invoice", systemImage: "plus")
                }
            }
        }
        .inspector(isPresented: Binding(get: { toEdit != nil }, set: { if !$0 { toEdit = nil } })) {
            VStack {
                Form {
                    Section {
                        TextField("Number", value: Binding(get: { toEdit?.number ?? 0 }, set: { toEdit?.number = $0 }), format: .number)
                        TextField("Place", text: Binding(get: { toEdit?.place ?? "" }, set: { toEdit?.place = $0 }))
                        DatePicker("Start Date", selection: Binding(get: { toEdit?.startDate ?? .now }, set: { toEdit?.startDate = $0 }), displayedComponents: [.date])
                        DatePicker("End Date", selection: Binding(get: { toEdit?.endDate ?? .now }, set: { toEdit?.endDate = $0 }), displayedComponents: [.date])
                        Picker("Currency", selection: Binding(get: { toEdit?.currency ?? .usd }, set: { toEdit?.currency = $0 })) {
                            ForEach(Currency.allCases, id: \.self) { item in
                                Text(item.rawValue.uppercased())
                            }
                        }
                        Picker("Subject Matter", selection: Binding(get: { toEdit?.subjectMatter }, set: { toEdit?.subjectMatter = $0 })) {
                            ForEach(subjects) { item in
                                Text(item.engName ?? "Unknown")
                                    .tag(item)
                            }
                        }
                        TextField("Quantity", value: Binding(get: { toEdit?.quantity ?? 1 }, set: { toEdit?.quantity = $0 }), format: .number)
                        TextField("Price", value: Binding(get: { toEdit?.price ?? 0.0 }, set: { toEdit?.price = $0 }), formatter: numberFormatter)
                    }
                }
                
                Button("Close") {
                    toEdit = nil
                }
                .padding()
            }
        }
        .inspector(isPresented: Binding(get: { pdf != nil }, set: { if !$0 { pdf = nil } })) {
            if let doc = pdf {
                PDFKitView(data: doc)
                Button("Close") {
                    pdf = nil
                }
            }
            else {
                EmptyView()
            }
        }
    }
}
