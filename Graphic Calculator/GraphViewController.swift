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
            if graphView?.dataSource == nil {
                graphView.dataSource = self
            }
        }
    }
    
    @IBAction func changeOrigin(_ sender: UITapGestureRecognizer) {
        graphView.changeOrigin(reactingTo: sender)
    }
    
    
    var functionToGraph: ((Double) -> Double)?
    
    func function(_ input: Double) -> Double {
        guard let F = functionToGraph else {
            return Double.nan
        }
        return F(input)
    }
}


