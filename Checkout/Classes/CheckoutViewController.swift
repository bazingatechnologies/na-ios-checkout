//
//  CheckoutViewController.swift
//  Checkout
//
//  Created by Sven Resch on 2016-06-01.
//  Copyright © 2017 Bambora Inc. All rights reserved.
//

import UIKit

/*
 Adding our Checkout SDK to your app could not be easier. You simply create and 
 display this view controller. Checkout is configured by setting data attributes 
 on this view controller. It can be configured to collect shipping and billing 
 addresses in addition to the card details.
 
 The required parameters are:
   amount: the amount you are going to charge the customer
   currency: the currency
   orderId: the id of the order (bazinga! only)
 
 The optional parameters are:
   name: your company name
   image: your company logo
   purchaseDescription: a description of the purchase
   shippingAddress: if the shipping address is required – true/false
   billingAddress: if the billing address is required – true/false
   primaryColor: the primary header color of the form. Default is blue.
   brands: the valid brand list
   shouldShowEmail: whether or not it should show the email field
   textColor: Set a color for the text. Default color becomes transparent in dark mode.
   placeholderColor: Set a color for the placeholder. Default color becomes transparent in dark mode.
 */
open class CheckoutViewController: UIViewController {
    
    // MARK: - Private properties

    @IBOutlet fileprivate weak var headerView: UIView!
    @IBOutlet fileprivate weak var footerView: UIView!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var amountLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    
    // MARK: - Public properties
    
    @objc open var amount: NSDecimalNumber = NSDecimalNumber(value: 1.0 as Double)
    @objc open var currencyCode: String = "CAD"
    @objc open var orderId: String = ""
    @objc open var name: String?
    @objc open var image: UIImage?
    @objc open var purchaseDescription: String?
    @objc open var brands: Array<String>?
    @objc open var placeholderColor: UIColor? = UIColor.black
    @objc open var textColor: UIColor? = UIColor.orange
    
    @objc open var shippingAddressRequired: Bool = true
    @objc open var billingAddressRequired: Bool = true
    @objc open var shouldShowEmail: Bool = true
    @objc open var shippingAddress: Address?
    @objc open var billingAddress: Address?
    
    @objc open var primaryColor: UIColor = Settings.primaryColor {
        didSet {
            Settings.primaryColor = primaryColor
        }
    }
    
    @objc open var processingClosure: ((_ result: Dictionary<String, AnyObject>?, _ error: NSError?) -> Void)?
    
    @objc open var tokenRequestTimeoutSeconds = Settings.tokenRequestTimeout {
        didSet {
            Settings.tokenRequestTimeout = tokenRequestTimeoutSeconds
        }
    }
    
    // MARK: - View controller methods
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.modalPresentationStyle = .formSheet
        }
        State.sharedInstance.reset()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.modalPresentationStyle = .formSheet
        }
        State.sharedInstance.reset()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        State.sharedInstance.amountStr = CheckoutViewController.localizedCurrencyAmount(self.amount, currencyCode: self.currencyCode)
        State.sharedInstance.processingClosure = self.processingClosure
        State.sharedInstance.billingAddressRequired = self.billingAddressRequired
        State.sharedInstance.brands = self.brands
        State.sharedInstance.orderId = self.orderId
        State.sharedInstance.shouldShowEmail = self.shouldShowEmail
        State.sharedInstance.placeholderColor = self.placeholderColor
        State.sharedInstance.textColor = self.textColor
        
        self.headerView.backgroundColor = self.primaryColor
        
        if self.image == nil {
            // Set the default image to use template based color
            self.imageView.tintColor = self.headerView.backgroundColor
        }
        else {
            self.imageView.image = self.image
        }
        
        self.nameLabel.text = self.name
        self.amountLabel.text = State.sharedInstance.amountStr
        self.descriptionLabel.text = self.purchaseDescription
        self.footerView.alpha = 0
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showFooter),
            name: NSNotification.Name(rawValue: "ShowFooter"),
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideFooter),
            name: NSNotification.Name(rawValue: "HideFooter"),
            object: nil)
    }

    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation
    
    // This method is executed before viewDidLoad.
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController, segue.identifier == "navController" {
            if !self.billingAddressRequired && !self.shippingAddressRequired {
                // Re-jig the nav controller to have a PaymentViewController as its root
                let storyboard = self.storyboard!
                if let paymentController = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
                    navController.viewControllers = [paymentController]
                }
            }
        }
    }
    
    // MARK: - Custom action methods
    
    @IBAction func closeButtonAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showFooter() {
        UILabel.beginAnimations(nil, context: nil)
        UILabel.setAnimationDuration(0.25)
        self.footerView.alpha = 1
        UILabel.commitAnimations()
    }

    @objc func hideFooter() {
        UILabel.beginAnimations(nil, context: nil)
        UILabel.setAnimationDuration(0.25)
        self.footerView.alpha = 0
        UILabel.commitAnimations()
    }

    // MARK: - Private methods
    
    fileprivate static func localizedCurrencyAmount(_ amount:NSDecimalNumber, currencyCode:String) -> String {
        let formatter = NumberFormatter()
        formatter.currencyCode = currencyCode
        formatter.numberStyle = NumberFormatter.Style.currency
        if let localized = formatter.string(from: amount) {
            return localized
        }
        else {
            return "0.0"
        }
    }

}
