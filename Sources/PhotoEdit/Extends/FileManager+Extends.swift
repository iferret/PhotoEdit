//
//  FileManager+Extends.swift
//
//
//  Created by iferret on 2024/5/8.
//

import Foundation

extension FileManager: Compatible {}
extension CompatibleWrapper where Base: FileManager {
    
    /// URL
    internal var temporaryURL: URL {
        if #available(iOS 16.0, *) {
            return .init(filePath: NSTemporaryDirectory())
        } else {
            return .init(fileURLWithPath: NSTemporaryDirectory())
        }
    }
    
    /// temporaryURL for uuid
    /// - Parameters:
    ///   - uuid: String
    ///   - fileExt: String
    /// - Returns: URL
    internal func temporaryURL(for uuid: String, fileExt: String) -> URL {
        if #available(iOS 16.0, *) {
            return base.hub.temporaryURL.appending(component: uuid + "." + fileExt, directoryHint: .notDirectory)
        } else {
            return base.hub.temporaryURL.appendingPathComponent(uuid + "." + fileExt, isDirectory: false)
        }
    }
}
