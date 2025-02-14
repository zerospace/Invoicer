//
//  String+Transliteration.swift
//  Invoicer
//
//  Created by Oleksandr Fedko on 14.02.2025.
//

import Foundation

extension String {
    var transliterate: String {
        let transliterationTableStart: [Character: String] = [
            "Є": "Ye", "є": "ye", "Ї": "Yi", "ї": "yi", "Й": "Y", "й": "y",
            "Ю": "Yu", "ю": "yu", "Я": "Ya", "я": "ya"
        ]
        
        let transliterationTableInside: [Character: String] = [
            "Є": "Ie", "є": "ie", "Ї": "I", "ї": "i", "Й": "I", "й": "i",
            "Ю": "Iu", "ю": "iu", "Я": "Ia", "я": "ia"
        ]
        
        let transliterationTableDefault: [Character: String] = [
            "А": "A", "а": "a", "Б": "B", "б": "b", "В": "V", "в": "v",
            "Г": "H", "г": "h", "Ґ": "G", "ґ": "g", "Д": "D", "д": "d",
            "Е": "E", "е": "e", "Ж": "Zh", "ж": "zh", "З": "Z", "з": "z",
            "И": "Y", "и": "y", "І": "I", "і": "i", "К": "K", "к": "k",
            "Л": "L", "л": "l", "М": "M", "м": "m", "Н": "N", "н": "n",
            "О": "O", "о": "o", "П": "P", "п": "p", "Р": "R", "р": "r",
            "С": "S", "с": "s", "Т": "T", "т": "t", "У": "U", "у": "u",
            "Ф": "F", "ф": "f", "Х": "Kh", "х": "kh", "Ц": "Ts", "ц": "ts",
            "Ч": "Ch", "ч": "ch", "Ш": "Sh", "ш": "sh", "Щ": "Shch", "щ": "shch"
        ]
        
        var result = ""
        let words = self.split(separator: " ")
        
        for (index, word) in words.enumerated() {
            var transliteratedWord = ""
            
            for (i, character) in word.enumerated() {
                guard character.lowercased() != "ь", character != "'", character != "’" else { continue }
                
                var transliteratedCharacter = ""
                
                if i > 0 && word[word.index(word.startIndex, offsetBy: i - 1)] == "з" && character == "г" {
                    transliteratedCharacter = "zgh" // Транслітерація "зг"
                }
                else {
                    if i == 0 {
                        transliteratedCharacter = transliterationTableStart[character] ?? transliterationTableDefault[character] ?? String(character)
                    } else {
                        transliteratedCharacter = transliterationTableInside[character] ?? transliterationTableDefault[character] ?? String(character)
                    }
                }
                
                transliteratedWord.append(transliteratedCharacter)
            }
            
            if index > 0 {
                result.append(" ")
            }
            result.append(transliteratedWord)
        }
        
        return result
    }
}
