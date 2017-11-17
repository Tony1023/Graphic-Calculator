//
//  ViewController.swift
//  Graphic Calculator
//
//  Created by Tony Lyu on 06/11/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController
{
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            let pinchHandler = #selector(GraphView.changeScale(reactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: pinchHandler)
            graphView.addGestureRecognizer(pinchRecognizer)
            let panHandler = #selector(GraphView.changeOrigin(reactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: panHandler)
            graphView.addGestureRecognizer(panRecognizer)
        }
    }
    
    var function: ((Double) -> Double)?

}

