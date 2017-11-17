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
    var scale: CGFloat = 2.0 { didSet{ setNeedsDisplay() } }
    
    private var origin: CGPoint! { didSet{ setNeedsDisplay() } }
    
    //private var originRelativePosition: (xScale: Double, yScale: Double)?
    
    var dataSource: GraphViewController?
    
    private let defaultPointsPerUnit: CGFloat = 25
    
    private var axesDrawer = AxesDrawer()
    
    func changeScale(reactingTo pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .changed, .ended:
            scale *= pinch.scale
            pinch.scale = 1
        default:
            break
        }
    }
    
    func changeOrigin(reactingTo pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .changed, .ended:
            let translation = pan.translation(in: self)
            origin.x += translation.x
            origin.y += translation.y
            pan.setTranslation(CGPoint.zero, in: self)
        default:
            break;
        }
    }
    
    private func pathForFunction() -> UIBezierPath {
        let path = UIBezierPath()
        guard let function = dataSource?.function else {
            print ("Nothing!")
            return path
        }
        let xAxis = (lowerBound: -Double(origin.x / defaultPointsPerUnit / scale), upperBound: Double((bounds.width - origin.x) / defaultPointsPerUnit / scale))
        let yAxis = (lowerBound: Double((origin.y - bounds.height) / defaultPointsPerUnit / scale), upperBound: Double(origin.y / defaultPointsPerUnit / scale))
        var startedGraphing = false
        for input in stride(from: xAxis.lowerBound, to: xAxis.upperBound, by: Double(1.0 / (defaultPointsPerUnit * scale))) {
            let output = function(input)
            var currentPoint: CGPoint?
            if !output.isNaN, output <= yAxis.upperBound, output >= yAxis.lowerBound {
                currentPoint = CGPoint(x: origin.x + CGFloat(input) * defaultPointsPerUnit * scale, y: origin.y - CGFloat(output) * defaultPointsPerUnit * scale)
            }
            //print(currentPoint, input, output)
            if let point = currentPoint {
                if !startedGraphing {
                    path.move(to: point)
                    startedGraphing = true
                } else {
                    path.addLine(to: point)
                }
            }
        }
        return path
    }

    override func draw(_ rect: CGRect) {
        if origin == nil {
           origin = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        pathForFunction().stroke()
        axesDrawer.contentScaleFactor = scale
        axesDrawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale * CGFloat(defaultPointsPerUnit))
    }

}
