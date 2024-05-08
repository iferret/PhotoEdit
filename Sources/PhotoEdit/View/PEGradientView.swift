//
//  PEGradientView.swift
//
//
//  Created by iferret on 2024/5/8.
//

import UIKit

/// PEGradientView
class PEGradientView: UIView {
    
    // MARK: 公开属性
    
    /// AnyClass
    internal override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    /* The array of CGColorRef objects defining the color of each gradient
     * stop. Defaults to nil. Animatable.
     */
    internal var colors: Array<UIColor>? {
        didSet { (layer as! CAGradientLayer).colors = colors?.map(\.cgColor) }
    }
    
    
    /* An optional array of NSNumber objects defining the location of each
     * gradient stop as a value in the range [0,1]. The values must be
     * monotonically increasing. If a nil array is given, the stops are
     * assumed to spread uniformly across the [0,1] range. When rendered,
     * the colors are mapped to the output colorspace before being
     * interpolated. Defaults to nil. Animatable.
     */
    internal var locations: [Float]? {
        didSet { (layer as! CAGradientLayer).locations = locations?.map { .init(value: $0) } }
    }
    
    
    /* The start and end points of the gradient when drawn into the layer's
     * coordinate space. The start point corresponds to the first gradient
     * stop, the end point to the last gradient stop. Both points are
     * defined in a unit coordinate space that is then mapped to the
     * layer's bounds rectangle when drawn. (I.e. [0,0] is the bottom-left
     * corner of the layer, [1,1] is the top-right corner.) The default values
     * are [.5,0] and [.5,1] respectively. Both are animatable.
     */
    internal var startPoint: CGPoint {
        get { (layer as! CAGradientLayer).startPoint }
        set { (layer as! CAGradientLayer).startPoint = newValue }
    }
    
    internal var endPoint: CGPoint {
        get { (layer as! CAGradientLayer).endPoint }
        set { (layer as! CAGradientLayer).endPoint = newValue }
    }
    
    
    /* The kind of gradient that will be drawn. Currently, the only allowed
     * values are `axial' (the default value), `radial', and `conic'.
     */
    internal var type: CAGradientLayerType {
        get { (layer as! CAGradientLayer).type }
        set { (layer as! CAGradientLayer).type = newValue }
    }
}
