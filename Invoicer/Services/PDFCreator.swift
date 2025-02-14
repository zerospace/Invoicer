//
//  PDFCreator.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 03.02.2025.
//

import Cocoa
import PDFKit

final class PDFCreator {
    private let dateFormatter = DateFormatter()
    private let englishNumberFormatter = NumberFormatter()
    private let ukrainianNumberFormatter = NumberFormatter()
    private let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
    
    func generate(invoice: Invoice, customer: Customer, profile: Profile) -> Data {
        let insets = NSEdgeInsets(top: 35, left: 85, bottom: 21, right: 43)
        let innerRect = pageRect.inset(by: insets)
        var pageYOffset = insets.top
        let tableOffset = 5.0
        let offset = 25.0
        let centerX = innerRect.width / 2
        
        let total = Double(invoice.quantity) * invoice.price
        let currencyString = invoice.currency.rawValue.uppercased()
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        englishNumberFormatter.numberStyle = .spellOut
        englishNumberFormatter.locale = Locale(identifier: "en_US")
        
        ukrainianNumberFormatter.numberStyle = .spellOut
        ukrainianNumberFormatter.locale = Locale(identifier: "uk_UA")
        
        let cfMutableData = CFDataCreateMutable(kCFAllocatorDefault, 0)!
        var mediaBox = pageRect
        if let consumer = CGDataConsumer(data: cfMutableData), let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) {
            NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: true)
            context.beginPDFPage([kCGPDFContextMediaBox as CFString : pageRect] as CFDictionary)
            
            context.translateBy(x: 0, y: pageRect.height)
            context.scaleBy(x: 1, y: -1)
            
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont(name: "Arial Narrow Bold", size: 10) ?? .boldSystemFont(ofSize: 10),
                .foregroundColor: NSColor.black,
            ]
            let regularAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont(name: "Arial Narrow", size: 10) ?? .systemFont(ofSize: 10),
                .foregroundColor: NSColor.black,
            ]
            let termsAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont(name: "Arial Narrow", size: 8) ?? .systemFont(ofSize: 8),
                .foregroundColor: NSColor.black,
            ]
            
            // MARK: - Title
            let title = NSAttributedString(string: "Invoice (offer) / Інвойс (оферта) № \(invoice.number)", attributes: boldAttributes)
            let titleSize = title.size()
            title.draw(at: CGPoint(x: innerRect.midX - (titleSize.width / 2), y: pageYOffset))
            pageYOffset += offset
            let topMainTable = pageYOffset
            
            drawLine(from: CGPoint(x: insets.left, y: pageYOffset), to: CGPoint(x: pageRect.width - insets.right, y: pageYOffset), in: context)
            
            // MARK: - Date and Place
            let dateEng = NSMutableAttributedString(string: "Date and Place: ", attributes: boldAttributes)
            let dateUkr = NSMutableAttributedString(string: "Дата та місце: ", attributes: boldAttributes)
            let date = dateFormatter.string(from: invoice.startDate)
            dateEng.append(NSAttributedString(string: date, attributes: regularAttributes))
            dateUkr.append(NSAttributedString(string: date, attributes: regularAttributes))
            if let place = invoice.place {
                dateEng.append(NSAttributedString(string: ", " + place, attributes: regularAttributes))
                dateUkr.append(NSAttributedString(string: ", " + place, attributes: regularAttributes))
            }
            let dateEngSize = dateEng.size()
            let dateEngRect = CGRect(x: insets.left + tableOffset, y: pageYOffset + tableOffset, width: centerX - tableOffset * 2, height: dateEngSize.height + tableOffset * 2)
            dateEng.draw(in: dateEngRect)
            let dateUkrSize = dateUkr.size()
            let dateUkrRect = CGRect(x: centerX + insets.left + tableOffset, y: pageYOffset + tableOffset, width: centerX - tableOffset * 2, height: dateUkrSize.height + tableOffset * 2)
            dateUkr.draw(in: dateUkrRect)
            
            pageYOffset += dateEngSize.height + tableOffset * 2
            drawLine(from: CGPoint(x: innerRect.maxX, y: pageYOffset), to: CGPoint(x: insets.left, y: pageYOffset), in: context)
            
            // MARK: -  Supplier
            let supplierEng = NSMutableAttributedString(string: "Supplier: ", attributes: boldAttributes)
            let supplierUkr = NSMutableAttributedString(string: "Виконавець: ", attributes: boldAttributes)
            if profile.isFop {
                supplierEng.append(NSAttributedString(string: "Individual Entrepreneur ", attributes: regularAttributes))
                supplierUkr.append(NSAttributedString(string: "ФОП ", attributes: regularAttributes))
            }
            if let lastName = profile.lastName, let firstName = profile.firstName, let patronymic = profile.patronymic {
                supplierEng.append(NSAttributedString(string: lastName.transliterate + " " + firstName.transliterate + "\n", attributes: regularAttributes))
                supplierUkr.append(NSAttributedString(string: lastName + " " + firstName + " " + patronymic + "\n", attributes: regularAttributes))
            }
            supplierEng.append(NSAttributedString(string: "address: " + profile.address.transliterate, attributes: regularAttributes))
            supplierUkr.append(NSAttributedString(string: "що проживає за адресою " + profile.address, attributes: regularAttributes))
            if let taxNumber = profile.taxNumber {
                supplierEng.append(NSAttributedString(string: "\nIndividual Tax Number - " + taxNumber, attributes: regularAttributes))
                supplierUkr.append(NSAttributedString(string: "\nІПН - " + taxNumber, attributes: regularAttributes))
            }
            
            let supplierEngTextRect = CGRect(x: innerRect.minX, y: pageYOffset, width: centerX, height: .greatestFiniteMagnitude).insetBy(dx: tableOffset, dy: tableOffset)
            let supplierEngBounds = supplierEng.boundingRect(with: supplierEngTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            let supplierEngRect = CGRect(origin: supplierEngTextRect.origin, size: supplierEngBounds.size)
            supplierEng.draw(in: supplierEngRect)
            
            let supplierUkrTextRect = CGRect(x: centerX + insets.left, y: pageYOffset, width: centerX, height: .greatestFiniteMagnitude).insetBy(dx: tableOffset, dy: tableOffset)
            let supplierUkrBounds = supplierUkr.boundingRect(with: supplierUkrTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            let supplierUkrRect = CGRect(origin: supplierUkrTextRect.origin, size: supplierUkrBounds.size)
            supplierUkr.draw(in: supplierUkrRect)
            
            pageYOffset += max(supplierEngRect.height, supplierUkrRect.height) + tableOffset * 2
            drawLine(from: CGPoint(x: innerRect.maxX, y: pageYOffset), to: CGPoint(x: insets.left, y: pageYOffset), in: context)
            
            // MARK: - Customer
            let customerEng = NSMutableAttributedString(string: "Customer: ", attributes: boldAttributes)
            let customerUkr = NSMutableAttributedString(string: "Замовник: ", attributes: boldAttributes)
            if let name = customer.name {
                customerEng.append(NSAttributedString(string: name + "\n", attributes: regularAttributes))
                customerUkr.append(NSAttributedString(string: name + "\n", attributes: regularAttributes))
            }
            customerEng.append(NSAttributedString(string: customer.address, attributes: regularAttributes))
            customerUkr.append(NSAttributedString(string: customer.address, attributes: regularAttributes))
            if let represented = customer.represented {
                customerEng.append(NSAttributedString(string: "\nRepresented by ", attributes: regularAttributes))
                customerUkr.append(NSAttributedString(string: "\nв особі ", attributes: regularAttributes))
                if let name = represented.name {
                    customerEng.append(NSAttributedString(string: name, attributes: regularAttributes))
                    customerUkr.append(NSAttributedString(string: name, attributes: regularAttributes))
                    if let note = represented.noteEng {
                        customerEng.append(NSAttributedString(string: ", " + note, attributes: regularAttributes))
                    }
                    if let note = represented.noteUkr {
                        customerUkr.append(NSAttributedString(string: ", " + note, attributes: regularAttributes))
                    }
                }
            }
            
            let customerEngTextRect = CGRect(x: innerRect.minX, y: pageYOffset, width: centerX, height: .greatestFiniteMagnitude).insetBy(dx: tableOffset, dy: tableOffset)
            let customerEngBounds = customerEng.boundingRect(with: customerEngTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            let customerEngRect = CGRect(origin: customerEngTextRect.origin, size: customerEngBounds.size)
            customerEng.draw(in: customerEngRect)
            
            let customerUkrTextRect = CGRect(x: centerX + insets.left, y: pageYOffset, width: centerX, height: .greatestFiniteMagnitude).insetBy(dx: tableOffset, dy: tableOffset)
            let customerUkrBounds = customerUkr.boundingRect(with: customerUkrTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            let customerUkrRect = CGRect(origin: customerUkrTextRect.origin, size: customerUkrBounds.size)
            customerUkr.draw(in: customerUkrRect)
            
            pageYOffset += max(customerEngRect.height, customerUkrRect.height) + tableOffset * 2
            drawLine(from: CGPoint(x: innerRect.maxX, y: pageYOffset), to: CGPoint(x: insets.left, y: pageYOffset), in: context)
            
            // MARK: - Payer
            if let payer = customer.payer {
                let payerEng = NSMutableAttributedString(string: "Payer (authorized by Customer to make payments):\n", attributes: boldAttributes)
                let payerUkr = NSMutableAttributedString(string: "Платник (повірена особа Замовника щодо розрахунків):\n", attributes: boldAttributes)
                if let name = payer.name {
                    payerEng.append(NSAttributedString(string: name + "\n", attributes: regularAttributes))
                    payerUkr.append(NSAttributedString(string: name + "\n", attributes: regularAttributes))
                    if let customer = customer.name {
                        payerEng.append(NSAttributedString(string: "(on behalf of \(customer))\n", attributes: regularAttributes))
                        payerUkr.append(NSAttributedString(string: "(від імені \(customer))\n", attributes: regularAttributes))
                    }
                }
                
                payerEng.append(NSAttributedString(string: payer.address, attributes: regularAttributes))
                payerUkr.append(NSAttributedString(string: payer.address, attributes: regularAttributes))
                
                if let represented = payer.represented {
                    payerEng.append(NSAttributedString(string: "\nRepresented by ", attributes: regularAttributes))
                    payerUkr.append(NSAttributedString(string: "\nв особі ", attributes: regularAttributes))
                    if let name = represented.name {
                        payerEng.append(NSAttributedString(string: name, attributes: regularAttributes))
                        payerUkr.append(NSAttributedString(string: name, attributes: regularAttributes))
                        if let note = represented.noteEng {
                            payerEng.append(NSAttributedString(string: ", " + note, attributes: regularAttributes))
                        }
                        if let note = represented.noteUkr {
                            payerUkr.append(NSAttributedString(string: ", " + note, attributes: regularAttributes))
                        }
                    }
                }
                
                let payerEngTextRect = CGRect(x: innerRect.minX, y: pageYOffset, width: centerX, height: .greatestFiniteMagnitude).insetBy(dx: tableOffset, dy: tableOffset)
                let payerEngBounds = payerEng.boundingRect(with: payerEngTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
                let payerEngRect = CGRect(origin: payerEngTextRect.origin, size: payerEngBounds.size)
                payerEng.draw(in: payerEngRect)
                
                let payerUkrTextRect = CGRect(x: centerX + insets.left, y: pageYOffset, width: centerX, height: .greatestFiniteMagnitude).insetBy(dx: tableOffset, dy: tableOffset)
                let payerUkrBounds = payerUkr.boundingRect(with: payerUkrTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
                let payerUkrRect = CGRect(origin: payerUkrTextRect.origin, size: payerUkrBounds.size)
                payerUkr.draw(in: payerUkrRect)
                
                pageYOffset += max(payerEngRect.height, payerUkrRect.height) + tableOffset * 2
                drawLine(from: CGPoint(x: innerRect.maxX, y: pageYOffset), to: CGPoint(x: insets.left, y: pageYOffset), in: context)
            }
            
            // MARK: - Subject Matter
            let subjectMatterEng = NSMutableAttributedString(string: "Subject Matter: ", attributes: boldAttributes)
            let subjectMatterUkr = NSMutableAttributedString(string: "Предмет: ", attributes: boldAttributes)
            
            if let subject = invoice.subjectMatter {
                if let name = subject.engName {
                    subjectMatterEng.append(NSAttributedString(string: name, attributes: regularAttributes))
                }
                if let name = subject.ukrName {
                    subjectMatterUkr.append(NSAttributedString(string: name, attributes: regularAttributes))
                }
            }
            
            let subjectEngTextRect = CGRect(x: innerRect.minX, y: pageYOffset, width: centerX, height: .greatestFiniteMagnitude).insetBy(dx: tableOffset, dy: tableOffset)
            let subjectEngBounds = subjectMatterEng.boundingRect(with: subjectEngTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            let subjectEngRect = CGRect(origin: subjectEngTextRect.origin, size: subjectEngBounds.size)
            subjectMatterEng.draw(in: subjectEngRect)
            
            let subjectUkrTextRect = CGRect(x: centerX + insets.left, y: pageYOffset, width: centerX, height: .greatestFiniteMagnitude).insetBy(dx: tableOffset, dy: tableOffset)
            let subjectUkrBounds = subjectMatterUkr.boundingRect(with: subjectUkrTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            let subjectUkrRect = CGRect(origin: subjectUkrTextRect.origin, size: subjectUkrBounds.size)
            subjectMatterUkr.draw(in: subjectUkrRect)
            
            pageYOffset += max(subjectEngRect.height, subjectUkrRect.height) + tableOffset * 2
            drawLine(from: CGPoint(x: innerRect.maxX, y: pageYOffset), to: CGPoint(x: insets.left, y: pageYOffset), in: context)
            
            // MARK: -  Currency
            let currencyEng = NSMutableAttributedString(string: "Currency: ", attributes: boldAttributes)
            currencyEng.append(NSAttributedString(string: currencyString, attributes: regularAttributes))
            currencyEng.draw(at: CGPoint(x: innerRect.minX + tableOffset, y: pageYOffset + tableOffset))
            
            let currencyUkr = NSMutableAttributedString(string: "Валюта: ", attributes: boldAttributes)
            currencyUkr.append(NSAttributedString(string: invoice.currency.rawValue.uppercased(), attributes: regularAttributes))
            currencyUkr.draw(at: CGPoint(x: centerX + insets.left + tableOffset, y: pageYOffset + tableOffset))
            
            pageYOffset += currencyEng.size().height + tableOffset * 2
            drawLine(from: CGPoint(x: innerRect.maxX, y: pageYOffset), to: CGPoint(x: insets.left, y: pageYOffset), in: context)
            
            //MARK: - Price
            let priceEng = NSMutableAttributedString(string: "Price (amount) of the goods/services: ", attributes: boldAttributes)
            priceEng.append(NSAttributedString(string: String(format: "%.2f", total), attributes: regularAttributes))
            priceEng.draw(at: CGPoint(x: innerRect.minX + tableOffset, y: pageYOffset + tableOffset))
            
            let priceUkr = NSMutableAttributedString(string: "Ціна (загальна вартість) товарів/послуг: ", attributes: boldAttributes)
            priceUkr.append(NSAttributedString(string: String(format: "%.2f", total), attributes: regularAttributes))
            priceUkr.draw(at: CGPoint(x: centerX + insets.left + tableOffset, y: pageYOffset + tableOffset))
            
            pageYOffset += priceEng.size().height + tableOffset * 2
            drawLine(from: CGPoint(x: innerRect.maxX, y: pageYOffset), to: CGPoint(x: insets.left, y: pageYOffset), in: context)
            
            // MARK: - Terms of payments
            let paymentTermsEng = NSMutableAttributedString(string: "Terms of payments and acceptation: ", attributes: boldAttributes)
            paymentTermsEng.append(NSAttributedString(string: "Postpayment of 100% upon the services delivery. The services being rendered at the location of the Customer.", attributes: regularAttributes))
            let paymentTermsEngTextRect = CGRect(x: innerRect.minX, y: pageYOffset, width: centerX, height: .greatestFiniteMagnitude).insetBy(dx: tableOffset, dy: tableOffset)
            let paymentTermsEngBounds = paymentTermsEng.boundingRect(with: paymentTermsEngTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            let paymentTermsEngRect = CGRect(origin: paymentTermsEngTextRect.origin, size: paymentTermsEngBounds.size)
            paymentTermsEng.draw(in: paymentTermsEngRect)
            
            let paymentTermsUkr = NSMutableAttributedString(string: "Умови оплати та передачі: ", attributes: boldAttributes)
            paymentTermsUkr.append(NSAttributedString(string: "100% післяплата за фактом виконання послуг. Послуги надаються за місцем реєстрації Замовника.", attributes: regularAttributes))
            let paymentTermsUkrTextRect = CGRect(x: centerX + insets.left, y: pageYOffset, width: centerX, height: .greatestFiniteMagnitude).insetBy(dx: tableOffset, dy: tableOffset)
            let paymentTermsUkrBounds = paymentTermsUkr.boundingRect(with: paymentTermsUkrTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            let paymentTermsUkrRect = CGRect(origin: paymentTermsUkrTextRect.origin, size: paymentTermsUkrBounds.size)
            paymentTermsUkr.draw(in: paymentTermsUkrRect)
            
            pageYOffset += max(paymentTermsEngRect.height, paymentTermsUkrRect.height) + tableOffset * 2
            drawLine(from: CGPoint(x: innerRect.maxX, y: pageYOffset), to: CGPoint(x: insets.left, y: pageYOffset), in: context)
            drawLine(from: CGPoint(x: innerRect.maxX, y: pageYOffset), to: CGPoint(x: innerRect.maxX, y: topMainTable), in: context)
            drawLine(from: CGPoint(x: innerRect.minX, y: pageYOffset), to: CGPoint(x: innerRect.minX, y: topMainTable), in: context)
            drawLine(from: CGPoint(x: centerX + insets.left, y: pageYOffset), to: CGPoint(x: centerX + insets.left, y: topMainTable), in: context)
            
            pageYOffset += 10.0
            let secondTableTop = pageYOffset
            
            // MARK: - Second table
            drawLine(from: CGPoint(x: innerRect.maxX, y: pageYOffset), to: CGPoint(x: insets.left, y: pageYOffset), in: context)
            
            var xOffset = innerRect.minX + tableOffset
            pageYOffset += tableOffset
            
            let countTitle = NSAttributedString(string: "№", attributes: regularAttributes)
            countTitle.draw(at: CGPoint(x: xOffset, y: pageYOffset))
            xOffset += innerRect.width * 0.05
            let firstRowX = xOffset
            xOffset += tableOffset
            
            let descriptionTitle = NSAttributedString(string: "Description/\nОпис", attributes: regularAttributes)
            descriptionTitle.draw(at: CGPoint(x: xOffset, y: pageYOffset))
            xOffset += innerRect.width * 0.44
            let secondRowX = xOffset
            xOffset += tableOffset
            
            let quantityTitle = NSAttributedString(string: "Quantity/\nКількість", attributes: regularAttributes)
            quantityTitle.draw(at: CGPoint(x: xOffset, y: pageYOffset))
            xOffset += innerRect.width * 0.1
            let thirdRowX = xOffset
            xOffset += tableOffset
            
            let priceTitle = NSAttributedString(string: "Price, \(currencyString)/\nЦіна, \(currencyString)", attributes: regularAttributes)
            priceTitle.draw(at: CGPoint(x: xOffset, y: pageYOffset))
            xOffset += innerRect.width * 0.15
            let fourthRowX = xOffset
            xOffset += tableOffset
            
            let amountTitle = NSAttributedString(string: "Amount, \(currencyString)/\nЗагальна вартість, \(currencyString)", attributes: regularAttributes)
            amountTitle.draw(at: CGPoint(x: xOffset, y: pageYOffset))
            
            pageYOffset += amountTitle.size().height + tableOffset
            drawLine(from: CGPoint(x: innerRect.minX, y: pageYOffset), to: CGPoint(x: innerRect.maxX, y: pageYOffset), in: context)
            pageYOffset += tableOffset
            
            xOffset = innerRect.minX + tableOffset
            let oneString = NSAttributedString(string: "1", attributes: regularAttributes)
            oneString.draw(at: CGPoint(x: xOffset, y: pageYOffset))
            xOffset = firstRowX + tableOffset
            
            var secondRowHeigth = oneString.size().height + tableOffset
            if let subject = invoice.subjectMatter, let engName = subject.engName {
                let description = NSMutableAttributedString(string: engName, attributes: regularAttributes)
                if let ukrName = subject.ukrName {
                    description.append(NSAttributedString(string: " / " + ukrName, attributes: regularAttributes))
                }
                
                let descTextRect = CGRect(x: xOffset, y: pageYOffset, width: innerRect.width * 0.425, height: .greatestFiniteMagnitude)
                let descBounds = description.boundingRect(with: descTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
                let descRect = CGRect(origin: descTextRect.origin, size: descBounds.size)
                description.draw(in: descRect)
                
                secondRowHeigth = descRect.height + tableOffset
            }
            xOffset = secondRowX + tableOffset
            
            let quantityString = NSAttributedString(string: "\(invoice.quantity)", attributes: regularAttributes)
            quantityString.draw(at: CGPoint(x: xOffset, y: pageYOffset))
            xOffset = thirdRowX + tableOffset
            
            let priceString = NSAttributedString(string: String(format: "%.2f", invoice.price), attributes: regularAttributes)
            priceString.draw(at: CGPoint(x: xOffset, y: pageYOffset))
            xOffset = fourthRowX + tableOffset
            
            let amountString = NSAttributedString(string: String(format: "%.2f", total), attributes: regularAttributes)
            amountString.draw(at: CGPoint(x: xOffset, y: pageYOffset))
            pageYOffset += secondRowHeigth
            
            drawLine(from: CGPoint(x: innerRect.minX, y: pageYOffset), to: CGPoint(x: innerRect.maxX, y: pageYOffset), in: context)
            pageYOffset += tableOffset
            
            let totalString = NSAttributedString(string: "Total/Усього:", attributes: regularAttributes)
            totalString.draw(at: CGPoint(x: thirdRowX + tableOffset, y: pageYOffset))
            amountString.draw(at: CGPoint(x: fourthRowX + tableOffset, y: pageYOffset))
            
            pageYOffset += totalString.size().height + tableOffset
            drawLine(from: CGPoint(x: innerRect.minX, y: pageYOffset), to: CGPoint(x: innerRect.maxX, y: pageYOffset), in: context)
            drawLine(from: CGPoint(x: firstRowX, y: secondTableTop), to: CGPoint(x: firstRowX, y: pageYOffset), in: context)
            drawLine(from: CGPoint(x: secondRowX, y: secondTableTop), to: CGPoint(x: secondRowX, y: pageYOffset), in: context)
            drawLine(from: CGPoint(x: thirdRowX, y: secondTableTop), to: CGPoint(x: thirdRowX, y: pageYOffset), in: context)
            pageYOffset += tableOffset
            
            amountString.draw(at: CGPoint(x: fourthRowX + tableOffset, y: pageYOffset))
            
            xOffset = innerRect.minX + tableOffset
            let totalToPay = NSAttributedString(string: "Total to pay /\nУсього до сплати:", attributes: regularAttributes)
            totalToPay.draw(at: CGPoint(x: xOffset, y: pageYOffset))
            xOffset += totalToPay.size().width + (tableOffset * 2)
            
            let fraction = Int((total * 100).rounded()) % 100
            var engTotalInWords = englishNumberFormatter.string(from: NSNumber(value: Int(total)))?.capitalized ?? "Zero"
            engTotalInWords += " " + invoice.currency.englishNameInWords
            engTotalInWords += " " + (englishNumberFormatter.string(from: NSNumber(value: fraction)) ?? "zero") + " " + invoice.currency.englishFraction
            
            var ukrTotalInWords = ukrainianNumberFormatter.string(from: NSNumber(value: Int(total)))?.capitalized ?? "Нуль"
            ukrTotalInWords += " " + invoice.currency.ukrainianNameInWords
            ukrTotalInWords += " " + (ukrainianNumberFormatter.string(from: NSNumber(value: fraction)) ?? "нуль") + " " + invoice.currency.ukrainianFraction
            
            let totalInWords = NSAttributedString(string: engTotalInWords + "\n" + ukrTotalInWords, attributes: regularAttributes)
            let totalInWordsTextRect = CGRect(x: xOffset, y: pageYOffset, width: innerRect.width - xOffset - (innerRect.width - fourthRowX), height: .greatestFiniteMagnitude)
            let totalInWordsBounds = totalInWords.boundingRect(with: totalInWordsTextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            let totalInWordsRect = CGRect(origin: totalInWordsTextRect.origin, size: totalInWordsBounds.size)
            totalInWords.draw(in: totalInWordsRect)
            
            pageYOffset += totalInWordsRect.height + tableOffset
            drawLine(from: CGPoint(x: innerRect.minX, y: pageYOffset), to: CGPoint(x: innerRect.maxX, y: pageYOffset), in: context)
            drawLine(from: CGPoint(x: innerRect.minX, y: secondTableTop), to: CGPoint(x: innerRect.minX, y: pageYOffset), in: context)
            drawLine(from: CGPoint(x: innerRect.maxX, y: secondTableTop), to: CGPoint(x: innerRect.maxX, y: pageYOffset), in: context)
            drawLine(from: CGPoint(x: fourthRowX, y: secondTableTop), to: CGPoint(x: fourthRowX, y: pageYOffset), in: context)
            pageYOffset += 10
            
            // MARK: - Terms
            let text1 = "All charges of correspondent banks are at the Supplier’s expenses. / Усі комісії банків-кореспондентів сплачує виконавець."
            let text1Attributed = NSAttributedString(string: text1, attributes: termsAttributes)
            let text1TextRect = CGRect(x: insets.left, y: pageYOffset, width: innerRect.width, height: .greatestFiniteMagnitude)
            let text1Bounds = text1Attributed.boundingRect(with: text1TextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            text1Attributed.draw(in: CGRect(origin: text1TextRect.origin, size: text1Bounds.size))
            pageYOffset += text1Bounds.height + 5.0
            
            let text2 = """
            This Invoice is an offer to enter into the agreement. \
            Payment according hereto shall be deemed as an acceptation of the offer \
            to enter into the agreement on the terms and conditions set out herein. \
            Payment according hereto may be made not later than \(dateFormatter.string(from: invoice.endDate)) / \
            Цей Інвойс є пропозицією укласти договір. Оплата за цим Інвойсом є \
            прийняттям пропозиції укласти договір на умовах, викладених в цьому Інвойсі. \
            Оплата за цим інвойсом може бути здійснена не пізніше \(dateFormatter.string(from: invoice.endDate)).
            """
            let text2Attributed = NSAttributedString(string: text2, attributes: termsAttributes)
            let text2TextRect = CGRect(x: insets.left, y: pageYOffset, width: innerRect.width, height: .greatestFiniteMagnitude)
            let text2Bounds = text2Attributed.boundingRect(with: text2TextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            text2Attributed.draw(in: CGRect(origin: text2TextRect.origin, size: text2Bounds.size))
            pageYOffset += text2Bounds.height + 5.0
            
            let text3 = """
            Please note, that payment according hereto at the same time is \
            the evidence of the work performance and the service delivery in \
            full scope, acceptation thereof and the confirmation of final \
            mutual installments between Parties. / Оплата згідно цього Інвойсу \
            одночасно є свідченням виконання робіт та надання послуг в повному \
            обсязі, їх прийняття, а також підтвердженням кінцевих розрахунків між Сторонами.
            """
            let text3Attributed = NSAttributedString(string: text3, attributes: termsAttributes)
            let text3TextRect = CGRect(x: insets.left, y: pageYOffset, width: innerRect.width, height: .greatestFiniteMagnitude)
            let text3Bounds = text3Attributed.boundingRect(with: text3TextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            text3Attributed.draw(in: CGRect(origin: text3TextRect.origin, size: text3Bounds.size))
            pageYOffset += text3Bounds.height + 5.0
            
            let text4 = """
            Payment according hereto shall be also the confirmation that Parties \
            have no claims to each other and have no intention to submit any claims. \
            The agreement shall not include penalty and fine clauses. / Оплата згідно \
            цього Інвойсу є підтвердженням того, що Сторони не мають взаємних претензій \
            та не мають наміру направляти рекламації. Договір не передбачає штрафних санкцій.
            """
            let text4Attributed = NSAttributedString(string: text4, attributes: termsAttributes)
            let text4TextRect = CGRect(x: insets.left, y: pageYOffset, width: innerRect.width, height: .greatestFiniteMagnitude)
            let text4Bounds = text4Attributed.boundingRect(with: text4TextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            text4Attributed.draw(in: CGRect(origin: text4TextRect.origin, size: text4Bounds.size))
            pageYOffset += text4Bounds.height + 5.0
            
            let text5 = """
            The Parties shall not be liable for non-performance or improper performance \
            of the obligations under the agreement during the term of insuperable force \
            circumstances. / Сторони звільняються від відповідальності за невиконання \
            чи неналежне виконання зобов’язань за договором на час дії форс-мажорних обставин.
            """
            let text5Attributed = NSAttributedString(string: text5, attributes: termsAttributes)
            let text5TextRect = CGRect(x: insets.left, y: pageYOffset, width: innerRect.width, height: .greatestFiniteMagnitude)
            let text5Bounds = text5Attributed.boundingRect(with: text5TextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            text5Attributed.draw(in: CGRect(origin: text5TextRect.origin, size: text5Bounds.size))
            pageYOffset += text5Bounds.height + 5.0
            
            let text6 = """
            Any disputes arising out of the agreement between the Parties shall be settled \
            by the competent court at the location of a defendant. / Всі спори, що виникнуть \
            між Сторонами по договору будуть розглядатись компетентним судом за місцезнаходження відповідача.
            """
            let text6Attributed = NSAttributedString(string: text6, attributes: termsAttributes)
            let text6TextRect = CGRect(x: insets.left, y: pageYOffset, width: innerRect.width, height: .greatestFiniteMagnitude)
            let text6Bounds = text6Attributed.boundingRect(with: text6TextRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin])
            text6Attributed.draw(in: CGRect(origin: text6TextRect.origin, size: text6Bounds.size))
//            pageYOffset += text5Bounds.height + 5.0
            
            let sign = NSMutableAttributedString(string: "Supplier/Виконавець:\t______________________________________\t", attributes: regularAttributes)
            if let lastName = profile.lastName, let firstName = profile.firstName, let patronymic = profile.patronymic {
                sign.append(NSAttributedString(string: "(\(lastName.transliterate) \(firstName.transliterate) / \(lastName) \(firstName.first ?? Character("")). \(patronymic.first ?? Character("")).)", attributes: regularAttributes))
            }
            sign.draw(at: CGPoint(x: insets.left, y: innerRect.height - sign.size().height))
            
            context.endPDFPage()
            context.closePDF()
        }
        
        return cfMutableData as Data
    }
    
    // MARK: - Private
    private func drawLine(from point1: CGPoint, to point2: CGPoint, in context: CGContext) {
        context.setStrokeColor(NSColor.lightGray.cgColor)
        context.setLineWidth(0.5)
        context.move(to: point1)
        context.addLine(to: point2)
        context.drawPath(using: .stroke)
    }
}

fileprivate extension CGRect {
    func inset(by insets: NSEdgeInsets) -> CGRect {
        return CGRect(
            x: origin.x + insets.left,
            y: origin.y + insets.top,
            width: size.width - (insets.left + insets.right),
            height: size.height - (insets.top + insets.bottom))
    }
}
