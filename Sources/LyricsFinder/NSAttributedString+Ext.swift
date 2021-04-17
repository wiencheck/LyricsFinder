//
//  File.swift
//  
//
//  Created by Adam Wienconek on 04/03/2021.
//

import Foundation

extension NSAttributedString {
    convenience init(data: Data, documentType: DocumentType, encoding: String.Encoding = .utf8) throws {
        try self.init(attributedString: .init(data: data, options: [.documentType: documentType, .characterEncoding: encoding.rawValue], documentAttributes: nil))
    }

    func data(_ documentType: DocumentType) -> Data {
        // Discussion
        // Raises an rangeException if any part of range lies beyond the end of the receiver’s characters.
        // Therefore passing a valid range allow us to force unwrap the result
        try! data(from: .init(location: 0, length: length),
                  documentAttributes: [.documentType: documentType])
    }

    var text: Data { data(.plain) }
    var html: Data { data(.html)  }
    var rtf:  Data { data(.rtf)   }
    var rtfd: Data { data(.rtfd)  }
}
