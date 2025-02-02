//
//  Subject.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 31.01.2025.
//

import AppKit
import SwiftData

@Model
final class Subject {
    private(set) var id = UUID()
    var ukrName: String?
    var engName: String?
    @Relationship(deleteRule: .cascade, inverse: \InvoiceSubjectMatter.subject) var invoiceSubject: [InvoiceSubjectMatter]? = [InvoiceSubjectMatter]()
    
    init() {
        id = UUID()
        ukrName = nil
        engName = nil
        invoiceSubject = [InvoiceSubjectMatter]()
    }
}
