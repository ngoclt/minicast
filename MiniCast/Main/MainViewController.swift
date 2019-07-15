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
import GoogleCast

class MainViewController: UIViewController {
    
    private static let kCastControlBarsAnimationDuration: TimeInterval = 0.20

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
    
    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    
    var miniMediaControlsViewEnabled = false {
        didSet {
            if isViewLoaded {
                
            }
        }
    }
    
    var miniMediaControlsItemEnabled = false
    
    private var currentVideo: String? {
        didSet {
            addressBar.enabledCast = currentVideo != nil
        }
    }
    
    override func loadView() {
        super.loadView()
        
        view = webView
        
        navigationItem.titleView = addressBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let castContext = GCKCastContext.sharedInstance()
        miniMediaControlsViewController = castContext.createMiniMediaControlsViewController()
        miniMediaControlsViewController.delegate = self
        
        setupToolbar()
        loadUrl(URL(string: "https://24hphim.com/phim/boruto-naruto-the-he-ke-tiep-1544/xem-phim.html")!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Helpers
    
    private func setupToolbar() {
        let add = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(addTapped))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbarItems = [add, spacer]
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
        log.error(error)
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
            if let urlString = message.body as? String {
                currentVideo = urlString
                navigationController?.setToolbarHidden(false, animated: true)
            }
        }
    }
    
    @objc private func addTapped() {
        let metadata = GCKMediaMetadata()
        metadata.setString(webView.title ?? "Untitled", forKey: kGCKMetadataKeyTitle)
        
        let url = URL.init(string: currentVideo ?? "")
        guard let mediaURL = url else {
            print("invalid mediaURL")
            return
        }
        
        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: mediaURL)
        mediaInfoBuilder.streamType = .none
        mediaInfoBuilder.contentType = "video/mp4"
        mediaInfoBuilder.metadata = metadata
        let mediaInformation = mediaInfoBuilder.build()
        
        if let request = GCKCastContext.sharedInstance().sessionManager.currentSession?.remoteMediaClient?.loadMedia(mediaInformation) {
            request.delegate = self
        }
    }
}

extension MainViewController: GCKSessionManagerListener, GCKRequestDelegate {
    
}

extension MainViewController: GCKUIMiniMediaControlsViewControllerDelegate {
    
    func miniMediaControlsViewController(_: GCKUIMiniMediaControlsViewController,
                                         shouldAppear _: Bool) {
        
    }
}

extension MainViewController: Identifiable { }
