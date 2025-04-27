//
//  Invoice.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 22.01.2025.
//

import AppKit
import SwiftData

@Model
final class Invoice {
    private(set) var id = UUID()
    var place: String? = nil
    var number: Int = 0
    var startDate = Date.now
    var endDate = Date.now
    var currency = Currency.usd
    @Relationship(deleteRule: .nullify, inverse: \Subject.invoices) var subjectMatter: Subject?
    var quantity: Int = 1
    var price: Double = 0.0
    
    @Relationship var customer: Customer?
    
    init(number: Int, place: String?) {
        self.id = UUID()
        self.place = place
        self.number = number
        self.startDate = .now
        self.endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? .now
        self.currency = .usd
        self.subjectMatter = nil
        self.quantity = 1
        self.price = 0.0
    }
}
