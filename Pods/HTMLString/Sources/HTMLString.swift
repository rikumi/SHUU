/*
 * ==---------------------------------------------------------------------------------==
 *
 *  File            :   HTMLString.swift
 *  Project         :   HTMLString
 *  Author          :   ALEXIS AUBRY RADANOVIC
 *
 *  License         :   The MIT License (MIT)
 *
 * ==---------------------------------------------------------------------------------==
 *
 *	The MIT License (MIT)
 *	Copyright (c) 2016 ALEXIS AUBRY RADANOVIC
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy of
 *	this software and associated documentation files (the "Software"), to deal in
 *	the Software without restriction, including without limitation the rights to
 *	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 *	the Software, and to permit persons to whom the Software is furnished to do so,
 *	subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in all
 *	copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *	FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * ==---------------------------------------------------------------------------------==
 */

import Foundation

public extension String {
    
    // MARK: - Escaping
    
    ///
    /// A string where internal characters that need escaping for HTML are escaped.
    ///
    /// For example, '&' become '\&amp;'.
    ///
    
    public var escapingForUnicodeHTML: String {
        return escapeHTML(isEncodingUnicode: true)
    }

    ///
    /// A string where internal characters that need escaping for HTML are escaped.
    ///
    /// For instance, '&' becomes '\&amp;' and '🙃' becomes '\&#x1F643;'.
    ///
    /// All non-mapped characters (unicode that don't have a &keyword; mapping) will be converted to the appropriate &#xxx; value. If your webpage is unicode encoded (UTF16 or UTF8) use `escapingForHTML` instead as it is faster, and produces less bloated and more readable HTML (as long as you are using a unicode compliant HTML reader).
    ///
    
    public var escapingForASCIIHTML: String {
        return escapeHTML(isEncodingUnicode: false)
    }
    
    ///
    /// Replaces all characters that need to be encoded for use in HTML documents.
    ///
    /// If the encoding is Unicode, only characters that have a keyword in the `String.htmlEscapeTable` will be escaped. Otherwise, all non-ASCII characters will be escaped using their code point (&#128;).
    ///
    /// - parameter isEncodingUnicode: A Boolean indicating whether the string should be escaped with Unicode (`true`) or ASCII (`false`) encoding.
    ///
    /// - returns: A string escaped with respect to the specified encoding.
    ///
    
    fileprivate func escapeHTML(isEncodingUnicode: Bool) -> String {
        
        var finalString = String()
        
        for scalar in unicodeScalars {
            let escapingSequence = isEncodingUnicode ? scalar.escapingForUnicode : scalar.escapingForASCII
            finalString.append(escapingSequence)
        }
        
        return finalString
        
    }
    
    // MARK: - Unescaping
    
    ///
    /// A string where internal characters that are escaped for HTML are unescaped.
    ///
    /// For example, '&amp;' becomes '&'. Handles &#32; and &#x32; cases as well.
    ///
    
    public var unescapingFromHTML: String {
        
        guard self.contains("&") else {
            return self
        }
        
        var finalString = self
        var searchRange = finalString.startIndex ..< finalString.endIndex
        
        while let delimiterRange = finalString.range(of: "&", options: [], range: searchRange, locale: nil) {
            
            let semicolonCheckRange = delimiterRange.upperBound ..< finalString.endIndex
            
            guard let semicolonRange = finalString.range(of: ";", options: [], range: semicolonCheckRange, locale: nil) else {
                searchRange = delimiterRange.upperBound ..< finalString.endIndex
                continue
            }
            
            let escapeSequenceBounds = delimiterRange.lowerBound ..< semicolonRange.upperBound
            let escapeRange = finalString.index(after: delimiterRange.lowerBound) ..< finalString.index(before: semicolonRange.upperBound)
            let escapeString = finalString.substring(with: escapeRange)
                        
            var scalars: Array<UnicodeScalar>
            
            if escapeString[escapeString.startIndex] == "#" {
                
                let secondCharacter = escapeString[escapeString.index(after: escapeString.startIndex)]
                
                let isHexadecimal = (secondCharacter == "X" || secondCharacter == "x")
                let firstCharacterOffset = isHexadecimal ? 2 : 1
                
                let sequenceRange = escapeString.index(escapeString.startIndex, offsetBy: firstCharacterOffset) ..< escapeString.endIndex
                let sequence = escapeString.substring(with: sequenceRange)
                
                var value = UInt32()
                
                if isHexadecimal {
                    
                    let scanner = Scanner(string: sequence)

                    #if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
                    
                    guard scanner.scanHexInt32(&value) && value > 0 else {
                        searchRange = escapeRange.upperBound ..< finalString.endIndex
                        continue
                    }
                    
                    #else 

		    guard let _value = scanner.scanHexInt() else {
                        searchRange = escapeRange.upperBound ..< finalString.endIndex
                        continue
                    }

                    value = _value

                    #endif

                } else {
                    
                    guard let _value = UInt32(sequence) else {
                        searchRange = escapeRange.upperBound ..< finalString.endIndex
                        continue
                    }
                    
                    value = _value
                    
                }
                
                
                guard let _scalar = UnicodeScalar(value) else {
                    searchRange = escapeRange.upperBound ..< finalString.endIndex
                    continue
                }
                
                scalars = [_scalar]
                
            } else {
                
                guard let escapeMap = String.htmlEscapeTable.first(where: { $0.escapeSequence == escapeString }) else {
                    searchRange = escapeRange.upperBound ..< finalString.endIndex
                    continue
                }
                
                scalars = escapeMap.scalarValues.map({ UnicodeScalar($0) }).filter { $0 != nil }.map { $0! }
                
            }
            
            let escapeSequenceStart = escapeSequenceBounds.lowerBound.samePosition(in: finalString.unicodeScalars)
            let escapeSequenceEnd = escapeSequenceBounds.upperBound.samePosition(in: finalString.unicodeScalars)
            
            finalString.unicodeScalars.replaceSubrange(escapeSequenceStart ..< escapeSequenceEnd, with: scalars)
            searchRange = delimiterRange.upperBound ..< finalString.endIndex
            
        }
        
        return finalString
        
    }
    
}

fileprivate extension UnicodeScalar {
    
    ///
    /// Escapes the unicode scalar for ASCII web pages.
    ///
    
    fileprivate var escapingForASCII: String {
        
        if isASCII {
            return escapingForUnicode
        }
        
        if let escapeTable = String.htmlEscapeTable.first(where: { $0.scalarValues == [value] }) {
            return ("&" + escapeTable.escapeSequence.lowercased() + ";")
        } else {
            return ("&#" + String(value) + ";")
        }
        
    }
    
    ///
    /// Escapes the unicode scalar for Unicode web pages.
    ///
    
    fileprivate var escapingForUnicode: String {
        
        if let escapableUnicodeCodePoint = String.escapableUnicodeCodePoints[value] {
            return ("&" + escapableUnicodeCodePoint + ";")
        }
        
        return String(describing: self)
        
    }
    
}
