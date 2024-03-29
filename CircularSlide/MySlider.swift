//
//  MySlider.swift
//  CircularSlide
//
//  Created by Dennis Christopher on 2017-12-21.
//  Copyright © 2017 DChristopher. All rights reserved.
//

import UIKit

// MARK: - helpers
private func degreeToRadian(degree: Double) -> Double {
    return Double(degree * (Double.pi/180))
}

private func radianToDegree(radian: Double) -> Double {
    return Double(radian * (180/Double.pi))
}

// MARK: - protocols
protocol MySliderDelegate: class {
    func slider(_ slider: MySlider, didChangeValue value: Float)
}

class MySlider: UIControl {

    weak var delegate: MySliderDelegate?
    lazy var sliderLayer = CAShapeLayer()
    lazy var thumbButton = UIButton(type: .custom)
    
    var startAngle: Float = 90.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var endAngle: Float = 180.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var currentAngle: Float = 180.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var sliderColor: UIColor = .gray {
        didSet {
            sliderLayer.strokeColor = sliderColor.cgColor
            self.setNeedsDisplay()
        }
    }
    
    var thumbColor: UIColor = .red {
        didSet {
            thumbButton.backgroundColor = thumbColor
            self.setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: private methods -
    
    private func initSubViews() {
        addSlider()
        addThumb()
    }
    
    private func addSlider() {
        let center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        
        let sAngle = degreeToRadian(degree: Double(startAngle))
        let eAngle = degreeToRadian(degree: Double(endAngle))
        
        let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)
        
        sliderLayer.path = path.cgPath
        sliderLayer.lineWidth = 4.0
        sliderLayer.lineCap = kCALineCapRound
        sliderLayer.strokeColor = sliderColor.cgColor
        sliderLayer.fillColor = UIColor.clear.cgColor
        
        if sliderLayer.superlayer == nil {
            self.layer.addSublayer(sliderLayer)
        }
    }
    
    private func addThumb() {
        //thumbButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        thumbButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        thumbButton.backgroundColor = thumbColor
        thumbButton.layer.cornerRadius = thumbButton.frame.size.width/2
        thumbButton.layer.masksToBounds = true
        thumbButton.isUserInteractionEnabled = false
        thumbButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        //thumbButton.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
        self.addSubview(thumbButton)
    }
    
    /*func pressButton(button: UIButton) {
     NSLog("pressed!")
     }*/
    
    private func updateThumbPosition() {
        let angle = degreeToRadian(degree: Double(currentAngle))
        
        let x = cos(angle)
        let y = sin(angle)
        
        var rect = thumbButton.frame
        
        let radius = self.frame.size.width * 0.5
        let center = CGPoint(x: radius, y: radius)
        let thumbCenter: CGFloat = 10.0
        
        // x = cos(angle) * radius + CenterX;
        let finalX = (CGFloat(x) * (radius - thumbCenter)) + center.x
        
        // y = sin(angle) * radius + CenterY;
        let finalY = (CGFloat(y) * (radius - thumbCenter)) + center.y
        
        rect.origin.x = finalX - thumbCenter
        rect.origin.y = finalY - thumbCenter
        
        thumbButton.frame = rect
        let btnDegree: Int = Int(currentAngle)
        let btnTitle = String(btnDegree)
        thumbButton.setTitle(btnTitle,for: .normal)
    }
    
    private func thumbMoveDidComplete() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [ .curveEaseOut, .beginFromCurrentState ], animations: { () -> Void in
            self.thumbButton.transform = .identity
        }, completion: { [weak self] _ in
            self?.fireValueChangeEvent()
        })
    }
    
    private func fireValueChangeEvent() {
        delegate?.slider(self, didChangeValue: currentAngle)
    }
    
    private func degreeForLocation(location: CGPoint) -> Double {
        let dx = location.x - (self.frame.size.width * 0.5)
        let dy = location.y - (self.frame.size.height * 0.5)
        
        let angle = Double(atan2(Double(dy), Double(dx)))
        
        var degree = radianToDegree(radian: angle)
        if degree < 0 {
            degree = 360 + degree
        }
        
        return degree
    }
    
    private func moveToPoint(point: CGPoint) -> Bool {
        var degree = degreeForLocation(location: point)
        
        func moveToClosestEdge(degree: Double) {
            let startDistance = fabs(Float(degree) - startAngle)
            let endDistance = fabs(Float(degree) - endAngle)
            
            if startDistance < endDistance {
                currentAngle = startAngle
            }
            else {
                currentAngle = endAngle
            }
        }
        
        if startAngle > endAngle {
            if degree < Double(startAngle) && degree > Double(endAngle) {
                moveToClosestEdge(degree: degree)
                thumbMoveDidComplete()
                return false
            }
        }
        else {
            if degree > Double(endAngle) || degree < Double(startAngle) {
                moveToClosestEdge(degree: degree)
                thumbMoveDidComplete()
                return false
            }
        }
        
        currentAngle = Float(degree)
        
        return true;
    }
    
    // MARK: public methods -
    
    func moveToAngle(angle: Float, duration: CFTimeInterval) {
        let center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        
        let sAngle = degreeToRadian(degree: Double(startAngle))
        let eAngle = degreeToRadian(degree: Double(angle))
        
        let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)
        
        CATransaction.begin()
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = duration
        animation.path = path.cgPath
        thumbButton.layer.add(animation, forKey: "moveToAngle")
        CATransaction.setCompletionBlock { [weak self] in
            self?.currentAngle = angle
        }
        CATransaction.commit()
    }
    
    
    // MARK: touch events -
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // print(event)
        let point = touch.location(in: self)
        
        let rect = self.thumbButton.frame.insetBy(dx: -20, dy: -20)
        
        let canBegin = rect.contains(point)
        
        if canBegin {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [ .curveEaseIn, .beginFromCurrentState ], animations: { () -> Void in
                self.thumbButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: nil)
        }
        
        return canBegin
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if #available(iOS 9, *) {
            guard let coalescedTouches = event?.coalescedTouches(for: touch) else {
                return moveToPoint(point: touch.location(in: self))
            }
            
            let result = true
            for cTouch in coalescedTouches {
                let result = moveToPoint(point: cTouch.location(in: self))
                
                if result == false { break }
            }
            
            return result
        }
        
        return moveToPoint(point: touch.location(in: self))
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbMoveDidComplete()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        
        let sAngle = degreeToRadian(degree: Double(startAngle))
        let eAngle = degreeToRadian(degree: Double(endAngle))
        
        let path = UIBezierPath(arcCenter: center, radius: (self.bounds.size.width - 18)/2, startAngle: CGFloat(sAngle), endAngle: CGFloat(eAngle), clockwise: true)
        sliderLayer.path = path.cgPath
        
        updateThumbPosition()
    }

}
