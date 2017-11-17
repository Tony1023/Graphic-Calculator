//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Tony Lyu on 14/09/2017.
//  Copyright © 2017 Zhehao Lu. All rights reserved.
//

import Foundation

func changeSign(of expression: String) -> String {
    var resultExpression = expression
    if resultExpression.hasPrefix("-") {
        resultExpression.remove(at: resultExpression.startIndex)
    } else {
        return "-" + resultExpression
    }
    return resultExpression
}

var evaluationDictionary: Dictionary<String, Double>?

struct CalculatorBrain { //Structs get free initializers, while classes don't
    
    private var operationSequence = [Inputs]()
    
    mutating func undo() {
        if !operationSequence.isEmpty {
            operationSequence.removeLast()
        }
    }
    
    private enum Inputs {
        case operand(Double)
        case operation(String)
        case variable(String)
    }
    
    private enum Operation {
        case constant(Double) // Raw_values in enum
        case unaryOpeartion((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        //    "rand": Operation.constant(Double(arc4random())),
        "±": Operation.unaryOpeartion({ -$0 }, changeSign),
        "eˣ": Operation.unaryOpeartion({ pow(M_E, $0) }, { "e^(" + $0 + ")"}),
        "√": Operation.unaryOpeartion(sqrt, { "√(" + $0 + ")" }),
        "cos": Operation.unaryOpeartion(cos, { "cos(" + $0 + ")" }),
        "sin": Operation.unaryOpeartion(sin, { "sin(" + $0 + ")" }),
        "tan": Operation.unaryOpeartion(tan, { "tan(" + $0 + ")" }),
        "ln": Operation.unaryOpeartion(log, { "ln(" + $0 + ")" }),
        "x²": Operation.unaryOpeartion({pow($0, 2)}, { "(" + $0 + ")²" }),
        "10ˣ": Operation.unaryOpeartion({pow(10, $0)}, { "10^(" + $0 + ")" }),
        //Only when Swift can infer your function type
        //In this case .unaryOperation is already (Double) -> Double
        "+": Operation.binaryOperation(+, { $0 + "+" }),
        "−": Operation.binaryOperation(-, { $0 + "-" }),
        "×": Operation.binaryOperation(*, { $0 + "×" }),
        "÷": Operation.binaryOperation(/, { $0 + "÷" }),
        "=": Operation.equals
    ]
    
    //not constant in C++
    //Need to be specified because it's passed by copy
    mutating func setOperand(variable named: String) {
        operationSequence.append(Inputs.variable(named))
    }
    mutating func setOperand(_ operand: Double) {
        operationSequence.append(Inputs.operand(operand))
    }
    mutating func performOperation(_ symbol: String) {
        operationSequence.append(Inputs.operation(symbol))
    }
    
    var result: Double? {
        return evaluate().result
    }
    
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    var description: String {
        return evaluate().description
    }
    
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var accumulator: Double?
        var currentOperand: String?
        var pendingUnaryOperation: String?
        var inputExpression: String?
        var description: String {
            get {
                if let operationToAppend = pendingUnaryOperation {
                    if inputExpression != nil {
                        return inputExpression! + operationToAppend
                    } else {
                        return operationToAppend
                    }
                } else {
                    return inputExpression ?? ""
                }
            }
        }
        var pendingBinaryOperation: PendingBinaryOperation? //There's pending and not when not using binary opeartions so use a optional
        var resultIsPending: Bool {
            get {
                return (pendingBinaryOperation != nil)
            }
        }
        
        struct PendingBinaryOperation {
            let function: (Double, Double) -> Double
            let firstOperand: Double
            
            func perform(with secondOperand: Double) -> Double {
                return function(firstOperand, secondOperand)
            }
        }
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!) // when use ? then it will ignore the statment if nil
                pendingBinaryOperation = nil //finished the pending binary operation
            }
        }
        
        for input in operationSequence {
            switch input {
            case .operand (let operand):
                accumulator = operand
                if !resultIsPending {
                    inputExpression = nil
                }
                currentOperand = String(describing: operand)
                if currentOperand!.hasSuffix(".0") {
                    let range = currentOperand!.index(currentOperand!.endIndex, offsetBy: -2)..<currentOperand!.endIndex
                    currentOperand!.removeSubrange(range)
                }
            case .operation (let symbol):
                if inputExpression == nil {
                    inputExpression = currentOperand ?? "0"
                }
                if accumulator == nil {
                    accumulator = 0.0
                }
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        accumulator = value
                        currentOperand = symbol
                        if !resultIsPending{
                            inputExpression = symbol
                        } else {
                            pendingUnaryOperation = symbol
                        }
                    case .unaryOpeartion(let function, let describe):
                        if accumulator != nil {
                            accumulator = function(accumulator!)
                        }
                        if resultIsPending {
                            pendingUnaryOperation = describe(pendingUnaryOperation ?? currentOperand!)
                        } else {
                            inputExpression = describe(inputExpression!)
                        }
                    case .binaryOperation(let function, let describe):
                        if accumulator != nil {
                            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                            accumulator = nil // Hitting the plus botton
                        }
                        inputExpression = describe(inputExpression!)
                    case .equals:
                        if pendingBinaryOperation == nil {
                            break
                        }
                        performPendingBinaryOperation()
                        if let textToAppend = pendingUnaryOperation {
                            inputExpression! += textToAppend
                            pendingUnaryOperation = nil
                        } else {
                            inputExpression! += currentOperand!
                        }
                    }
                }
            case .variable (let variable):
                if let value = variables?[variable] {
                    accumulator = value
                } else {
                    accumulator = 0
                }/*
                if !resultIsPending {
                    inputExpression = nil
                }*/
                currentOperand = variable
            }
        }
        
        return (accumulator, pendingBinaryOperation != nil, description)
    }
}
