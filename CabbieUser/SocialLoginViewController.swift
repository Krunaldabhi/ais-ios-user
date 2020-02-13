//
//  SocailLoginViewController.swift
//  User
//
//  Created by CSS on 02/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookLogin
import FacebookCore
import AccountKit
import AuthenticationServices
import FirebaseAuth
import PhoneVerificationController

class SocialLoginViewController: UITableViewController {
    
    //MARK:- Local Variable
    
    private let tableCellId = "SocialLoginCell"
    private var isfaceBook = false
    private var accessToken : String?
    private var is_SignInApple = false
    private var SocialMedia_Type = 0
    private lazy var loader : UIView = {
        return createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.localize()
        self.navigationController?.isNavigationBarHidden = false
    }
}

// MARK:- Local Methods

extension SocialLoginViewController {
    
    private func initialLoads() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:  #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
         GIDSignIn.sharedInstance().clientID = "1040987739433-ned79anlaeq4p76l9k9copol5qau0oku.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    private func localize() {
        
        self.navigationItem.title = Constants.string.chooseAnAccount.localize()
    }
    
    //  Socail Login
    
    private func didSelect(at indexPath : IndexPath) {
       
        accessToken = nil // reset access token
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            self.facebookLogin()
            User.main.loginType = LoginType.facebook.rawValue
        case (0,1):
            self.googleLogin()
            User.main.loginType = LoginType.google.rawValue
        case (0,2):
            self.actionHandleAppleSignin()
            User.main.loginType = LoginType.apple.rawValue

        default:
            break
        }
        
    }
    
    
    // MARK:- Google Login
    
    private func googleLogin(){
        
        self.loader.isHidden = false
        self.isfaceBook = false
        is_SignInApple = false
        SocialMedia_Type = 2
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    
    // MARK:- Facebook Login
    
    private func facebookLogin() {
         SocialMedia_Type = 1
        is_SignInApple = false
        self.isfaceBook = true
        print("Facebook")
        let loginManager = LoginManager()
        loginManager.loginBehavior = .browser
        loginManager.logIn(permissions: [ .publicProfile, .email], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
                break
            case .cancelled:
                print("Cancelled")
                break
            case .success(_ , _, let accessToken):
                print(accessToken)
                self.accessToken = accessToken.tokenString
                self.accountKit()
                break
            }
        }
    }
    
    // MARK:- Sign in with Apple
    func actionHandleAppleSignin() {
          SocialMedia_Type = 3
      
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            
            let request = appleIDProvider.createRequest()
                 is_SignInApple = true
                  request.requestedScopes = [.fullName, .email]

                  let authorizationController = ASAuthorizationController(authorizationRequests: [request])

                  authorizationController.delegate = self

                  authorizationController.presentationContextProvider = self

                  authorizationController.performRequests()
            
        } else {
            // Fallback on earlier versions
        }

      

    }
    
    
    
    private func loadAPI(accessToken: String?,phoneNumber: Int?, loginBy: LoginType,country_code: String?){
        self.loader.isHidden = false
        let user = UserData()
        user.accessToken = accessToken
        user.device_id = UUID().uuidString
        user.device_token = deviceTokenString
        user.device_type = .ios
        user.login_by = loginBy
        user.mobile = phoneNumber
        user.country_code = "+\(country_code!)"
        
        var apiType = ""  //: Base = isfaceBook ? .facebookLogin : .googleLogin
        
        if SocialMedia_Type == 1 {
            apiType = String(Base.facebookLogin.rawValue)
        }else if SocialMedia_Type == 2 {
            apiType = String(Base.googleLogin.rawValue)
        }else if SocialMedia_Type == 3 {
            apiType = String(Base.signinAppleLogin.rawValue)
        }
        
        self.presenter?.post(api: Base(rawValue: apiType)!, data: user.toData())
        
    }
    
    
    private func accountKit(){
//        let accountKit = AccountKitManager(responseType: .accessToken)
//        let accountKitVC = accountKit.viewControllerForPhoneLogin()
//        accountKitVC.isSendToFacebookEnabled = true
//        self.prepareLogin(viewcontroller: accountKitVC)
//        self.present(accountKitVC, animated: true, completion: nil)
        
      

        let configuration = Configuration(requestCode: { phone, completion in
            
            PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil, completion: completion)
            
        }, signIn: { verificationID, verificationCode, completion in
            
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
             Auth.auth().signIn(with: credential) { _, error in completion(error)
                
                if error != nil{
                    self.view.make(toast: error.debugDescription)
                }else{
                        
                }
                
                
            }
        })
        
        
        let vc = PhoneVerificationController(configuration: configuration)
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    private func prepareLogin(viewcontroller : UIViewController&AKFViewController) {
        
        viewcontroller.delegate = self
        viewcontroller.uiManager = SkinManager(skinType: .contemporary, primaryColor: .primary)
    }
    
}

// MARK:- AKFViewControllerDelegate
extension SocialLoginViewController : AKFViewControllerDelegate {
    
    func viewControllerDidCancel(_ viewController: (UIViewController & AKFViewController)) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController), didFailWithError error: Error) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController), didCompleteLoginWith accessToken: AKFAccessToken, state: String) {
        print(state)
        viewController.dismiss(animated: true) {
            //self.loader.isHidden = false
            //self.presenter?.post(api: .signUp, data: self.userSignUpInfo?.toData())
            
            AccountKitManager(responseType: ResponseType.accessToken).requestAccount({ (account, error) in
                
                // self.accessToken = accessToken as! String
                guard let number = account?.phoneNumber?.phoneNumber, let code = account?.phoneNumber?.countryCode, let numberInt = Int(number) else {
                    self.onError(api: .addPromocode, message: .Empty, statusCode: 0)
                    return
                }
                
                var loginBy = ""
                
                if self.SocialMedia_Type == 1 {
                   loginBy = String(LoginType.facebook.rawValue)
                }else if self.SocialMedia_Type == 2 {
                   loginBy = String(LoginType.google.rawValue)
                }else if self.SocialMedia_Type == 3 {
                   loginBy = String(LoginType.apple.rawValue)
               }
               //let loginBy : LoginType = self.isfaceBook ? .facebook : .google
                
            
                
                self.loadAPI(accessToken: self.accessToken, phoneNumber: numberInt, loginBy: LoginType(rawValue: loginBy)!,country_code: code)
                
            })
            
        }
        
    }
}

// MARK:- TableView

extension SocialLoginViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let tableCell = tableView.dequeueReusableCell(withIdentifier: self.tableCellId, for: indexPath) as? SocialLoginCell {
            
            
            if indexPath.row == 0 {
                 tableCell.imageViewTitle.isHidden = false
                 tableCell.labelTitle.isHidden = false
                tableCell.imageViewTitle2.isHidden = true
                 tableCell.labelTitle.text = Constants.string.facebook
                 tableCell.imageViewTitle.image = #imageLiteral(resourceName: "fb_icon")
            } else if indexPath.row == 1 {
                tableCell.imageViewTitle.isHidden = false
                tableCell.labelTitle.isHidden = false
                tableCell.imageViewTitle2.isHidden = true
                 tableCell.labelTitle.text = Constants.string.google
                  tableCell.imageViewTitle.image =  #imageLiteral(resourceName: "google_icon")
            }else {
                tableCell.imageViewTitle.isHidden = true
                 tableCell.labelTitle.isHidden = true
                tableCell.imageViewTitle2.isHidden = false
                 tableCell.labelTitle.text = Constants.string.SignInwithApple
                tableCell.imageViewTitle2.isHidden = false
                
            }
           
            return tableCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.didSelect(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

//MARK:- Google Implementation


extension SocialLoginViewController : GIDSignInDelegate {
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        self.loader.isHidden = true
        
        guard user != nil else {
            return
        }
        self.accessToken = user.authentication.accessToken
        print(user.profile, error)
        accountKit()
        //  UserData.main.set(name: String.removeNil(user.profile.name), email: String.removeNil(user.profile.email),image: String.removeNil(user.profile.imageURL(withDimension: 50).absoluteString))
        
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        self.loader.isHidden = true
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        
        present( viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension SocialLoginViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    func getProfile(api: Base, data: Profile?) {
        
        if api == .getProfile {
            Common.storeUserData(from: data)
            storeInUserDefaults()
            self.navigationController?.present(Common.setDrawerController(), animated: true, completion: nil)
        }
        loader.isHideInMainThread(true)
        
    }
    
    func getOath(api: Base, data: LoginRequest?) {
        if api == .signinAppleLogin || api == .facebookLogin || api == .googleLogin, let accessTokenString = data?.access_token {
            User.main.accessToken = accessTokenString
            User.main.refreshToken =  data?.refresh_token
            self.presenter?.get(api: .getProfile, parameters: nil)
        }
    }
}

extension SocialLoginViewController: PhoneVerificationDelegate {
    func cancelled(controller: PhoneVerificationController) {
        print("Cancelled verification")
        controller.dismiss(animated: true)
    }

    func verified(phoneNumber: String, CountryCode: String, controller: PhoneVerificationController) {
        print("Verified phone \(phoneNumber)")
        print("Verified Code \(CountryCode)")
        controller.dismiss(animated: true)
        
        
        var loginBy = ""
            
            if self.SocialMedia_Type == 1 {
               loginBy = String(LoginType.facebook.rawValue)
            }else if self.SocialMedia_Type == 2 {
               loginBy = String(LoginType.google.rawValue)
            }else if self.SocialMedia_Type == 3 {
               loginBy = String(LoginType.apple.rawValue)
           }
           //let loginBy : LoginType = self.isfaceBook ? .facebook : .google
            
        
            
        self.loadAPI(accessToken: self.accessToken, phoneNumber: Int(phoneNumber), loginBy: LoginType(rawValue: loginBy)!,country_code: CountryCode)
    }
}

//MARK:- Sign in Apple

extension SocialLoginViewController: ASAuthorizationControllerDelegate {

     // ASAuthorizationControllerDelegate function for authorization failed

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

        print(error.localizedDescription)

    }

       // ASAuthorizationControllerDelegate function for successful authorization

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            // Create an account as per your requirement
            

            let appleId = appleIDCredential.user

            let appleUserFirstName = appleIDCredential.fullName?.givenName

            let appleUserLastName = appleIDCredential.fullName?.familyName

            let appleUserEmail = appleIDCredential.email
            
            print(appleIDCredential)
            
            let str_identityToken = String(decoding: appleIDCredential.identityToken!, as: UTF8.self)
            
            print("User id is \(appleId) \n Full Name is \(String(describing: appleIDCredential.fullName)) \n Email id is \(String(describing: appleIDCredential.email)) \n Token is \(String(describing: str_identityToken))")
            
            self.accessToken = str_identityToken
            self.accountKit()

            //Write your code

        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {

            let appleUsername = passwordCredential.user

            let applePassword = passwordCredential.password

            self.accessToken = passwordCredential.user
            self.accountKit()

        }

    }

}

extension SocialLoginViewController: ASAuthorizationControllerPresentationContextProviding {

    //For present window

    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

        return self.view.window!

    }

}


class SocialLoginCell : UITableViewCell {
    
    @IBOutlet weak var imageViewTitle : UIImageView!
    @IBOutlet weak var labelTitle : UILabel!
    @IBOutlet weak var imageViewTitle2 : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setDesign()
    }
    
    // MARK:- Set Designs
    
    private func setDesign() {
        Common.setFont(to: self.labelTitle, isTitle: true)
    }
    
    
    
}

