//
//  Currency.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 14.02.2025.
//

import Foundation

enum Currency: String, Codable, CaseIterable {
    case usd, eur, uah
    
    var englishNameInWords: String {
        switch self {
        case .usd: "United States dollars"
        case .eur: "euros"
        case .uah: "hryvnias"
        }
    }
    
    var englishFraction: String {
        switch self {
        case .usd: "cents"
        case .eur: "cents"
        case .uah: "kopiyok"
        }
    }
    
    var ukrainianNameInWords: String {
        switch self {
        case .usd: "доларів США"
        case .eur: "євро"
        case .uah: "гривень"
        }
    }
    
    var ukrainianFraction: String {
        switch self {
        case .usd: "центів"
        case .eur: "центів"
        case .uah: "копійок"
        }
    }
}
