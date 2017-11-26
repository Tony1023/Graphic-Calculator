//
//  ViewController.swift
//  Calculator
//
//  Created by Tony Lyu on 11/09/2017.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel! //! means auto unwrapping everytime
    
    @IBOutlet weak var inputs: UILabel!
    
    private var userIsTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) { //_ means no external name
        let digit = sender.currentTitle!
        if userIsTyping {
            let textCurrentlyInDisplay = display.text!
            if Double(textCurrentlyInDisplay + digit) != nil {
                if digit != "0" || display.text! != "0" {
                    display.text! = textCurrentlyInDisplay + digit
                }
            }// Setting an optional doesn't need unwrapping
        } else {
            if digit == "." {
                display.text = "0."
            } else if digit != "0" {
                display.text = digit
            } else if digit == "0" {
                display.text = "0"
            }
            userIsTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)! //This kind of castings are all into optionals
        }
        set {
            var textToDisplay = String(newValue) //newValue is a set var
            if textToDisplay.hasSuffix(".0") {
                let range = textToDisplay.index(textToDisplay.endIndex, offsetBy: -2)..<textToDisplay.endIndex
                textToDisplay.removeSubrange(range)
            }
            display.text = textToDisplay
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false;
        }
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }
        updateResult()
    }
    
    private var hasUndone = false
    
    @IBAction func undo(_ sender: UIButton) {
        if userIsTyping, var displayText = display.text {
            let characterToRemove = displayText.index(before: displayText.endIndex)
            displayText.remove(at: characterToRemove)
            if displayText.isEmpty || displayText == "0" {
                displayText = "0"
                userIsTyping = false
            }
            display.text = displayText
        } else if !hasUndone {
            brain.undo()
            hasUndone = true
            updateResult()
        } else {
            displayM.text = "M="
            display.text = "0"
            inputs.text = "0"
            brain = CalculatorBrain()
            evaluationDictionary = nil
            userIsTyping = false
        }
    }
    
    @IBAction func useMemory(_ sender: UIButton) {
        if !brain.evaluate().isPending {
            display.text = "0"
            inputs.text = "0"
            brain = CalculatorBrain()
            userIsTyping = false
        }
        brain.setOperand(variable: "M")
        if let result = brain.evaluate().result {
            displayValue = result
        }
    }
    
    @IBOutlet weak var displayM: UILabel!
    
    @IBAction func computeWithStoredVariable(_ sender: UIButton) {
        if evaluationDictionary == nil {
            evaluationDictionary = ["M": displayValue]
        } else {
            evaluationDictionary!["M"] = displayValue
        }
        displayM.text = "M=" + display.text!
        userIsTyping = false
        updateResult()
    }
    
    private func updateResult() {
        let resultComputedWithDictionary = brain.evaluate(using: evaluationDictionary)
        if let result = resultComputedWithDictionary.result {
            displayValue = result
        }
        if resultComputedWithDictionary.isPending {
            inputs.text = resultComputedWithDictionary.description + "..."
        } else {
            inputs.text = resultComputedWithDictionary.description + "="
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if brain.evaluate(using: evaluationDictionary).isPending {
            return
        }
        var destinationVC = segue.destination
        if let navigationVC = destinationVC as? UINavigationController {
            destinationVC = navigationVC.visibleViewController ?? destinationVC
        }
        if let graphVC = destinationVC as? GraphViewController {
            graphVC.functionToGraph = { self.brain.evaluate(using: ["M": $0]).result ?? Double.nan }
            graphVC.navigationItem.title = self.brain.evaluate().description
        }
    }

}
