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

    var webView: WKWebView!
    var urlField: UISearchBar!
    
    override func loadView() {
        super.loadView()
    
        let wkWebConfig = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: wkWebConfig)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUrlAddressField()
        prepareToolbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadUrl(URL(string: "https://24hphim.com/")!)
    }
    
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
        webView.load(URLRequest(url: url))
    }

    private func showSnackBarForMessage(_ message: String) {
        guard let snackbar = snackbarController?.snackbar else {
            return
        }
        
        snackbar.text = message
        
        _ = snackbarController?.animate(snackbar: .visible, delay: 1)
        _ = snackbarController?.animate(snackbar: .hidden, delay: 4)
    }
}

extension MainViewController {
    private func prepareUrlAddressField() {
        urlField = UISearchBar(frame: .zero)
        urlField.placeholder = "Enter URL"
        urlField.setImage(Icon.edit, for: .search, state: .normal)
        urlField.autocorrectionType = .no
        urlField.autocapitalizationType = .none
        urlField.returnKeyType = .go
        urlField.spellCheckingType = .no
        urlField.searchBarStyle = .prominent
        urlField.delegate = self
        navigationItem.titleView = urlField
    }
    
    private func prepareCastButton() {
        
    }
    
    private func prepareToolbar() {
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [refresh]
        navigationController?.isToolbarHidden = false
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let url = validateUrlString(searchBar.text) else {
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
        showSnackBarForMessage(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let urlString = navigationAction.request.url?.absoluteString,
            let inputUrl = urlField.text,
            urlString.contains(inputUrl) {
            urlField.text = urlString
        }
        
        decisionHandler(.allow)
    }
}

extension MainViewController: WKUIDelegate {
    
}

extension MainViewController: Identifiable { }
