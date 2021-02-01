//
//  BaseViewController.swift
//  Quickerala
//
//  Created by Bibin on 24/05/19.
//  Copyright © 2019 Hifx IT & Media Services Private Limited. All rights reserved.
//

import UIKit

/// Base View controller for the entire project.
class BaseViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setting the navigation bar button items
        let navigationItem = (tabBarController?.navigationItem ?? self.navigationItem)
        navigationItem.setLeftBarButtonItems(leftBarButtons, animated: true)
        navigationItem.setRightBarButtonItems(rightBarButtons, animated: true)
        navigationItem.backBarButtonItem = .init(title: " ", style: .done, target: nil, action: nil)
//        navigationController?.navigationBar.barStyle = .black
    }
    
    deinit {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: BarButtonItemSettable Protocol Conformance
@objc extension BaseViewController: BarButtonItemSettable {
    var leftBarButtons: [UIBarButtonItem] { return [] }
    var rightBarButtons: [UIBarButtonItem] { return [] }
}

// MARK: Protocols
/// Protocol variables to retrieve the BarButtonItems in navigation bar.
@objc protocol BarButtonItemSettable {
    /// Collection of leftBarButtons in navigation bar.
    @objc optional var leftBarButtons: [UIBarButtonItem] { get }
    
    /// Collection of leftBarButtons in navigation bar.
    @objc optional var rightBarButtons: [UIBarButtonItem] { get }
}

protocol LoginPresentable {
    func presentLogin(_ completion:  @escaping (Authentication.Status) -> Void)
}

extension LoginPresentable where Self: UIViewController {
    func presentLogin(_ completion:  @escaping (Authentication.Status) -> Void) {
        executeInMainThread {
            
            guard !(UIViewController.top is LoginViewController) else { return }
            let loginView = LoginViewController.instantiate()
            let loginPresenter = LoginPresenter()
            loginPresenter.completion = completion
            loginView.presenter = loginPresenter
            self.present(UINavigationController(rootViewController: loginView), animated: true)
        }
    }
}

extension UIViewController: LoginPresentable {}
