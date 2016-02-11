//
//  Color.swift
//  OneMinuteChanges
//
//  Created by Scott Austin on 2/4/16.
//  Copyright © 2016 europaSoftware. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Colors
let kLightGreenColor = UIColor(red:135.0/255.0, green:252.0/255.0, blue:112.0/255.0, alpha:1.0)
let kMidGreenColor = UIColor(red:99.0/255.0, green:218.0/255.0, blue:56.0/255.0, alpha:1.0)
let kDarkGreenColor = UIColor(red:12.0/255.0, green:211.0/255.0, blue:24/255.0, alpha:1.0)

let kLightGreyColor = UIColor(red:220.0/255.0, green:221.0/255.0, blue:222.0/255.0, alpha:1.0)
let kDarkGreyColor = UIColor(red:136.0/255.0, green:139.0/255.0, blue:144.0/255.0, alpha:1.0)

let kLightBlueColor = UIColor(red:25.0/255.0, green:214.0/255.0, blue:253.0/255.0, alpha:1.0)
let kMidBlueColor = UIColor(red:86.0/255.0, green:183.0/255.0, blue:241.0/255.0, alpha:1.0)
let kDarkBlueColor = UIColor(red:29.0/255.0, green:98.0/255.0, blue:240.0/255.0, alpha:1.0)

let kLightPinkColor = UIColor(red:255.0/255.0, green:41.0/255.0, blue:141.0/255.0, alpha:1.0)
let kDarkPinkColor = UIColor(red:255.0/255.0, green:41.0/255.0, blue:105.0/255.0, alpha:1.0)

let kRedColor = UIColor(red:255.0/255.0, green:59.0/255.0, blue:48.0/255.0, alpha:1.0)

let kLightOrangeColor = UIColor(red:255.0/255.0, green:149.0/255.0, blue:0.0/255.0, alpha:1.0)
let kDarkOrangeColor = UIColor(red:255.0/255.0, green:94.0/255.0, blue:58.0/255.0, alpha:1.0)

let kLightTealColor = UIColor(red:81.0/255.0, green:237.0/255.0, blue:198.0/255.0, alpha:1.0)

let kLightPurpleColor = UIColor(red:239.0/255.0, green:77.0/255.0, blue:182.0/255.0, alpha:1.0)
let kDarkPurpleColor = UIColor(red:199.0/255.0, green:67.0/255.0, blue:252.0/255.0, alpha:1.0)

let kBrownColor = UIColor(red:162.0/255.0, green:132.0/255.0, blue:94.0/255.0, alpha:1.0)

let kYellowColor = UIColor(red:234.0/255.0, green:187.0/255.0, blue:0.0/255.0, alpha:1.0)

// MARK: - Gradients
func gradientWithStartColor(startColor: UIColor, endColor: UIColor) -> CAGradientLayer
{
    let gradient = CAGradientLayer()
    gradient.colors = [startColor.CGColor, endColor.CGColor]
    
    return gradient
}

let kLightGreenToDarkGreenGradient = gradientWithStartColor(kLightGreenColor, endColor: kDarkGreenColor)
let kFaceTimeGradient = kLightGreenToDarkGreenGradient
let kMessagesGradient = kLightGreenToDarkGreenGradient

let kLightGreyToDarkGreyGradient = gradientWithStartColor(kLightGreyColor, endColor:kDarkGreyColor)
let kCameraGradient = kLightGreyToDarkGreyGradient
let kSettingsGradient = kLightGreyToDarkGreyGradient

let kDarkBlueToLightBlueGradient = gradientWithStartColor(kDarkBlueColor, endColor:kLightBlueColor)
let kWeatherGradient = kDarkBlueToLightBlueGradient
let kMailGradient = kDarkBlueToLightBlueGradient

let kLightBlueToDarkBlueGradient = gradientWithStartColor(kLightBlueColor, endColor: kDarkBlueColor)
let kAppStoreGradient = kLightBlueToDarkBlueGradient

let kDarkPinkToDarkOrangeGradient = gradientWithStartColor(kDarkPinkColor, endColor:kDarkOrangeColor)
let kMusicGradient = kDarkPinkToDarkOrangeGradient

let kLightTealToMidBlueGradient = gradientWithStartColor(kLightTealColor, endColor: kMidBlueColor)
let kVideosGradient = kLightTealToMidBlueGradient

let kLightPurpleToDarkPurpleGradient = gradientWithStartColor(kLightPurpleColor, endColor: kDarkPurpleColor)
let kITunesStoreGradient = kLightPurpleToDarkPurpleGradient


