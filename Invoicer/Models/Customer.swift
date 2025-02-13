//
//  Customer.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 21.01.2025.
//

import AppKit
import SwiftData

struct Represented: Codable {
    var name: String?
    var noteEng: String?
    var noteUkr: String?
}

@Model
final class Customer {
    private(set) var id = UUID()
    var name: String?
    var zip: String?
    var street: String?
    var city: String?
    var country: String?
    var region: String?
    var district: String?
    @Attribute(.externalStorage) var imageData: Data?
    var represented: Represented?
    @Relationship(deleteRule: .cascade, inverse: \Payer.customer) var payer: Payer?
    @Relationship(deleteRule: .cascade, inverse: \Invoice.customer) var invoices: [Invoice]? = [Invoice]()
    
    var image: NSImage {
        if let data = imageData {
            return NSImage(data: data)!
        }
        return NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: nil)!.withSymbolConfiguration(.init(pointSize: 44.0, weight: .regular, scale: .large))!
    }
    
    var address: String {
        var parts = [String]()
        if let street = street { parts.append(street) }
        if let city = city { parts.append(city) }
        if let district = district { parts.append(district) }
        if let region = region { parts.append(region) }
        if let zip = zip { parts.append(zip) }
        if let country = country { parts.append(country) }
        return parts.joined(separator: ", ")
    }
    
    init() {
        id = UUID()
        name = nil
        zip = nil
        street = nil
        imageData = nil
        represented = nil
        city = nil
        country = nil
        region = nil
        district = nil
    }
}

@Model
final class Payer {
    private(set) var id = UUID()
    var name: String?
    var zip: String?
    var street: String?
    var city: String?
    var country: String?
    var region: String?
    var district: String?
    var represented: Represented?
    @Relationship weak var customer: Customer? = nil
    
    var address: String {
        var parts = [String]()
        if let street = street { parts.append(street) }
        if let city = city { parts.append(city) }
        if let district = district { parts.append(district) }
        if let region = region { parts.append(region) }
        if let zip = zip { parts.append(zip) }
        if let country = country { parts.append(country) }
        return parts.joined(separator: ", ")
    }
    
    init() {
        id = UUID()
        name = nil
        zip = nil
        street = nil
        represented = nil
        city = nil
        country = nil
        region = nil
        district = nil
    }
}
