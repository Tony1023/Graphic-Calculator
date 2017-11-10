//
//  GraphView.swift
//  Graphic Calculator
//
//  Created by Tony Lyu on 08/11/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView
{
    
    @IBInspectable
    var scale: CGFloat = 1.0 { didSet{ setNeedsDisplay() } }
    
    var origin: CGPoint! { didSet{ setNeedsDisplay() } }
    
    private let defaultPointsPerUnit: CGFloat = 25
    
    private var axesDrawer = AxesDrawer()
    
    private func pathForFunction(_ function: (Double) -> Double) -> UIBezierPath {
        let xAxis = (lowerBound: -Double(origin.x / defaultPointsPerUnit), upperBound: Double((bounds.width - origin.x) / defaultPointsPerUnit))
        let yAxis = (lowerBound: Double((origin.y - bounds.height) / defaultPointsPerUnit), upperBound: Double(origin.y / defaultPointsPerUnit))
        let path = UIBezierPath()
        path.move(to: origin)
        for input in stride(from: xAxis.lowerBound, to: xAxis.upperBound, by: Double(scale / defaultPointsPerUnit)) {
            let output = function(input)
            var currentPoint: CGPoint?
            if !output.isNaN, output <= yAxis.upperBound, output >= yAxis.lowerBound {
                currentPoint = CGPoint(x: origin.x + CGFloat(input) * defaultPointsPerUnit, y: origin.y - CGFloat(output) * defaultPointsPerUnit)
            }
            //print(currentPoint, input, output)
            if let point = currentPoint {
                path.addLine(to: point)
            }
        }
        return path
    }
    

    override func draw(_ rect: CGRect) {
        origin = CGPoint(x: bounds.midX, y: bounds.midY)
        pathForFunction(sqrt).stroke()
        axesDrawer.contentScaleFactor = scale
        axesDrawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale * CGFloat(defaultPointsPerUnit))
    }

}
