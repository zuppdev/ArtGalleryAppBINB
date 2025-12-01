//
//  HTMLParser.swift
//  ArtGalleryAppBINB
//
//  Created by Zap on 01/12/25.
//

import Foundation
import SwiftUI

extension String {
    /// Converts HTML string to plain text with proper formatting
    func htmlToAttributedString() -> AttributedString {
        // Remove HTML tags and convert entities
        var text = self
        
        // Replace common HTML entities
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        
        // Remove HTML tags but preserve the text
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        // Clean up extra whitespace
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return AttributedString(text)
    } 
    
    /// Converts HTML to plain text string
    func htmlToPlainText() -> String {
        return String(htmlToAttributedString().characters)
    }
}
