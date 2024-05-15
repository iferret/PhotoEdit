//
//  PEConfiguration.swift
//  
//
//  Created by iferret on 2024/5/14.
//

import UIKit

/// PEConfiguration
public class PEConfiguration: NSObject {
    
    // MARK: 公开属性
    
    /// 保存到相册
    public var saveToAlbum: Bool = true
    /// 自动关闭
    public var closeWhenFinished: Bool = true
    /// maxImageBytes
    public var maxImageBytes: Int = 1024 * 1024 * 2
    /// UIFont
    public var barItemFont: UIFont = .pingfang(ofSize: 18.0)
    /// UIFont
    public var buttonFont: UIFont = .pingfang(ofSize: 18.0)
    
    // MARK: 私有属性
    
    /// Optional<PEConfiguration>
    private static var configuration: Optional<PEConfiguration> = .none
    
    // MARK: 生命周期
    
    /// init
    private override init() {
        super.init()
    }
    
    /// `default`
    /// - Returns: PEConfiguration
    public static func `default`() -> PEConfiguration {
        if let obj = PEConfiguration.configuration {
            return obj
        } else {
            PEConfiguration.configuration = .init()
            return PEConfiguration.configuration!
        }
    }
    
    /// clearup
    internal static func clearup() {
        PEConfiguration.configuration = .none
    }
}
