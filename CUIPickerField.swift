//
//  CUIPickerField.swift
//  General
//
//  Created by Bibin on 18/07/18.
//

import UIKit

@objc public protocol UIPickerFieldDelegate: NSObjectProtocol {
    func numberOfOptionsInPickerField(_ pickerField: CUIPickerField) -> Int
    func pickerField(_ pickerField: CUIPickerField, titleForOptionInIndex index: Int) -> String?
    @objc optional func pickerField(_ pickerField: CUIPickerField, didSelectOptionAtIndex index: Int)
}


open class CUIPickerField: UITextField, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    open weak var pickerDelegate: UIPickerFieldDelegate?
    
    open var selectedOptionIndex: Int = -1{
        didSet{
            self.selectedRow = self.selectedOptionIndex
            if selectedOptionIndex >= 0 {
                super.text = pickerDelegate?.pickerField(self, titleForOptionInIndex: selectedOptionIndex)
            }
            else{
                super.text = nil
            }
            self.selectedText = super.text
        }
    }
    
    override open var text: String?{
        set{super.text = newValue}
        get{ return super.text }
    }
    
    @available(*, unavailable)
    override open var delegate: UITextFieldDelegate?{
        set{}
        get{ return super.delegate }
    }
    
    override open var inputAccessoryView: UIView?{
        set{}
        get{ return super.inputAccessoryView }
    }
    
    override open var inputView: UIView?{
        set{}
        get{ return super.inputView }
    }
    
    
    
    
    fileprivate var pickerView: UIPickerView = UIPickerView()
    fileprivate var selectedText: String?
    fileprivate var selectedRow: Int = -1
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialisation()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialisation()
    }
    
    fileprivate func initialisation(){
        
        super.inputView = pickerView
        super.inputAccessoryView = configureInputAccessoryView()
        
        if #available(iOS 13.0, *) {
            pickerView.backgroundColor = .tertiarySystemBackground
        } else {
            pickerView.backgroundColor = .white
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        super.delegate = self
        
    }
    
    fileprivate func configureInputAccessoryView() -> UIView{
        
        let screenSize: CGSize = UIScreen.main.bounds.size
        
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
        if #available(iOS 13.0, *) {
            toolbar.barTintColor = .systemBackground
        } else {
            toolbar.barTintColor = .white
        }
        toolbar.isTranslucent = true
        
        
        let cancelBarButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction(_:)))
        
        let fexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneBarButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
        
        toolbar.setItems([cancelBarButton, fexibleSpace, doneBarButton], animated: false)
        
        return toolbar
    }

    open override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)){
            return false
        }
        else if action == #selector(copy(_:)){
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }

    @objc func cancelAction(_ sender: UIBarButtonItem){
        resignFirstResponder()
    }
    
    @objc func doneAction(_ sender: UIBarButtonItem){
        resignFirstResponder()
        
        if self.selectedOptionIndex != self.selectedRow {
            super.text = selectedText
            self.selectedOptionIndex = selectedRow
            pickerDelegate?.pickerField?(self, didSelectOptionAtIndex: selectedOptionIndex)
        }
    }
    
    
    //MARK:- UITEXTFIELD DELEGATE
    
//    @available(*, unavailable)
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        return true
    }
    
//    @available(*, unavailable)
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.selectRow(selectedOptionIndex, inComponent: 0, animated: false)
    }
    
//    @available(*, unavailable)
    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool{
        return true
    }
    
//    @available(*, unavailable)
    open func textFieldDidEndEditing(_ textField: UITextField){}
    
//    @available(*, unavailable)
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        return false
    }
    
//    @available(*, unavailable)
    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return false
    }
    
//    @available(*, unavailable)
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        return false
    }
    
    
    //MARK:- UIPICKER VIEW DATA SOURCE
    
//    @available(*, unavailable)
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
//    @available(*, unavailable)
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if let _fieldDelegate = pickerDelegate{
            return _fieldDelegate.numberOfOptionsInPickerField(self)
        }
        
        return 0
    }
    

    //MARK:- UIPICKER VIEW DELEGATE
    
//    @available(*, unavailable)
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDelegate?.pickerField(self, titleForOptionInIndex: row)
    }
    
//    @available(*, unavailable)
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRow = row
    }

}
