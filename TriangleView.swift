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
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        let pointyness: CGFloat = 15
        linePath.move(to: CGPoint(x: 0, y: rect.maxY-pointyness))
        linePath.addLine(to: CGPoint(x: rect.maxX/2, y: rect.maxY))
        linePath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY-pointyness))
        line.path = linePath.cgPath
        line.strokeColor = UIColor.primary.darker(by:5).cgColor
        line.fillColor = UIColor.clear.cgColor
        line.lineWidth = 2
        line.lineJoin = kCALineJoinRound
        layer.addSublayer(line)
        
        return
    }
}

