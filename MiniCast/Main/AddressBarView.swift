//
//  AddressBarView.swift
//  MiniCast
//
//  Created by Ngoc Le on 11/06/2019.
//  Copyright © 2019 Coder Life. All rights reserved.
//

import UIKit
import Material

protocol AddressBarViewDelegate: class {
    func addressBarView(_ addressBarView: AddressBarView, goTo url: String?)
}

class AddressBarView: UIView {
    
    private let kContentXibName = "AddressBarView"
    
    public weak var delegate: AddressBarViewDelegate?
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var urlField: TextField!
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var castButton: UIButton!
    
    
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
        
        actionButton.setImage(Icon.cm.play, for: .normal)
        castButton.setImage(Icon.cm.movie, for: .normal)
    }
    
    private func goToUrl() {
        text = urlField.text
        
        delegate?.addressBarView(self, goTo: text)
        
        urlField.resignFirstResponder()
    }
    
    
    @IBAction private func didTapOnActionButton(_ sender: Any) {
        goToUrl()
    }
    
    public func cancel() {
        urlField.text = text
        urlField.resignFirstResponder()
    }
}

extension AddressBarView: TextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goToUrl()
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
