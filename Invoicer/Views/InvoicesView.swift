//
//  InvoicesView.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 22.01.2025.
//

import SwiftUI
import SwiftData

struct InvoicesView: View {
    @Environment(\.modelContext) private var modelContext
    
    private let customer: Customer
    private let invoices: [Invoice]
    private let numberFormatter: NumberFormatter
    
    @Query private var subjects: [Subject]
    @State private var toEdit: Invoice? = nil
    @State private var toDelete: Invoice? = nil
    @State private var confirmDeletion: Bool = false
    
    init(customer: Customer) {
        self.customer = customer
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
                
                Text(invoice.subjectMatters?.reduce(Decimal(0.0), { $0 + Decimal($1.price) }) ?? Decimal(0.0), format: .currency(code: "USD"))
                    .font(.title2)
                    .padding()
                
                Menu("", systemImage: "ellipsis") {
                    Button("Delete", systemImage: "trash") {
                        toDelete = invoice
                        confirmDeletion.toggle()
                    }
                    Button("Save as PDF", systemImage: "document.fill") {
                        
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
                        Button("Add Subject Matter") {
                            let subject = InvoiceSubjectMatter(invoice: toEdit)
                            toEdit?.subjectMatters?.append(subject)
                            modelContext.insert(subject)
                        }
                    }
                    
                    if let subjectMatters = toEdit?.subjectMatters {
                        ForEach(subjectMatters) { subjectMatter in
                            Section {
                                Picker("Subject", selection: Binding(get: { subjectMatter.subject }, set: { subjectMatter.subject = $0 })) {
                                    ForEach(subjects) { item in
                                        Text(item.engName ?? "Unknown")
                                            .tag(item)
                                    }
                                }
                                TextField("Quantity", value: Binding(get: { subjectMatter.quantity }, set: { subjectMatter.quantity = $0 }), format: .number)
                                TextField("Price", value: Binding(get: { subjectMatter.price }, set: { subjectMatter.price = $0 }), formatter: numberFormatter)
                                Button("Delete") {
                                    modelContext.delete(subjectMatter)
                                }
                            }
                        }
                    }
                }
                
                Button("Close") {
                    toEdit = nil
                }
                .padding()
            }
        }
    }
}
