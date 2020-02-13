//
//  LottieHelper.swift
//  User
//
//  Created by CSS on 08/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation
import Lottie

typealias LottieView = AnimationView

class LottieHelper {

    func addLottie(file : String = "heart", with frame : CGRect)->LottieView{
        
        let heartView = AnimationView(name: file)
        heartView.frame = frame
        return heartView
    }
}
