//
//  PDFKitView.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 04.02.2025.
//

import SwiftUI
import PDFKit

struct PDFKitView: NSViewRepresentable {
    let data: Data
    
    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = PDFDocument(data: data)
        view.autoScales = true
        return view
    }
    
    func updateNSView(_ nsView: PDFView, context: Context) {
        nsView.document = PDFDocument(data: data)
    }
}
