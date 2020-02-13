//
//  otpverfiyVC.swift
//  Provider
//
//  Created by iMac on 08/01/20.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit
import FirebaseAuth

class otpverfiyVC: UIViewController,PostViewProtocol {
    
    
     public var str_Verification : String?
    
   public var userInfoTmp : UserData?
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
   
    private lazy var loader : UIView = {
           return createActivityIndicator(self.view)
       }()
    var userSignUpInfo : UserData?
    var completion : ((Bool)->())?
    var otp  = [String]()
    var pinstr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.textField1.delegate = self as? UITextFieldDelegate
        self.textField2.delegate = self as? UITextFieldDelegate
        self.textField3.delegate = self as? UITextFieldDelegate
        self.textField4.delegate = self as? UITextFieldDelegate
        self.textField5.delegate = self as? UITextFieldDelegate
        self.textField6.delegate = self as? UITextFieldDelegate
        
        self.textField1.keyboardType = .numberPad
        self.textField2.keyboardType = .numberPad
        self.textField3.keyboardType = .numberPad
        self.textField4.keyboardType = .numberPad
        self.textField5.keyboardType = .numberPad
        self.textField6.keyboardType = .numberPad
        
        textField1.addTarget(self, action: #selector(self.myTargetFunction(textField:)), for: .touchDown)
        textField2.addTarget(self, action: #selector(self.myTargetFunction(textField:)), for: .touchDown)
        textField3.addTarget(self, action: #selector(self.myTargetFunction(textField:)), for: .touchDown)
        textField4.addTarget(self, action: #selector(self.myTargetFunction(textField:)), for: .touchDown)
        textField5.addTarget(self, action: #selector(self.myTargetFunction(textField:)), for: .touchDown)
        textField6.addTarget(self, action: #selector(self.myTargetFunction(textField:)), for: .touchDown)

        
        textField1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textField2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textField3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textField4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textField5.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textField6.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        // Do any additional setup after loading the view.
    }
    func showToast(string:String) {
        self.view.makeToast(string, duration: 1.0, position: .top)
    }
    @IBAction func verfiyBtn(_ sender: UIButton) {
        
        if (textField1.text == ""){
            self.alert()
        }
        else if (textField2.text == ""){
             self.alert()
        }
        else if (textField3.text == ""){
             self.alert()
        }
        else if (textField4.text == ""){
             self.alert()
        }
        else if (textField5.text == ""){
            self.alert()
            
        }
        else if (textField6.text == ""){
             self.alert()
        }
        else
        {
           
            let str_Code = "\(textField1.text!)\(textField2.text!)\(textField3.text!)\(textField4.text!)\(textField5.text!)\(textField6.text!)"
            
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.str_Verification!, verificationCode: str_Code)
            
            
            Auth.auth().signIn(with: credential) { (user, error) in
              if let error = error {
                // ...
                return
              }
              // User is signed in
              // Here sign in completed.
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("otpback"), object: nil)
                self.dismiss(animated: false, completion: nil)
              }
            
                            
            
        }
        
                                           
            
    }
        
    @IBAction func backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func onError(api: Base, message: String, statusCode code: Int) {
            DispatchQueue.main.async {
                self.loader.isHidden = true
                self.showToast(string: message)
            }
    }
       
      
            
    
        
        
        
   
    func alert(){
        let alt =  UIAlertController(title: "", message: "Please Enter otp", preferredStyle: .alert)
        
        let ok =  UIAlertAction(title: "Ok", style: .cancel) { (action) in
            print("ok")
        }
        alt.addAction(ok)
        self.present(alt, animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(textField: UITextField){
           let text = textField.text
           
           
           
           if  text?.count == 1 {
               
               switch textField{
               case textField1:
                   textField2.becomeFirstResponder()
                   
               case textField2:
                   textField3.becomeFirstResponder()
                  
               case textField3:
                   textField4.becomeFirstResponder()
                  
               case textField4:
                   textField5.becomeFirstResponder()
                   
               case textField5:
                   textField6.becomeFirstResponder()
                 
                   
               case textField6:
                   textField6.resignFirstResponder()
                  
                  
               default:
                   break
               }
           }
           else{
           }
       }
       func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           
           if let text = textField.text {
               
               // 10. when the user enters something in the first textField it will automatically adjust to the next textField and in the process do some disabling and enabling. This will proceed until the last textField
               if (text.count < 1) && (string.count > 0) {
                   
                   if textField == textField1 {
                       textField2.becomeFirstResponder()
                      
                       
                   }
                   
                   if textField == textField2 {
                       textField3.becomeFirstResponder()
                      
                       
                   }
                   
                   if textField == textField3 {
                       textField4.becomeFirstResponder()
                       
                       
                   }
                   if textField == textField4 {
                       textField5.becomeFirstResponder()
                      
                       
                   }
                   if textField == textField5 {
                       textField6.becomeFirstResponder()
                       
                       
                       
                   }
                   if textField == textField6 {
                       // do nothing
                       textField.resignFirstResponder()
                   }
                  
                   
                   textField.text = string
                   return false
                   
               } // 11. if the user gets to the last textField and presses the back button everything above will get reversed
                   //            else if (text.count >= 1) && (string.count == 0) {
                   //
                   //                if textField == secondTxt {
                   //                    firstTxt.becomeFirstResponder()
                   //                    firstTxt.text = ""
                   //                    self.firstImg.image = UIImage.init(named: "Rectangle 1 copy")
                   //
                   //                }
                   //
                   //                if textField == thirdTxt {
                   //                    secondTxt.becomeFirstResponder()
                   //                    secondTxt.text = ""
                   //                    self.secondImg.image = UIImage.init(named: "Rectangle 1 copy")
                   //
                   //                }
                   //
                   //                if textField == fourthTxt {
                   //                    thirdTxt.becomeFirstResponder()
                   //                    thirdTxt.text = ""
                   //                    self.thirdImg.image = UIImage.init(named: "Rectangle 1 copy")
                   //
                   //                }
                   //
                   //                if textField == firstTxt {
                   //                    // do nothing
                   //                }
                   //
                   //                textField.text = ""
                   //                return false
                   //
                   //            } // 12. after pressing the backButton and moving forward again you will have to do what's in step 10 all over again
               else if text.count >= 1 {
                   
                   if textField == textField1 {
                       textField2.becomeFirstResponder()
                       
                       
                   }
                   
                   if textField == textField2 {
                       textField3.becomeFirstResponder()
                    
                       
                   }
                   
                   if textField == textField3 {
                       textField4.becomeFirstResponder()
                       
                       
                   }
                   if textField == textField4 {
                       textField5.becomeFirstResponder()
                       
                       
                   }
                   if textField == textField5 {
                       textField6.becomeFirstResponder()
                      
                       
                       
                   }
                   if textField == textField6 {
                       // do nothing
                       textField.resignFirstResponder()
                   }
                   
                   textField.text = string
                   return false
               }
           }
           return true
       }
       
       @objc func myTargetFunction(textField: UITextField) {
           
        
           switch textField{
           case textField1:
                if #available(iOS 12.0, *) {
                           if textField.textContentType == UITextContentType.oneTimeCode{
                   
                                   //here split the text to your four text fields
                   
                                   if let otpCode = textField.text, otpCode.count > 5{
                   
                                       textField1.text = String(otpCode[otpCode.startIndex])
                                       textField2.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 1)])
                                       textField3.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 2)])
                                       textField4.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 3)])
                                       textField5.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 4)])
                                       textField6.text = String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: 5)])
                                       self.pinstr = otpCode
                                       
                                   }
                               }
                           } else {
                               // Fallback on earlier versions
                           }
               
               
           case textField2:
            print(textField2.text!)
               
           case textField3:
            print(textField3.text!)
               
           case textField4:
            print(textField4.text!)
               
           case textField5:
            print(textField5.text!)
               
           case textField6:
            print(textField6.text!)
               
               
           default:
               break
           }
           
       }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
