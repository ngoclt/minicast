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
    
    private lazy var airPlayButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        button.setImage(#imageLiteral(resourceName: "Image"), for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapOnAirPlayButton), for: .touchUpInside)
        button.tintColor = .gray
        return button
    } ()
    
    private lazy var castButton: GCKUICastButton = {
        let button = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        button.tintColor = .gray
        return button
    } ()
    
    private lazy var urlLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 24))
        label.fontSize = 11.0
        label.textColor = .gray
        return label
    } ()
    
    private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
    
    var miniMediaControlsItemEnabled = false {
        didSet {
            airPlayButton.isEnabled = currentVideo != nil
        }
    }
    
    private var currentVideo: String? {
        didSet {
            airPlayButton.isEnabled = miniMediaControlsItemEnabled
            castButton.isEnabled = currentVideo != nil
            urlLabel.text = currentVideo
            urlLabel.sizeToFit()
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addressBar.canGoBack = webView.canGoBack
    }
    
    // MARK: - Helpers
    
    private func setupToolbar() {
        let urlBarButtonItem = UIBarButtonItem(customView: urlLabel)
        let airPlayBarButtonItem = UIBarButtonItem(customView: airPlayButton)
        let castBarButtonItem = UIBarButtonItem(customView: castButton)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbarItems = [spacer, urlBarButtonItem, airPlayBarButtonItem, castBarButtonItem]
        
        navigationController?.toolbar.barTintColor = .white
        navigationController?.toolbar.shadowColor = .clear
        navigationController?.toolbar.isTranslucent = false
        navigationController?.isToolbarHidden = false
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
    func didTapGoOnAddressBarView(_ addressBarView: AddressBarView) {
        guard let url = validateUrlString(addressBarView.text) else {
            return
        }
        
        loadUrl(url)
    }
    
    func didTapHomeOnAddressBarView(_ addressBarView: AddressBarView) {
        
    }
    
    func didTapStopOnAddressBarView(_ addressBarView: AddressBarView) {
        webView.stopLoading()
    }
    
    func didTapReloadOnAddressBarView(_ addressBarView: AddressBarView) {
        webView.reload()
    }
    
    func didTapBackOnAddressBarView(_ addressBarView: AddressBarView) {
        webView.goBack()
        addressBarView.canGoBack = webView.canGoBack
    }
}

extension MainViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        addressBar.isLoading = true
        addressBar.canGoBack = webView.canGoBack
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        addressBar.isLoading = false
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        log.error(error)
        addressBar.isLoading = false
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
    
    @objc private func didTapOnAirPlayButton() {
        let metadata = GCKMediaMetadata()
        metadata.setString(webView.title ?? "Untitled", forKey: kGCKMetadataKeyTitle)
        
        let url = URL.init(string: currentVideo ?? "")
        guard let mediaURL = url else {
            showAlert(title: "Error", message: "It seems like the video url is not correct.")
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
        miniMediaControlsItemEnabled = true
    }
}

extension MainViewController: Identifiable { }
