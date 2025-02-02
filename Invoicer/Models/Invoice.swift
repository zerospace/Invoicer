//
//  Invoice.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 22.01.2025.
//

import AppKit
import SwiftData

enum Currency: String, Codable, CaseIterable {
    case usd, eur, uah
    
    var ukrName: String {
        switch self {
        case .usd: "доларів США"
        case .eur: "євро"
        case .uah: "грн"
        }
    }
    
    var engName: String {
        switch self {
        case .usd: "United States dollars"
        case .eur: "euros"
        case .uah: "hryvnias"
        }
    }
}

@Model
final class Invoice {
    private(set) var id = UUID()
    var place: String? = nil
    var number: Int = 0
    var startDate = Date.now
    var endDate = Date.now
    var currency = Currency.usd
    @Relationship(deleteRule: .cascade, inverse: \InvoiceSubjectMatter.invoice) var subjectMatters: [InvoiceSubjectMatter]? = [InvoiceSubjectMatter]()
    @Relationship var customer: Customer?
    
    init(number: Int, place: String?) {
        self.id = UUID()
        self.place = place
        self.number = number
        self.startDate = .now
        self.endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? .now
        self.currency = .usd
        self.subjectMatters = [InvoiceSubjectMatter]()
    }
}
