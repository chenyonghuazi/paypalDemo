//
//  ViewController.swift
//  paypalDemo
//
//  Created by Edwin chen on 2018/8/24.
//  Copyright © 2018年 Edwin. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree

class ViewController: UIViewController,PayPalPaymentDelegate {
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("hey")
        dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("paymentSucceed")
        dismiss(animated: true, completion: nil)
    }
    
    

    
    var paymentButton:UIButton = {
        let a = UIButton()
        a.setTitle("Pay the Bill", for: UIControlState.normal)
        a.setTitleColor(UIColor.black, for: UIControlState.normal)
        return a
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPaymentButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupPaymentButton(){
        view.addSubview(paymentButton)
        paymentButton.frame = CGRect(origin: view.center, size: CGSize(width: 100, height: 60))
        paymentButton.addTarget(self, action: #selector(handlePaymentClicked), for: UIControlEvents.touchUpInside)
    }
    @objc func handlePaymentClicked(){
        setupPaypal()
    }
    
    func setupPaypal(){
        PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentSandbox)
        
        let paypalConf = PayPalConfiguration()
        paypalConf.acceptCreditCards = true
        paypalConf.payPalShippingAddressOption = PayPalShippingAddressOption.payPal
        paypalConf.merchantName = "UChill"
        paypalConf.languageOrLocale = NSLocale.preferredLanguages.first
        let payment = PayPalPayment()
        payment.amount = NSDecimalNumber(string: "31.61")
        payment.currencyCode = "CAD"
        payment.shortDescription = "包含小费"
        if !payment.processable{
            // error
        }
        let paymentVC = PayPalPaymentViewController(payment: payment, configuration: paypalConf, delegate: self)
        if paymentVC != nil{
            self.present(paymentVC!, animated: true, completion: nil)
        }
    }
    

    
    func fetchClientToken() {
        // TODO: Switch this URL to your own authenticated API
        let clientTokenURL = NSURL(string: "https://braintree-sample-merchant.herokuapp.com/client_token")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            if error == nil{
                guard let clientToken = String(data: data!, encoding: String.Encoding.utf8) else{return}
                DispatchQueue.main.async {
                    self.showDropIn(clientTokenOrTokenizationKey: clientToken)
                }
            }else{
                print(error!.localizedDescription)
            }
            // As an example, you may wish to present Drop-in at this point.
            // Continue to the next section to learn more...
            }.resume()
    }
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }

}

