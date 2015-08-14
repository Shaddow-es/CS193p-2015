//
//  ViewController.swift
//  Calculator
//
//  Created by David on 2/8/15.
//  Copyright (c) 2015 David Muñoz Fernández. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func enter() {
        if userIsInTheMiddleOfTypingANumber {
            userIsInTheMiddleOfTypingANumber = false
            displayValue = brain.pushOperand(displayValue)
        }
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            display.text =  newValue != nil ? "\(newValue!)" : " "
            userIsInTheMiddleOfTypingANumber = false
            history.text = brain.description
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.clear()
        displayValue = nil
        brain.variableValues.removeAll(keepCapacity: false)
    }
    
    @IBAction func operate(sender: UIButton) {
        enter()
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
    }
    
    @IBAction func setVariableValue(sender: UIButton) {
        let varName = sender.currentTitle!
        let index = advance(varName.startIndex, 1)
        brain.variableValues[varName[index..<varName.endIndex]] = displayValue
        displayValue = brain.evaluate()
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        enter()
        let varName = sender.currentTitle!
        userIsInTheMiddleOfTypingANumber = false
        brain.pushOperand(varName)
        displayValue = brain.evaluate()
    }
    
}

