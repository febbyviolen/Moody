//
//  ConnectGoogleAccountViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/07/08.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import NVActivityIndicatorView
import AuthenticationServices

class AccountConnectViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var stackView3: UIStackView!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var stackView1: UIStackView!
    
    @IBOutlet weak var unconnectButton: UIButton!
    @IBOutlet weak var appleStartConnectingButton: UIButton!
    @IBOutlet weak var startConnectingButton: UIButton!
    @IBOutlet weak var secondRuleButton: UIButton!
    @IBOutlet weak var firstRuleButton: UIButton!
    
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label10: UILabel!
    @IBOutlet weak var label9: UILabel!
    @IBOutlet weak var label8: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    
    let font = Font()
    let userDefault = UserDefaults.standard
    let fb = Firebase()
    
    var activityIndicatorView: NVActivityIndicatorView! = nil
    
    var firstRule = false
    var secondRule = false
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if userDefault.string(forKey: "userEmail") != nil {
            stackView1.isHidden = true
            stackView2.isHidden = true
            stackView3.isHidden = true
            label1.text = String(format: NSLocalizedString("connection.message", comment: ""))
            label1.textAlignment = .center
            
            unconnectButton.layer.cornerRadius = 10
            unconnectButton.isHidden = false
            unconnectButton.titleLabel?.font = font.title2Size
        } else {
            setupFont()
            setupUI()
        }
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func firstRuleButton(_ sender: Any) {
        firstRule = !firstRule
        firstRuleButton.setImage(firstRule ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle"), for: .normal)
        
        if firstRule && secondRule {
            startConnectingButton.isEnabled = true
            appleStartConnectingButton.isEnabled = true
        } else {
            startConnectingButton.isEnabled = false
            appleStartConnectingButton.isEnabled = false
        }
    }
    
    @IBAction func secondRuleButton(_ sender: Any) {
        secondRule = !secondRule
        secondRuleButton.setImage(secondRule ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle"), for: .normal)
        
        if firstRule && secondRule {
            startConnectingButton.isEnabled = true
            appleStartConnectingButton.isEnabled = true
        } else {
            startConnectingButton.isEnabled = false
            appleStartConnectingButton.isEnabled = false
        }
    }
    
    @IBAction func unconnect(_ sender: Any) {
        userDefault.set(nil, forKey: "userEmail")
        userDefault.set(nil, forKey: "userID")
        self.userDefault.set("false", forKey: "premiumPass")
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func googleStartConnectingButton(_ sender: Any) {
        if firstRule && secondRule {
            
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            activityIndicatorView.startAnimating()
            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
                guard error == nil else {
                    // ...
                    print("Google sign-in error: \(error!.localizedDescription)")
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString
                else {
                    // ...
                    return
                }
                
                //alert
                checkIfGoogleAccountExists(idToken: idToken, completion: { str, uid in
                    
                    self.activityIndicatorView.stopAnimating()
                    if str != "false" {
                        // Create a new UIAlertController
                        let alertController = UIAlertController(title: "", message: String(format: NSLocalizedString("merge_data_message", comment: "")), preferredStyle: .alert)

                        // Add actions
                        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                            self.fb.transferUserData(idToken: uid) {
                                self.fb.deleteUser(user: self.userDefault.string(forKey: "userID")!, date: Date())
                                self.userDefault.set(uid, forKey: "userID")
                                self.userDefault.set(user.profile?.email, forKey: "userEmail")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                        yesAction.setValue(UIColor(named: "black"), forKey: "titleTextColor")
                        
                        let noAction = UIAlertAction(title: "No", style: .default) { _ in
                            self.fb.transferUserDataNoMerge(idToken: uid) {
                                self.fb.deleteUser(user: self.userDefault.string(forKey: "userID")!, date: Date())
                                self.userDefault.set(uid, forKey: "userID")
                                self.userDefault.set(user.profile?.email, forKey: "userEmail")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                        noAction.setValue(UIColor(named: "black"), forKey: "titleTextColor")
                        
                        alertController.addAction(noAction)
                        alertController.addAction(yesAction)

                        // Present the alert controller
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        //if there is no google account exists
                        self.fb.transferUserDataNoMerge(idToken: uid) {
                            self.fb.deleteUser(user: self.userDefault.string(forKey: "userID")!, date: Date())
                            self.userDefault.set(uid, forKey: "userID")
                            self.userDefault.set(user.profile?.email, forKey: "userEmail")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }
        }
        
        func checkIfGoogleAccountExists(idToken: String, completion: @escaping (String, String) -> Void) {
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: "")
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Firebase authentication error: \(error.localizedDescription)")
                    completion("false", "")
                    return
                }
                
                // Successfully signed in with Google
                if authResult?.additionalUserInfo?.isNewUser == true {
                    // Google account is not registered with Firebase
                    completion("false", authResult!.user.uid)
                } else {
                    // Google account is already registered with Firebase
                    completion("true", authResult!.user.uid)
                }
            }
        }
    }
    
    @IBAction func appleStartConnectingButton(_ sender: Any) {
        if firstRule && secondRule {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.email, .fullName]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

//MARK: APPLE LOGIN
extension AccountConnectViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        //if failed
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        //if success
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            //get credentials data here
            
            self.activityIndicatorView.startAnimating()
            guard let appleIDToken = credentials.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let nonce = userDefault.string(forKey: "userID")!
            
            let userCredential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: credentials.fullName)
            
            isRegisteredUser(credential: userCredential) { str, uid in
                
                self.activityIndicatorView.stopAnimating()
                if str != "false" {
                    // Create a new UIAlertController
                    let alertController = UIAlertController(title: "", message: String(format: NSLocalizedString("merge_data_message", comment: "")), preferredStyle: .alert)

                    // Add actions
                    let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                        self.fb.transferUserData(idToken: uid) {
                            self.fb.deleteUser(user: self.userDefault.string(forKey: "userID")!, date: Date())
                            self.userDefault.set(uid, forKey: "userID")
                            self.userDefault.set(credentials.email ?? credentials.fullName?.givenName ?? "apple", forKey: "userEmail")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                    yesAction.setValue(UIColor(named: "black"), forKey: "titleTextColor")
                    
                    let noAction = UIAlertAction(title: "No", style: .default) { _ in
                        self.fb.transferUserDataNoMerge(idToken: uid) {
                            self.fb.deleteUser(user: self.userDefault.string(forKey: "userID")!, date: Date())
                            self.userDefault.set(uid, forKey: "userID")
                            self.userDefault.set(credentials.email ?? credentials.fullName?.givenName ?? "apple", forKey: "userEmail")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                    noAction.setValue(UIColor(named: "black"), forKey: "titleTextColor")
                    
                    alertController.addAction(noAction)
                    alertController.addAction(yesAction)

                    // Present the alert controller
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    //if there is no google account exists
                    self.fb.transferUserDataNoMerge(idToken: uid) {
                        self.fb.deleteUser(user: self.userDefault.string(forKey: "userID")!, date: Date())
                        self.userDefault.set(uid, forKey: "userID")
                        self.userDefault.set(credentials.email ?? credentials.fullName?.givenName ?? "apple", forKey: "userEmail")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            break
        default:
            break
        }
    }
    
    private func isRegisteredUser(credential: OAuthCredential, completion: @escaping (String, String) -> Void) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Firebase authentication error: \(error.localizedDescription)")
                completion("false", "" )
                return
            }
            
            // Successfully signed in with Apple
            if authResult?.additionalUserInfo?.isNewUser == true {
                completion("false", authResult!.user.uid)
            } else {
                completion("true", authResult!.user.uid)
            }
        }
        
    }
    
}

extension AccountConnectViewController: ASAuthorizationControllerPresentationContextProviding {
    
    //set which kind of window you want the device to pop
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension AccountConnectViewController {
    private func setupUI() {
        stackView1.layer.cornerRadius = 15
        stackView1.layer.borderColor = UIColor(named: "black")!.cgColor
        stackView1.layer.borderWidth = 1
        stackView1.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        startConnectingButton.layer.cornerRadius = 10
        startConnectingButton.isEnabled = false
        startConnectingButton.setTitleColor(UIColor.systemGray2, for: .disabled)
        
        appleStartConnectingButton.layer.cornerRadius = 10
        appleStartConnectingButton.isEnabled = false
        appleStartConnectingButton.setTitleColor(UIColor.systemGray2, for: .disabled)
        
        unconnectButton.isHidden = true
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let center = CGPoint(x: screenWidth/2, y: screenHeight/2)
        
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let type = NVActivityIndicatorType.ballPulse
        let color = UIColor(named: "black")
        let padding: CGFloat = 0
        
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: type, color: color, padding: padding)
        
        activityIndicatorView.center = center
        self.view.addSubview(activityIndicatorView)
    }
    
    private func setupFont() {
        label1.font = font.subSize
        label2.font = font.subSize
        label3.font = font.sub2Size
        label4.font = font.subSize
        label5.font = font.sub2Size
        label6.font = font.subSize
        label7.font = font.sub2Size
        label8.font = font.subSize
        label9.font = font.sub2Size
        label10.font = font.subSize
        label11.font = font.dateSize
        
        firstRuleButton.titleLabel?.font = font.sub2Size
        secondRuleButton.titleLabel?.font = font.sub2Size
        startConnectingButton.titleLabel?.font = font.title2Size
        appleStartConnectingButton.titleLabel?.font = font.title2Size
        unconnectButton.titleLabel?.font = font.title2Size
    }
    
}
