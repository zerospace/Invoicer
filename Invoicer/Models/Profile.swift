//
//  Profile.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 17.01.2025.
//

import SwiftData

@Model
final class Profile {
    var lastName: String?
    var firstName: String?
    var patronymic: String?
    var isFop: Bool = false
    var zip: String?
    var addressLine: String?
    var region: String?
    var district: String?
    var city: String?
    var taxNumber: String?
    
    init() {
        self.lastName = nil
        self.firstName = nil
        self.patronymic = nil
        self.isFop = false
        self.zip = nil
        self.addressLine = nil
        self.region = nil
        self.district = nil
        self.city = nil
        self.taxNumber = nil
    }
}
