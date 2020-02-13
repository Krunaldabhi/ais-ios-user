//
//  AppData.swift
//  User
//
//  Created by CSS on 10/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

let AppName = "Cabbie"
var deviceTokenString = Constants.string.noDevice
let stripePublishableKey = "pk_test_DbfzA8Pv1MDErUiHakK9XfLe"
let googleMapKey = "AIzaSyDSStyENuXzpneM2izq_NMQ6OZ7AjVJlow"
let appSecretKey = "yEZPnjkdrIOVILo43t2DgRVb90oPjp9CZEmXAxb0"
let appClientId = 2
let passwordLengthMax = 10
let defaultMapLocation = LocationCoordinate(latitude: 13.009245, longitude: 80.212929)
let baseUrl = "https://cabbieuae.com/"

var supportNumber = "919585290750"
var supportEmail = "support@cabbieuae.com"
var offlineNumber = "57777"
let helpSubject = "\(AppName) Help"

let requestInterval : TimeInterval = 60
let requestCheckInterval : TimeInterval = 5
let driverBundleID = "com.cabbietransport.pilot"

// AppStore URL

enum AppStoreUrl : String {
    
    case user = "https://itunes.apple.com/us/app/Cabbie-User/id1492928392?ls=1&mt=8"
    case driver = "https://itunes.apple.com/us/app/cabbie-pilot/id1495166242?ls=1&mt=8"
    
}
