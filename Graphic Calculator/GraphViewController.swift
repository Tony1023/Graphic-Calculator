//
//  ViewController.swift
//  Graphic Calculator
//
//  Created by Tony Lyu on 06/11/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphData
{
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            let pinchHandler = #selector(GraphView.changeScale(reactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: pinchHandler)
            graphView.addGestureRecognizer(pinchRecognizer)
            let panHandler = #selector(GraphView.moveOrigin(reactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: panHandler)
            graphView.addGestureRecognizer(panRecognizer)
            let tapHandler = #selector(GraphView.changeOrigin(reactingTo:))
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: tapHandler)
            graphView.addGestureRecognizer(tapRecognizer)
            graphView.dataSource = self
        }
    }
    
    var functionToGraph: ((Double) -> Double)?
    
    func function(input: Double) -> Double {
        guard let F = functionToGraph else {
            return Double.nan
        }
        return F(input)
    }
}


