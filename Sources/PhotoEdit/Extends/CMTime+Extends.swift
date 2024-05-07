//
//  CMTime+Extends.swift
//
//
//  Created by iferret on 2024/5/7.
//

import CoreMedia

extension CMTime: CompatibleValue {}
extension CompatibleWrapper where Base == CMTime {
    
    /// TimeInterval
    internal var rounded: TimeInterval {
        return base.seconds.rounded()
    }
    /// 小时
    internal var hours:  Int { return Int(rounded / 3600.0) }
    /// 分钟
    internal var minutes: Int { return Int(rounded.truncatingRemainder(dividingBy: 3600.0) / 60.0) }
    /// 秒
    internal var seconds: Int { return Int(rounded.truncatingRemainder(dividingBy: 60.0)) }
    /// 可读性文本
    internal var readable: String {
        return hours > 0 ? String(format: "%d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
    }
}
