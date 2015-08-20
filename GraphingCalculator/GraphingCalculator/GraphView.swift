//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by David on 19/8/15.
//  Copyright (c) 2015 David Muñoz Fernández. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func valueFor(x: Double) -> Double?
}

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var scale: CGFloat = Constants.DefaultScale {
        didSet{
            drawer.contentScaleFactor = contentScaleFactor
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var color: UIColor = UIColor.blackColor() {
        didSet{
            drawer.color = color
            setNeedsDisplay()
        }
    }
    
    private var lastOrigin: CGPoint?
    var origin: CGPoint {
        get {
            // if lastOrigin not set -> calculate 
            if lastOrigin == nil {
                let originX = bounds.width / 2
                let originY = bounds.height / 2
                lastOrigin = CGPoint(x:originX, y:originY)
            }
            return lastOrigin!
        }
        set {
            lastOrigin = newValue
            setNeedsDisplay()
        }
    }

    //var origin = CGPoint(x:0, y:0) { didSet{ setNeedsDisplay() } }
    
    private var xValues:[Double] {
        get {
            var values = [Double] ()
            let xFrom = -Int(origin.x / scale) - 1
            let xTo = xFrom + Int(bounds.width / scale) + 2
            for x in xFrom...xTo {
                for fraction in 0..<Constants.GraphFractionsXPrecision {
                    let xFraction = Double(x) + Double(fraction)/Double(Constants.GraphFractionsXPrecision)
                    values.append(xFraction)
                }
            }
            return values
        }
    }
    
    weak var dataSource: GraphViewDataSource?
    
    private var drawer = AxesDrawer()
    
    override func drawRect(rect: CGRect) {
        drawer.contentScaleFactor = contentScaleFactor
        drawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scale)
        
        let path = UIBezierPath()
        var isFirstX = true
        for x in xValues {
            let y = dataSource?.valueFor(Double(x))
            if  y != nil && (y!.isNormal || y!.isZero) {
                let pointX = origin.x + CGFloat(x) * scale
                let pointY = origin.y - CGFloat(y!) * scale
                let point = CGPoint(x: pointX, y: pointY)
                if isFirstX {
                    path.moveToPoint(point)
                    isFirstX = false
                }else{
                    path.addLineToPoint(point)
                }
            }else{
                isFirstX = true
            }
        }
        path.stroke()
    }

    private struct Constants {
        static let MoveGestureScaleFactor: CGFloat = 2
        static let DefaultScale: CGFloat = 1.0
        static let GraphFractionsXPrecision = 20
    }
    
    // ----------------------------------------------------------
    // MARK: - Actions
    // ----------------------------------------------------------
    
    @IBAction func moveGraph(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(self)
            let newOriginX = translation.x * Constants.MoveGestureScaleFactor
            let newOriginY = translation.y * Constants.MoveGestureScaleFactor
            origin = CGPoint(x: origin.x + newOriginX, y: origin.y + newOriginY)
            // reset gesture translation
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    @IBAction func scaleGraph(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    @IBAction func changeOriginGraph(gesture: UITapGestureRecognizer) {
        let translation = gesture.locationInView(self)
        let newOriginX = translation.x
        let newOriginY = translation.y
        origin = CGPoint(x: origin.x - newOriginX, y: origin.y - newOriginY)
    }
}
