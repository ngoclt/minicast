//
//  AddressBarView.swift
//  MiniCast
//
//  Created by Ngoc Le on 11/06/2019.
//  Copyright © 2019 Coder Life. All rights reserved.
//

import UIKit
import Material
import GoogleCast

protocol AddressBarViewDelegate: class {
    func didTapGoOnAddressBarView(_ addressBarView: AddressBarView)
    func didTapHomeOnAddressBarView(_ addressBarView: AddressBarView)
    func didTapStopOnAddressBarView(_ addressBarView: AddressBarView)
    func didTapReloadOnAddressBarView(_ addressBarView: AddressBarView)
    func didTapBackOnAddressBarView(_ addressBarView: AddressBarView)
}

class AddressBarView: UIView {
    
    private let kContentXibName = "AddressBarView"
    
    public weak var delegate: AddressBarViewDelegate?
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var urlField: TextField!
    @IBOutlet private var homeButton: UIButton!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var actionButton: UIButton!
    
    public var isLoading: Bool = false {
        didSet {
            actionButton.setImage(isLoading ? #imageLiteral(resourceName: "CloseIcon") : #imageLiteral(resourceName: "ReloadIcon"), for: .normal)
        }
    }
    
    public var canGoBack: Bool = false {
        didSet {
            backButton.isEnabled = canGoBack
        }
    }
    
    public var text: String? {
        didSet {
            urlField.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(kContentXibName, owner: self, options: nil)
        
        contentView.frame = bounds
        
        translatesAutoresizingMaskIntoConstraints = false;
        addSubview(contentView);
        
        contentView.pinEdges(to: self)
    }
    
    @IBAction private func didTapOnBackButton(_ sender: Any) {
        urlField.resignFirstResponder()
        delegate?.didTapBackOnAddressBarView(self)
    }
    
    @IBAction private func didTapOnHomeButton(_ sender: Any) {
        urlField.resignFirstResponder()
        delegate?.didTapHomeOnAddressBarView(self)
    }
    
    @IBAction private func didTapOnActionButton(_ sender: Any) {
        urlField.resignFirstResponder()
        delegate?.didTapGoOnAddressBarView(self)
    }
    
    public func cancel() {
        urlField.text = text
        urlField.resignFirstResponder()
    }
}

extension AddressBarView: TextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.didTapHomeOnAddressBarView(self)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if urlField.text?.isEmpty ?? false {
            urlField.text = text
        }
    }
}
