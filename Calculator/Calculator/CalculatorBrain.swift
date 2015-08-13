//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by David on 4/8/15.
//  Copyright (c) 2015 David Muñoz Fernández. All rights reserved.
//

import Foundation

class CalculatorBrain {

    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Constant(String, Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Constant(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    init() {
        func learnOp (op: Op){
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") {$1 / $0})
        learnOp(Op.BinaryOperation("+") {$0 + $1})
        learnOp(Op.BinaryOperation("−") {$1 - $0})
        
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        
        learnOp(Op.Constant("π", M_PI))
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList { // guaranteed to be a PropertyList
        get {
            return opStack.map{ $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    }else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Constant(_, let value):
                return (value, remainingOps)
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with remainder left over")
        return result
    }
    
    func pushOperand(operand: Double?) -> Double? {
        if operand != nil {
            opStack.append(Op.Operand(operand!))
        }
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func clear() {
        opStack.removeAll(keepCapacity: false)
    }
    
    private func history(textHistory: String, ops: [Op]) -> (history: String, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .UnaryOperation(_, let operation):
                let operandEvaluation = history(textHistory, ops: remainingOps)
                return (op.description + "(" + operandEvaluation.history + ")" + textHistory, operandEvaluation.remainingOps)
            case .BinaryOperation(_, let operation):
                let op1Evaluation = history(textHistory, ops: remainingOps)
                let op2Evaluation = history(op1Evaluation.history, ops: op1Evaluation.remainingOps)
                let histOp1 = op2Evaluation.remainingOps.count<=1 ? op1Evaluation.history : "(" + op1Evaluation.history + ")"
                let histOp2 = op1Evaluation.remainingOps.count<=1 ? op2Evaluation.history : "(" + op2Evaluation.history + ")"
                return ( histOp2 + op.description + histOp1, op2Evaluation.remainingOps )
            case .Constant(_, _): fallthrough
            case .Operand(_): fallthrough
            case .Variable(_):
                return (op.description, remainingOps)
            }
        }
        return ("", ops)
    }
    
    func history() -> String {
        let(result, remainder) = history("", ops: opStack)
        return result
    }
}