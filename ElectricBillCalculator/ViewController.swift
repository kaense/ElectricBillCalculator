//
//  ViewController.swift
//  ElectricBillCalculator
//
//  Created by 田中良明 on 2018/09/28.
//  Copyright © 2018年 tanakayoshiaki. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, UITextFieldDelegate,GADBannerViewDelegate{
    
    @IBOutlet var scrollView: UIScrollView!
    // 現在選択されているTextField
    var selectedTextField:UITextField?
    
    let AdMobTest:Bool = false
    
    @IBOutlet var subBannerView: UIView!
    var bannerView: GADBannerView!
    
    @IBOutlet var sum: UILabel!
    @IBOutlet var powerConsumption: UITextField!{
        didSet {
            powerConsumption?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForPowerConsumption)))
        }
    }
    @IBOutlet var unitPrice: UITextField!{
        didSet {
            unitPrice?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForUnitPrice)))
        }
    }
    @IBOutlet var hours: UITextField!{
        didSet {
            hours?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForHours)))
        }
    }
    @IBOutlet var minutes: UITextField!{
        didSet {
            minutes?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMinutes)))
        }
    }
    @IBOutlet var days: UITextField!{
        didSet {
            days?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForDays)))
        }
    }
    @IBOutlet var unitPriceData: UILabel!
    
    @objc func doneButtonTappedForUnitPrice() {
        unitPrice.resignFirstResponder()
    }
    @objc func doneButtonTappedForPowerConsumption() {
        powerConsumption.resignFirstResponder()
    }
    @objc func doneButtonTappedForHours() {
        hours.resignFirstResponder()
    }
    @objc func doneButtonTappedForMinutes() {
        minutes.resignFirstResponder()
    }
    @objc func doneButtonTappedForDays() {
        days.resignFirstResponder()
    }
    

    // UserDefaults のインスタンス
    let userDefaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // キーボードイベントの監視開始
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeShown(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        

        // キーボードイベントの監視解除
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    // キーボード以外をタップするとキーボードが下がるメソッド
    @objc func hideKyeoboardTap(recognizer : UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tapされた時の動作を宣言する: 一度タップされたらキーボードを隠す
        let hideTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKyeoboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)

    
        self.textFieldInit() // TextFieldのセットアップ
        
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
                let resultInt = Int(resultPowerConsumption! * resultDays! * (resultHours! + resultMinutes! / 60) * resultUnitPrice! / 1000)
                let num = NSNumber(value: resultInt)
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.decimal
                formatter.groupingSeparator = ","
                formatter.groupingSize = 3
                let resultString = formatter.string(from: num)
                sum.text = resultString
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*powerConsumption.resignFirstResponder()
        unitPrice.resignFirstResponder()
        days.resignFirstResponder()
        hours.resignFirstResponder()
        minutes.resignFirstResponder()
        */
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

extension ViewController{
    
    func textFieldInit() {
        // 最初に選択されているTextFieldをセット
        self.selectedTextField = self.powerConsumption
        
        // 各TextFieldのdelegate 色んなイベントが飛んでくるようになる
        self.powerConsumption.delegate = self
        self.unitPrice.delegate = self
        self.hours.delegate = self
        self.minutes.delegate = self
        self.days.delegate = self
        
    }
    
    // キーボードが表示された時に呼ばれる
    @objc func keyboardWillBeShown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                restoreScrollViewSize()
                
                let convertedKeyboardFrame = scrollView.convert(keyboardFrame, from: nil)
                // 現在選択中のTextFieldの下部Y座標とキーボードの高さから、スクロール量を決定
                let offsetY: CGFloat = self.selectedTextField!.frame.maxY - convertedKeyboardFrame.minY
                if offsetY < 0 { return }
                updateScrollViewSize(moveSize: offsetY, duration: animationDuration)
            }
        }
    }
    
    // キーボードが閉じられた時に呼ばれる
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        restoreScrollViewSize()
    }
    
    // TextFieldが選択された時
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 選択されているTextFieldを更新
        self.selectedTextField = textField
    }
    
    
    // moveSize分Y方向にスクロールさせる
    func updateScrollViewSize(moveSize: CGFloat, duration: TimeInterval) {
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(duration)
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: moveSize, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.contentOffset = CGPoint(x: 0, y: moveSize)
        
        UIView.commitAnimations()
    }
    
    func restoreScrollViewSize() {
        // キーボードが閉じられた時に、スクロールした分を戻す
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        //let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            //UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    //@objc func cancelButtonTapped() { self.resignFirstResponder() }
}
