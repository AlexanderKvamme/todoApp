//
//  TriangleView.swift
//  todoApp
//
//  Created by Alexander K on 19/07/2018.
//  Copyright © 2018 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class TriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let overdraw: CGFloat = 10
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY+overdraw))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        context.closePath()
        context.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.60)
        
        // Gradient
        
        context.fillPath()
    }
}
