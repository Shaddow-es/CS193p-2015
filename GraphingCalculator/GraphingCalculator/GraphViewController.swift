//
//  GraphViewController.swift
//  GraphingCalculator
//
//  Created by David on 19/8/15.
//  Copyright (c) 2015 David Muñoz Fernández. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    // ----------------------------------------------------------
    // MARK: - Model
    // ----------------------------------------------------------
    var origin = CGPoint() {
        didSet {
            graphView.origin = origin
        }
    }
    
    var scale = CGFloat(Constants.DefaultScale) {
        didSet {
            graphView.scale = scale
        }
    }
    
    // ----------------------------------------------------------
    // MARK: - Outlets
    // ----------------------------------------------------------
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
        }
    }
    
    // ----------------------------------------------------------
    // MARK: - GraphViewDataSource
    // ----------------------------------------------------------
    
    func valueFor(x: Double) -> Double? {
        brain.variableValues[Constants.VariableName] = x
        return brain.evaluate()
    }
    
    // ----------------------------------------------------------
    // MARK: - Controller Lifecycle
    // ----------------------------------------------------------
    
    override func viewDidLoad() {
        title = brain.description
    }
    
    // ----------------------------------------------------------
    // MARK: - Private
    // ----------------------------------------------------------
    
    private struct Constants {
        static let DefaultScale: CGFloat = 1.0
        static let VariableName = "M"
    }
    
    private var brain = CalculatorBrain()

}
