//
//  SubscriptionViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/07/23.
//

import UIKit
import StoreKit
import NVActivityIndicatorView

class SubscriptionViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var thirdBenefitSubSubLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var thirdView: UIView!
    @IBOutlet weak var fourthView: UIView!
    @IBOutlet weak var secondVIew: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var retrieveLabel: UIButton! //actually its a button
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var fourthBenefitSubLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    @IBOutlet weak var thirdBenefitLabel: UILabel!
    @IBOutlet weak var sceondBenefitLabel: UILabel!
    @IBOutlet weak var firstBenefitLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    
    let font = Font()
    let fb = Firebase()
    var model : SKProduct!
    let userDefault = UserDefaults.standard
    var activityIndicatorView: NVActivityIndicatorView! = nil
    
    let productsIDsToRestore = "moody.premiumPass"
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        setupFont()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //observer
        SKPaymentQueue.default().add(self)
        setupUI()
        setupFont()
        fetchProducts()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            guard let product = response.products.first else {
                // Handle the case when no products are available
                print("NO PRODUCT")
                return
            }
            // Rest of the implementation...
            self.model = product
            self.setupInfo()
        }
    }
    
    //MARK: BUTTON
    @IBAction func retrieveButton(_ sender: Any) {
        activityIndicatorView.startAnimating()
        
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @IBAction func buyButton(_ sender: Any) {
        activityIndicatorView.startAnimating()
        if model != nil {
            let payment = SKPayment(product: model!)
            SKPaymentQueue.default().add(payment)
        } else {
            activityIndicatorView.stopAnimating()
            let alert = UIAlertController(title: String(format: NSLocalizedString("실패했습니다", comment: "")), message: "", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: String(format: NSLocalizedString("네", comment: "")), style: .default, handler: nil)
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func fetchProducts(){
        let request = SKProductsRequest(productIdentifiers: Set(Subscription.allCases.compactMap({$0.rawValue})))
        print(Subscription.allCases.compactMap({$0.rawValue}))
        request.delegate = self
        request.start()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach ({
            switch $0.transactionState {
            case.purchased:
                self.userDefault.set("true", forKey: "premiumPass")
                self.userDefault.set("true", forKey: "needSendToServer")
                if let url = Bundle.main.appStoreReceiptURL,
                   let data = try? Data(contentsOf: url) {
                    let receiptBase64 = data.base64EncodedString()
                    // Send to server
                    self.fb.saveSubscriptionInfo(premiumID: receiptBase64, completion: {
                        self.userDefault.set("false", forKey: "needSendToServer")
                    })
                }
                buyButton.isHidden = true
                retrieveLabel.isHidden = true
                
                activityIndicatorView.stopAnimating()
                queue.finishTransaction($0)
                break
            case .failed:
                let alert = UIAlertController(title: String(format: NSLocalizedString("실패했습니다", comment: "")), message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: String(NSLocalizedString("네", comment: "")), style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true)
                
                activityIndicatorView.stopAnimating()
                queue.finishTransaction($0)
            case .restored:
                self.userDefault.set("true", forKey: "premiumPass")
                self.userDefault.set("true", forKey: "needSendToServer")
                if let url = Bundle.main.appStoreReceiptURL,
                   let data = try? Data(contentsOf: url) {
                    let receiptBase64 = data.base64EncodedString()
                    // Send to server
                    self.fb.saveSubscriptionInfo(premiumID: receiptBase64, completion: {
                        self.userDefault.set("false", forKey: "needSendToServer")
                    })
                }
                buyButton.isHidden = true
                retrieveLabel.isHidden = true
                
                activityIndicatorView.stopAnimating()
                queue.finishTransaction($0)
            default:
                print("on purchase..")
                activityIndicatorView.startAnimating()
            }
        })
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        activityIndicatorView.startAnimating()
        
        self.userDefault.set("true", forKey: "premiumPass")
        self.userDefault.set("true", forKey: "needSendToServer")
        
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
        
        if let url = Bundle.main.appStoreReceiptURL,
           let data = try? Data(contentsOf: url) {
            let receiptBase64 = data.base64EncodedString()
            // Send to server
            self.fb.saveSubscriptionInfo(premiumID: receiptBase64, completion: {
                self.userDefault.set("false", forKey: "needSendToServer")
            })
        } else {
            self.fb.saveSubscriptionInfo(premiumID: "not found", completion: {
                self.userDefault.set("false", forKey: "needSendToServer")
            })
        }
        
        buyButton.isHidden = true
        retrieveLabel.isHidden = true
        
        activityIndicatorView.stopAnimating()
        
        let alert = UIAlertController(title: String(NSLocalizedString("성공했습니다", comment: "")), message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: String(NSLocalizedString("네", comment: "")), style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        let alert = UIAlertController(title: String(NSLocalizedString("실패했습니다", comment: "")), message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: String(NSLocalizedString("네", comment: "")), style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

extension SubscriptionViewController {
    private func setupInfo() {
        priceLabel.text = "\(model.priceLocale.currencySymbol ?? "₩")\(model.price)"
    }
    
    private func setupUI() {
        firstView.layer.cornerRadius = 15
        secondVIew.layer.cornerRadius = 15
        thirdView.layer.cornerRadius = 15
        fourthView.layer.cornerRadius = 15
        buyButton.layer.cornerRadius = 15
        
        if userDefault.string(forKey: "premiumPass") == "true"  {
            buyButton.isHidden = true
            retrieveLabel.isHidden = true
        } else {
            buyButton.isHidden = false
            retrieveLabel.isHidden = false
        }
        
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
        introLabel.font = font.subSize
        titleLabel.font = font.subSize
        priceLabel.font = font.titleSize
        firstBenefitLabel.font = font.subSize
        sceondBenefitLabel.font = font.subSize
        thirdBenefitLabel.font = font.subSize
        thirdBenefitSubSubLabel.font = font.subSize
        fourthLabel.font = font.subSize
        fourthBenefitSubLabel.font = font.dateSize
        explanationLabel.font = font.subSize
        retrieveLabel.titleLabel?.font = font.sub2Size
        buyButton.titleLabel?.font = font.title2Size
    }
}
