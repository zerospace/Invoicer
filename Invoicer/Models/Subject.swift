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
    
    @Relationship var invoices: [Invoice]?
    
    init() {
        id = UUID()
        ukrName = nil
        engName = nil
    }
}
