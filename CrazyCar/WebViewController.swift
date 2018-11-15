//
//  WebViewController.swift
//  CarsGame
//
//  Created by roy on 2018/6/22.
//  Copyright © 2018年 Nitay&Raz. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class WebViewController: UIViewController {
    
    var urlStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.configuration.userContentController.add(self, name: "AppModel")
        webView.configuration.userContentController.add(self, name: "cp")
        
        NotificationCenter.default.addObserver(self, selector: #selector(backToActivity), name: NSNotification.Name(rawValue: "backToActivity"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "AppModel")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "cp")
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func backToActivity() {
        let openReload = "window.openReload()"
        webView.evaluateJavaScript(openReload) { (result, error) in
            guard error == nil else {
                return
            }
            guard result != nil else {
                return
            }
        }
    }

    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        // 设置偏好设置
        config.preferences = WKPreferences()
        // 默认为0
        config.preferences.minimumFontSize = 10
        // 默认认为YES
        config.preferences.javaScriptEnabled = true
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        // 通过JS与webview内容交互
        config.userContentController = WKUserContentController()
        
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
    
    func commonInit() {
        let url = URL.init(string: urlStr)
        guard url != nil else {
            return
        }
        
        self.view.addSubview(webView)
        webView.load(URLRequest(url: url!))
        webView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(view)
        }
        
    }
    
    func setTitle(str: String) {
        title = str
    }
    
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        webView.snp.remakeConstraints { (make) in
            let systemVerison = UIDevice.current.systemVersion
            let versionNumber = Float(systemVerison)
            
            guard versionNumber == nil else {
                if versionNumber! >= 11.0 {
                    make.top.equalTo(view).offset(-20)
                }else {
                    make.top.equalTo(view).offset(0)
                }
                make.left.right.bottom.equalTo(view)
                return
            }
            
            make.top.equalTo(view).offset(0)
            make.left.right.bottom.equalTo(view)
        }
    }

}

extension WebViewController: WKNavigationDelegate {
    
}

extension WebViewController: WKScriptMessageHandler {
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func analysisCommand(text: String) -> [String:AnyObject]? {
        let startIndex = text.index(of: "(") != nil ? text.index(of: "(")! : text.startIndex
        let endIndex = text.index(of: ")") != nil ? text.index(of: ")")! : text.endIndex
        
        let jsonStr = text[text.index(after: startIndex)..<endIndex]
        let dic = convertStringToDictionary(text: String(jsonStr))
        return dic
    }
    
    func evaluateJS() {
        
        webView.evaluateJavaScript("navigator.userAgent") {[weak webView] (result, error) in
            guard error == nil else {
                return
            }
            guard var resultStr = result as? String else {
                return
            }
            
            //resetting user agent
            var versionStr = ""
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                versionStr = version
            }
            resultStr += " appName/\(Bundle.main.bundleIdentifier!) appVersion/v\(versionStr)"
            webView?.customUserAgent = resultStr
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let body = message.body as? Dictionary<String,String>
        guard let bodyStr = body?["body"] else {
            return
        }
        
        if bodyStr.contains("setTitle") {
            let dic = analysisCommand(text: bodyStr)
            
            guard dic != nil else {
                return
            }
            if let title = dic!["title"] as? String {
                setTitle(str: title)
            }
        }
        if bodyStr.contains("hideTitleBar") {
            hideNavigationBar()
        }
        if bodyStr.contains("exit") {
            self.navigationController?.popViewController(animated: true)
        }
        
        if bodyStr.contains("openSafari") {
            let dic = analysisCommand(text: bodyStr)
            
            guard dic != nil else {
                return
            }
            guard let urlStr = dic!["url"] as? String else {
                return
            }
            
            if let url = URL(string: urlStr) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        evaluateJS()
    }
}

extension WebViewController: WKUIDelegate {
    
}
