//
//  GraphView.swift
//  Graphic Calculator
//
//  Created by Tony Lyu on 08/11/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

protocol GraphData: class {
    func function(_ input: Double) -> Double
}

@IBDesignable
class GraphView: UIView
{
    @IBInspectable
    var scale: CGFloat = 2.0 { didSet{ setNeedsDisplay() } }
    
    private var offSetToCenter: CGPoint! { didSet{ setNeedsDisplay() } }
    
    private var origin: CGPoint! {
        set {
            offSetToCenter.x = newValue.x - bounds.midX
            offSetToCenter.y = newValue.y - bounds.midY
        }
        get {
            if let offSet = offSetToCenter {
                return CGPoint(x: offSet.x + bounds.midX, y: offSet.y + bounds.midY)
            } else {
                return nil
            }
        }
    }
    
    weak var dataSource: GraphData? 
    
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
    
    func moveOrigin(reactingTo pan: UIPanGestureRecognizer) {
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
    
    func changeOrigin(reactingTo tap: UITapGestureRecognizer) {
        if tap.state == .ended {
            origin = tap.location(in: self)
        }
    }
    
    private func pathForFunction() -> UIBezierPath {
        let path = UIBezierPath()
        guard let function = dataSource?.function else {
            return path
        }
        var pathDNE: Bool = false
        let xAxis = (lowerBound: -Double(origin.x / defaultPointsPerUnit / scale), upperBound: Double((bounds.width - origin.x) / defaultPointsPerUnit / scale))
        var startedGraphing = false
        for input in stride(from: xAxis.lowerBound, to: xAxis.upperBound, by: Double(1.0 / (defaultPointsPerUnit * scale))) {
            let output = function(input)
            var currentPoint: CGPoint?
            if output.isNormal || output.isZero {
                currentPoint = CGPoint(x: origin.x + CGFloat(input) * defaultPointsPerUnit * scale, y: origin.y - CGFloat(output) * defaultPointsPerUnit * scale)
            } else {
                pathDNE = true
                continue
            }
            if let point = currentPoint {
                if !startedGraphing {
                    path.move(to: point)
                    startedGraphing = true
                } else if pathDNE {
                    path.move(to: point)
                    pathDNE = false
                } else {
                    path.addLine(to: point)
                }
            }
        }
        return path
    }

    override func draw(_ rect: CGRect) {
        if offSetToCenter == nil {
            offSetToCenter = CGPoint.zero
        }
        pathForFunction().stroke()
        axesDrawer.contentScaleFactor = scale
        axesDrawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale * CGFloat(defaultPointsPerUnit))
    }

}
