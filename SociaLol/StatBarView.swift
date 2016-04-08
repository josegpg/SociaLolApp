//
//  StatBarView.swift
//  SociaLol
//
//  Created by Jose Piñero on 4/7/16.
//  Copyright © 2016 José Piñero. All rights reserved.
//

import UIKit

public class StatBarView: UIView {
    
    var statImage: UIImageView!
    var bar: UIView!
    var barColor1: UIView!
    var barColor2: UIView!
    
    var gradient: CAGradientLayer!
    
    public enum StatBarType: String {
        case AdBar="ad"
        case LifeBar="life"
        case ApBar="ap"
        case DifficultyBar="difficulty"
    }
    
    // ADBAR COLORS
    static let redColor = UIColor(r: 92.0, g: 31.0, b: 31.0)
    static let shadowRedColor = UIColor(r: 77, g: 10, b: 10)
    
    // LIFEBAR COLORS
    static let greenColor = UIColor(r: 22, g: 58, b: 22)
    static let shadowGreenColor = UIColor(r: 0, g: 40, b: 0)
    
    // APBAR COLORS
    static let blueColor = UIColor(r: 27, g: 53, b: 86)
    static let shadowBlueColor = UIColor(r: 6, g: 35, b: 71)
    
    // DIFFICULTYBAR COLORS
    static let purpleColor = UIColor(r: 65, g: 26, b: 82)
    static let shadowPurpleColor = UIColor(r: 48, g: 5, b: 66)
    
    let barToColor: [StatBarType: GradientColors] = [
        StatBarType.AdBar: GradientColors(firstColor: redColor, secondColor: shadowRedColor),
        StatBarType.LifeBar: GradientColors(firstColor: greenColor, secondColor: shadowGreenColor),
        StatBarType.ApBar: GradientColors(firstColor: blueColor, secondColor: shadowBlueColor),
        StatBarType.DifficultyBar: GradientColors(firstColor: purpleColor, secondColor: shadowPurpleColor)
    ]
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        statImage = UIImageView(frame: CGRectMake(15.0, 0.0, 20.0, 20.0))
        statImage.contentMode = .ScaleToFill
        
        bar = UIView(frame: CGRectMake(37.0, 0.0, 2.0, 20.0))
        bar.layer.borderWidth = 1.0
        bar.layer.borderColor = UIColor.lightTextColor().CGColor
        
        barColor1 = UIView(frame: CGRectMake(37.0, 0.0, 2.0, 10.0))
        barColor2 = UIView(frame: CGRectMake(37.0, 10.0, 2.0, 10.0))
        
        addSubview(statImage)
        addSubview(barColor1)
        addSubview(barColor2)
        addSubview(bar)
        
        backgroundColor = UIColor.clearColor()
        
        
        statImage.image = UIImage(named: "profile-placeholder")
        
    }
    
    func drawWithStyle(barStyle: StatBarType, barValue: CGFloat, annimationDelay: Double) {
        
        // Set header image
        statImage.image = UIImage(named: barStyle.rawValue)
        
        // Min 2, max 248
        let barWidth = barValue / 10.0 * 246.0 + 2.0
        let newRect = CGRectMake(bar.origin.x, bar.origin.y, barWidth, bar.frame.height)
        
        
        // Set bar colors
        let colors = barToColor[barStyle]!
        let newRect1 = CGRectMake(barColor1.origin.x, barColor1.origin.y, barWidth, barColor1.frame.height)
        let newRect2 = CGRectMake(barColor2.origin.x, barColor2.origin.y, barWidth, barColor2.frame.height)
        
        barColor1.backgroundColor = colors.firstColor
        barColor2.backgroundColor = colors.secondColor
        
        UIView.animateWithDuration(1.0, delay: annimationDelay, options: .CurveEaseOut, animations: {
            self.bar.frame = newRect
            self.barColor1.frame = newRect1
            self.barColor2.frame = newRect2
        }, completion: nil)
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSize(width: 300, height: 20)
    }
    
    
    struct GradientColors {
        var firstColor: UIColor
        var secondColor: UIColor
    }
    
    
}