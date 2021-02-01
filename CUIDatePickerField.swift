//
//  CUIDatePickerField.swift
//  General
//
//  Created by Bibin on 18/07/18.
//

import UIKit

open class CUIDatePickerField: UITextField, UITextFieldDelegate {
    
    var format: String = "MMMM-dd-yyy"
    
    var maximumDate: Date?{
        didSet{
            datepickerView.maximumDate    = maximumDate
        }
    }
    
    var minimumDate: Date?{
        didSet{
            datepickerView.minimumDate    = minimumDate
        }
    }
    
    var mode: UIDatePicker.Mode = .date{
        didSet{
            datepickerView.datePickerMode = mode
        }
    }
    
    var date: Date?{
        didSet{
            super.text = dateString
        }
    }
    
    var dateString: String?{
        
        guard date != nil else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.format
        return dateFormatter.string(from: date!)
    }
    
    
    @available(*, unavailable)
    override open var text: String?{
        set{
            super.text = newValue
        }
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
    
    
    fileprivate var datepickerView: UIDatePicker = UIDatePicker()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialisation()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialisation()
    }
    
    fileprivate func initialisation(){
        
        super.inputView = datepickerView
        super.inputAccessoryView = configureInputAccessoryView()
        
        datepickerView.datePickerMode = mode
        datepickerView.maximumDate    = maximumDate
        datepickerView.minimumDate    = minimumDate
        
        //datepickerView.backgroundColor = UIColor.white
        
        super.text = dateString
        
        super.delegate = self
        
    }
    
    fileprivate func configureInputAccessoryView() -> UIView{
        
        let screenSize: CGSize = UIScreen.main.bounds.size
        
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
        
        let cancelBarButton: UIBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                               style: UIBarButtonItem.Style.plain,
                                                               target: self,
                                                               action: #selector(cancelAction(_:)))
        
        let fexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneBarButton: UIBarButtonItem = UIBarButtonItem(title: "Done",
                                                             style: UIBarButtonItem.Style.done,
                                                             target: self,
                                                             action: #selector(doneAction(_:)))
        
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
    
    @objc fileprivate func cancelAction(_ sender: UIBarButtonItem){
        resignFirstResponder()
    }
    
    @objc fileprivate func doneAction(_ sender: UIBarButtonItem){
        resignFirstResponder()
        self.date = datepickerView.date
        self.sendActions(for: .valueChanged)
        
    }
    
    
    func date(from string: String) -> Date?{
        if string.trimmed.isEmpty{
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.format
        return dateFormatter.date(from: string)
    }
    
    
    //MARK:- UITEXTFIELD DELEGATE
    
//    @available(*, unavailable)
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        return true
    }
    
//    @available(*, unavailable)
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        
        guard date != nil else {
            return
        }
        
        datepickerView.date = date!
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
    
}
