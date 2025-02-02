//
//  ProfileView.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 17.01.2025.
//

import SwiftUI

struct ProfileView: View {
    @Binding var profile: Profile?
    
    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                TextField("Last Name", text: Binding(get: {
                    return profile?.lastName ?? ""
                }, set: { profile?.lastName = $0 }))
                
                TextField("First Name", text: Binding(get: {
                    return profile?.firstName ?? ""
                }, set: { profile?.firstName = $0 }))
                
                TextField("Patronymic", text: Binding(get: {
                    return profile?.patronymic ?? ""
                }, set: { profile?.patronymic = $0 }))
                
                Toggle("Individual Entrepreneur", isOn: Binding(get: {
                    return profile?.isFop ?? false
                }, set: { profile?.isFop = $0 }))
                
                TextField("ZIP Code", text: Binding(get: {
                    return profile?.zip ?? ""
                }, set: { profile?.zip = $0 }))
                
                TextField("Region", text: Binding(get: {
                    return profile?.region ?? ""
                }, set: { profile?.region = $0 }))
                
                TextField("District", text: Binding(get: {
                    return profile?.district ?? ""
                }, set: { profile?.district = $0 }))
                
                TextField("City", text: Binding(get: {
                    return profile?.city ?? ""
                }, set: { profile?.city = $0 }))
                
                TextField("Address", text: Binding(get: {
                    return profile?.addressLine ?? ""
                }, set: { profile?.addressLine = $0 }))
                
                TextField("Individual Tax Number", text: Binding(get: {
                    return profile?.taxNumber ?? ""
                }, set: { profile?.taxNumber = $0 }))
            }
        }
    }
}
