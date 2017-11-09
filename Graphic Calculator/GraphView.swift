//
//  GraphView.swift
//  Graphic Calculator
//
//  Created by Tony Lyu on 08/11/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var scale: CGFloat = 1.0 { didSet{ setNeedsDisplay() } }
    
    @IBInspectable
    var origin: CGPoint! { didSet{ setNeedsDisplay() } }
    
    private var axesDrawer = AxesDrawer()

    override func draw(_ rect: CGRect) {
        if origin == nil {
            origin = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        axesDrawer.contentScaleFactor = scale
        axesDrawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale * 50)
    }

}
