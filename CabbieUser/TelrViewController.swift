//
//  TelrViewController.swift
//  TranxitUser
//
//  Created by Hardik Parmar on 07/12/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit
import TelrSDK

class TelrHelper {

    static let KEY:String = "74nj-vNR32^3fLXv"  // TODO fill key
    static let STOREID:String = "22707"         // TODO fill store id
    
    public class func preparePaymentRequest(forAmount amount:String) -> PaymentRequest{
        
        let paymentReq = PaymentRequest()
        
        paymentReq.key = KEY
        paymentReq.store = STOREID
        paymentReq.appId = Bundle.main.bundleIdentifier ?? "com.cabbie"
        paymentReq.appName = "TelrSDK"
        paymentReq.appUser = "\(User.main.id) ?? 123456"
        paymentReq.appVersion = "0.0.1"
        paymentReq.transTest = "0"
        paymentReq.transType = "auth"
        paymentReq.transClass = "paypage"
        paymentReq.transCartid = String(arc4random())
        paymentReq.transDesc = "cabbie-payment-gateway"
        paymentReq.transCurrency = "AED"
        paymentReq.transAmount = amount
        paymentReq.transLanguage = "en"
        paymentReq.billingEmail = User.main.email ?? ""
        paymentReq.billingFName = User.main.firstName ?? ""
        paymentReq.billingLName = User.main.lastName ?? ""
        paymentReq.country = "AE"
        paymentReq.billingPhone = User.main.mobile ?? ""
        
        return paymentReq
    }
    
    public class func preparePaymentRequest(forAmount amount:String, withTransactionId transactionId:String) -> PaymentRequest{
        
        let paymentReq = PaymentRequest()
        paymentReq.key = KEY
        paymentReq.store = STOREID
        paymentReq.appId = Bundle.main.bundleIdentifier ?? "com.cabbie"
        paymentReq.appName = "TelrSDK"
        paymentReq.appUser = "\(User.main.id) ?? 123456"
        paymentReq.appVersion = "0.0.1"
        paymentReq.transTest = "0"
        paymentReq.transType = "sale"
        paymentReq.transClass = "cont"
        paymentReq.transCartid = String(arc4random())
        paymentReq.transDesc = "cabbie-payment-gateway"
        paymentReq.transCurrency = "AED"
        paymentReq.transAmount = amount
        paymentReq.transRef = transactionId
        return paymentReq
    }
    
}

class ResultController: TelrResponseController {
    
    
    @IBOutlet var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = message!
        if let ref = tranRef{
            saveData(key: Keys.list.telr_transaction_id, value: ref)
        }
        if let last4 = cardLast4{
            saveData(key: Keys.list.cardLast4Digits, value: last4)
        }
        
        // Return payment results
        /*
         print(trace!)
         print(status!)
         print(avs!)
         print(code!)
         print(ca_valid!)
         print(cardCode!)
         print(cardLast4!)
         print(cvv!)
         print(tranRef!)
         */
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) { [weak self] in
            guard let self = `self` else { return }
            // Dismiss the view Controller
            let presenter = self.presentingViewController
            self.dismiss(animated: true, completion: {
               UIApplication.topViewController()?.navigationController?.popViewController(animated:    true)
                presenter?.dismiss(animated: true, completion: nil)
                
            })
        }
        
    }
    
    private func saveData(key:String, value:String){
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
}
