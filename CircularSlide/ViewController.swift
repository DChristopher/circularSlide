//
//  ViewController.swift
//  CircularSlide
//
//  Created by Dennis Christopher on 2017-12-21.
//  Copyright © 2017 DChristopher. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MySliderDelegate {
    let slider = MySlider()
    var lastValue: Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        slider.frame = CGRect(x: (self.view.frame.size.width - 200) * 0.5, y: (self.view.frame.size.height - 200) * 0.5, width: 200, height: 200)
        slider.startAngle = 120
        slider.endAngle = 119  //90    //60
        slider.currentAngle = 120
        //slider.thumbColor = UIColor(colorLiteralRed: 242.0/255.0, green: 107.0/255.0, blue: 107.0/255.0, alpha: 1.0)
        slider.thumbColor = UIColor(colorLiteralRed: 107.0/255.0, green: 107.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        slider.sliderColor = UIColor(colorLiteralRed: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        slider.delegate = self
        self.view.addSubview(slider)
        lastValue = 0.0
    }

    func slider(_ slider: MySlider, didChangeValue value: Float) {
        print(value)
        if let last = lastValue {
            if abs(value - last) < 1.0 {
                print("touch up inside")
                // 270 is the implicit max angle
                let randomAngle = Float(arc4random_uniform(270))
                slider.moveToAngle(angle: randomAngle, duration: 1.0)
            }
            lastValue = value
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        slider.moveToAngle(angle: 0, duration: 1.0)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        slider.frame = CGRect(x: (self.view.frame.size.width - 200) * 0.5, y: (self.view.frame.size.height - 200) * 0.5, width: 200, height: 200)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

