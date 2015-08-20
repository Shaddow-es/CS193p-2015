//
//  ViewController.swift
//  Calculator
//
//  Created by David on 2/8/15.
//  Copyright (c) 2015 David Muñoz Fernández. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private var userIsInTheMiddleOfTypingANumber = false
    private var brain = CalculatorBrain()
    
    private var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        set {
            display.text = newValue == nil ? " " : NSNumberFormatter.localizedStringFromNumber(newValue!, numberStyle: NSNumberFormatterStyle.DecimalStyle)
            userIsInTheMiddleOfTypingANumber = false
            history.text = brain.description
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
        history.text = " "
    }
    
    @IBAction func enter() {
        if userIsInTheMiddleOfTypingANumber {
            userIsInTheMiddleOfTypingANumber = false
            displayValue = brain.pushOperand(displayValue)
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.clear()
        displayValue = nil
        brain.variableValues.removeAll(keepCapacity: false)
    }
    
    @IBAction func undo(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            display.text = count(display.text!)>0 ? dropLast(display.text!) : display.text
        }else{
            brain.undoLastOperation()
            displayValue = brain.evaluate()
        }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let gvc = destination as? GraphViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "graph":
                    gvc.title = brain.description
                default: break
                }
            }
        }
    }
    
    override func viewDidLoad() {
        displayValue = brain.evaluate()
    }
    
}

