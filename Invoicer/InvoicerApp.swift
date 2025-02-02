//
//  InvoicerApp.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 07.01.2025.
//

import SwiftUI
import SwiftData

@main
struct InvoicerApp: App {
    private let modelContainer: ModelContainer
    
    init() {
        let schema = Schema([
            Profile.self,
            Customer.self,
            Payer.self,
            Subject.self,
            InvoiceSubjectMatter.self,
            Invoice.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
//            try modelContainer.mainContext.delete(model: Profile.self)
//            try modelContainer.mainContext.delete(model: Customer.self)
//            try modelContainer.mainContext.delete(model: Payer.self)
//            try modelContainer.mainContext.delete(model: InvoiceSubjectMatter.self)
//            try modelContainer.mainContext.delete(model: Invoice.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
        
        WindowGroup("Customer", id: "customer", for: UUID.self) { id in
            if let customerId = id.wrappedValue {
                let descriptor = FetchDescriptor<Customer>(predicate: #Predicate { $0.id == customerId })
                if let customer = try? modelContainer.mainContext.fetch(descriptor).first {
                    CustomerView(customer: customer)
                }
            }
            else {
                CustomerView(customer: Customer())
            }
        }
        .modelContainer(modelContainer)
        .windowResizability(.contentSize)
        
        WindowGroup("Subject Matter", id: "subject") {
            SubjectMatterView()
        }
        .modelContainer(modelContainer)
    }
}
