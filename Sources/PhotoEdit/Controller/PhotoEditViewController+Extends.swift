//
//  File.swift
//  
//
//  Created by iferret on 2024/5/6.
//

import UIKit

extension PhotoEditViewController {
    
    /// SourceType
    public enum SourceType {
        case camera
        case photo(_ uiImage: UIImage)
    }
    
    /// ResultType
    public enum ResultType {
        case photo(_ uiImage: UIImage)
        case video(_ fileURL: URL)
    }
}
