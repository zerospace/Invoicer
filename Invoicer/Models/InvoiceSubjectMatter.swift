//
//  InvoiceSubjectMatter.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 31.01.2025.
//

import AppKit
import SwiftData

@Model
final class InvoiceSubjectMatter {
    private(set) var id = UUID()
    @Relationship(deleteRule: .noAction) var subject: Subject? = nil
    @Relationship(deleteRule: .noAction) var invoice: Invoice? = nil
    
    var quantity: Int = 1
    var price: Double = 0.0
    
    init(invoice: Invoice?) {
        self.id = UUID()
        self.invoice = invoice
        self.subject = nil
        self.quantity = 1
        self.price = 0.0
    }
}
