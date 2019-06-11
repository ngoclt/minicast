//
//  ViewController.swift
//  MiniCast
//
//  Created by Ngoc Le on 07/06/2019.
//  Copyright © 2019 Coder Life. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import Material

class MainViewController: UIViewController {

    private lazy var addressBar: AddressBarView = {
        let view = AddressBarView(frame: .zero)
        view.delegate = self
        return view
    } ()
    
    
    private lazy var webView: WKWebView = {
        let contentController = WKUserContentController()
        
        if let jsSource = Bundle.main.url(forResource: "video_play_messenger", withExtension: "js"),
            let jsSourceString = try? String(contentsOf: jsSource) {
            let userScript = WKUserScript(source: jsSourceString, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            
            contentController.addUserScript(userScript)
            contentController.add(self, name: "callbackHandler")
        }
        
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = contentController
        
        let view = WKWebView(frame: .zero, configuration: wkWebConfig)
        view.uiDelegate = self
        view.navigationDelegate = self
        
        return view
    } ()
    
    override func loadView() {
        super.loadView()
        
        view = webView
        
        navigationItem.titleView = addressBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUrl(URL(string: "https://24hphim.com/phim/boruto-naruto-the-he-ke-tiep-1544/xem-phim.html")!)
    }
    
    // MARK: - Helpers
    
    private func validateUrlString(_ urlString: String?) -> URL? {
        guard let urlString = urlString else {
            return nil
        }
        
        var url: URL?
        if urlString.starts(with: "http://") || urlString.starts(with: "https://") {
            url = URL(string: urlString)
        } else {
            url = URL(string: "http://\(urlString)")
        }
        
        return url
    }
    
    private func loadUrl(_ url: URL) {
        addressBar.text = url.absoluteString
        webView.load(URLRequest(url: url))
    }
}

extension MainViewController: AddressBarViewDelegate {
    
    func addressBarView(_ addressBarView: AddressBarView, goTo url: String?) {
        
        guard let url = validateUrlString(addressBarView.text) else {
            return
        }
        
        loadUrl(url)
    }
}

extension MainViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        let error = error as NSError
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        if let urlString = navigationAction.request.url?.absoluteString,
            let inputUrl = addressBar.text,
            urlString.contains(inputUrl) {
            addressBar.text = urlString
        }
        
        decisionHandler(.allow)
    }
}

extension MainViewController: WKUIDelegate {
    
}

extension MainViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "callbackHandler" {
            if let messageString = message.body as? String {
                print(messageString)
            }
        }
    }
}

extension MainViewController: Identifiable { }
