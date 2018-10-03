//
//  ViewController.swift
//  ElectricBillCalculator
//
//  Created by 田中良明 on 2018/09/28.
//  Copyright © 2018年 tanakayoshiaki. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, UITextFieldDelegate,GADBannerViewDelegate {
    
    let AdMobTest:Bool = true
    
    @IBOutlet var subBannerView: UIView!
    var bannerView: GADBannerView!
    
    @IBOutlet var sum: UILabel!
    @IBOutlet var powerConsumption: UITextField!
    @IBOutlet var unitPrice: UITextField!
    @IBOutlet var hours: UITextField!
    @IBOutlet var minutes: UITextField!
    @IBOutlet var days: UITextField!
    @IBOutlet var unitPriceData: UILabel!
    // UserDefaults のインスタンス
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // デフォルト値
        userDefaults.register(defaults: ["powerConsumption": "100" ])
        userDefaults.register(defaults: ["hours": "24" ])
        userDefaults.register(defaults: ["minutes": "0" ])
        userDefaults.register(defaults: ["days": "30" ])
        userDefaults.register(defaults: ["unitPrice": "19.52" ])
        
        // Keyを指定して読み込み
        powerConsumption.text = (userDefaults.object(forKey: "powerConsumption") as! String)
        hours.text = (userDefaults.object(forKey: "hours") as! String)
        minutes.text = (userDefaults.object(forKey: "minutes") as! String)
        days.text = (userDefaults.object(forKey: "days") as! String)
        unitPrice.text = (userDefaults.object(forKey: "unitPrice") as! String)
        
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        //subBannerView.addSubview(bannerView)
        
        addBannerViewToView(bannerView)
        
        
        self.powerConsumption.keyboardType = UIKeyboardType.numberPad
        self.hours.keyboardType = UIKeyboardType.numberPad
        self.minutes.keyboardType = UIKeyboardType.numberPad
        self.days.keyboardType = UIKeyboardType.numberPad
        self.unitPrice.keyboardType = UIKeyboardType.decimalPad
 


        
        powerConsumption.delegate = self
        hours.delegate = self
        minutes.delegate = self
        days.delegate = self
        unitPrice.delegate = self
        
        
        if AdMobTest {
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        }else{
            bannerView.adUnitID = "ca-app-pub-6789227322694215/9175089891"
        }
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self

        
        unitPriceData.text = "＜各電力会社の１kwWh毎の料金＞※2018年9月27日現在\n東京電力:19.52円　北海道電力:23.54円\n東北電力:18.24円 中部電力:20.68円\n北陸電力:17.52円　関西電力:19.95円\n中国電力:20.40円　四国電力:20円\n九州電力:17.19円 沖縄電力:22.53円"
        
        calculate(0)
        
    }
    
    @IBAction func calculatePowerConsumption(_ sender: UITextField) {
        // Keyを指定して保存
        userDefaults.set(powerConsumption.text, forKey: "powerConsumption")
        calculate(0)
    }
    
    @IBAction func calculateHours(_ sender: UITextField) {
        // Keyを指定して保存
        userDefaults.set(hours.text, forKey: "hours")
        calculate(0)
    }
    @IBAction func calculateMinutes(_ sender: UITextField) {
        // Keyを指定して保存
        userDefaults.set(minutes.text, forKey: "minutes")
        calculate(0)
    }
    
    @IBAction func calculateDays(_ sender: UITextField) {
        // Keyを指定して保存
        userDefaults.set(days.text, forKey: "days")
        calculate(0)
    }
    
    @IBAction func calculateUnitPrice(_ sender: UITextField) {
        // Keyを指定して保存
        userDefaults.set(unitPrice.text, forKey: "unitPrice")
        calculate(0)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func calculate(_ sender: Any) {
        // データの同期
        userDefaults.synchronize()
        
        let resultPowerConsumption:Float? = Float(powerConsumption.text!)
        let resultHours:Float? = Float(hours.text!)
        let resultMinutes:Float? = Float(minutes.text!)
        let resultDays:Float? = Float(days.text!)
        let resultUnitPrice:Float? = Float(unitPrice.text!)
        
        
        
        if resultPowerConsumption != nil && resultHours != nil && resultDays != nil && resultUnitPrice != nil && resultMinutes != nil {
            if ((resultUnitPrice! > 100000) || (resultHours! > 100000) || (resultDays! > 100000) || (resultMinutes! > 100000) || (resultPowerConsumption! > 100000)){
                sum.text = "--"
            }else{
                let text:String = String(Int(resultPowerConsumption! * resultDays! * (resultHours! + resultMinutes! / 60) * resultUnitPrice! / 1000))
                sum.text = text
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        /*view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: topLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
         */
        bannerView.topAnchor.constraint(equalTo: subBannerView.topAnchor, constant: 10).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}


