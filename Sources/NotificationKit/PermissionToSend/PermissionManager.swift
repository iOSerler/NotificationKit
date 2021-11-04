//
//  NotificationManager.swift
//  iOSerler
//
//  Copyright © 2021 Nursultan Askarbekuly. All rights reserved.
//

import UIKit

enum PermissionAlertType: String {
    /// permissionAlertType
    case intrusive = "Intrusive"
    case nonintrusive = "Nonintrusive"
    case screen = "Screen"
    case system = "System"
}

public class PermissionManager: NSObject {
    
    /// publicly passed dependencies
    public weak var hostController: UIViewController?
    
    /// dependencies injected at the initializations
    private let notificationConfig: PermissionConfiguration
    private let analytics: GenericAnalytics?
    
    /// internal dependencies
    private var scheduleLocalNotifications: (() -> Void)?
    
    /// Analytics titles for user properties and event logs
    private let buttonPressedEventLog = "NotificationManager Button Pressed"
    private let alertShownEventLog = "Allow Notifications Alert Shown"
    private let permissionAlertTypePropertyTitle = "PermissionAlertType"
    
    init(notificationConfig: PermissionConfiguration, analytics: GenericAnalytics?) {
        self.notificationConfig = notificationConfig
        self.analytics = analytics
        
        super.init()
    }
    
    func configureNotifications() {
        
        let center  = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in

            let status = settings.authorizationStatus
            
            /// log user property
            let statusIndex = settings.authorizationStatus.rawValue
            let statusArray = ["not determined", "denied", "allowed", "provisional", "ephemeral"]
            self.analytics?.setUserProperty("Notification Status", value: statusArray[statusIndex])
            
            if status == .authorized {
                self.scheduleLocalNotifications?()
            }
            
            if status == .notDetermined
                && self.notificationConfig.appOpenCount % 2 == 0  {
                self.askPermission(alertType: self.notificationConfig.permissionAlertType)
            }
            
        }
        
    }
    
    func askPermission(alertType: PermissionAlertType) {
                
        analytics?.setUserProperty(permissionAlertTypePropertyTitle, value: alertType.rawValue)
        
        analytics?.logEvent(alertShownEventLog, properties: [
            permissionAlertTypePropertyTitle: alertType.rawValue
        ])
        
        
        DispatchQueue.main.async {
            switch alertType {
            case .intrusive:
                self.showIntrusivePermissionAlert()
            case .nonintrusive:
                self.setupNonintrusiveAlertView()
                self.showNonintrusivePermissionAlert()
            case .screen:
                self.setupAlertViewController()
                self.presentPermissionAlertController()
            case .system:
                self.showSystemPermissionAlert()
            default:
                print(#file, #function, "received RemoteConfigValue other than what was expected:", alertType.rawValue)
                return
            }
        }
    }
    
    func showSystemPermissionAlert() {
        
        let requestingPermissionEventTitle = "Requesting Permission for Notifications"
        
        let center  = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.analytics?.logEvent(requestingPermissionEventTitle, properties: [
                    "result": "successful"
                ])
                
                self.analytics?.logEvent("NotificationPermissionGiven", properties: nil)
                self.analytics?.setUserProperty("Notification Status", value: "allowed")
                
                self.scheduleLocalNotifications?()
                
            } else if let error = error {
                print(error.localizedDescription)
                self.analytics?.logEvent(requestingPermissionEventTitle, properties: [
                    "result": "denied"
                ])
            }
        }
    }
    
    func showIntrusivePermissionAlert() {
        let alert = UIAlertController(title: notificationConfig.enableLabelText,
                                      message: "",
                                      preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: notificationConfig.enableButtonTitle, style: .default) { (action) in
            self.yesAlertButtonPressed()
        }
        
        let dismissAction = UIAlertAction(title: notificationConfig.dismissButtonTitle, style: .default) { (action) in
            self.dismissAlertButtonPressed()
        }
        
        alert.addAction(dismissAction)
        alert.addAction(yesAction)
        
        DispatchQueue.main.async {
            self.hostController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func showNonintrusivePermissionAlert() {
        
        guard let navigationView = self.hostController?.navigationController?.view,
              let _ = self.alertViewTopConstraint else {
            return
        }
        
        navigationView.layoutIfNeeded()
        
        if #available(iOS 11.0, *) {
            self.alertViewTopConstraint.constant = navigationView.safeAreaInsets.top + 5
        } else {
            self.alertViewTopConstraint.constant = 10
        }
                
        UIView.animate(withDuration: 1.0) {
                
            navigationView.layoutIfNeeded()
        }
    }
    
    @objc func yesAlertButtonPressed() {
        print("yesAlertButtonPressed")
        analytics?.logEvent(buttonPressedEventLog, properties: [
            "button": notificationConfig.enableButtonTitle,
        ])
        showSystemPermissionAlert()
        dismissAlert()
    }
    
    @objc func dismissAlertButtonPressed() {
        print("dismissAlertButtonPressed")
        analytics?.logEvent(buttonPressedEventLog, properties: [
            "button": notificationConfig.dismissButtonTitle,
        ])
        dismissAlert()
        
    }
    
    func dismissAlert() {
        
        alertViewController.dismiss(animated: true, completion: nil)
        
        guard let view = self.hostController?.view,
              let navigationView = self.hostController?.navigationController?.view,
              let _ = alertViewTopConstraint else {
            return
        }
        
        if #available(iOS 11.0, *) {
            self.alertViewTopConstraint.constant = -alertViewHeight - view.safeAreaInsets.top
        } else {
            self.alertViewTopConstraint.constant = -alertViewHeight
        }
        
        UIView.animate(withDuration: 0.7) {
            navigationView.layoutIfNeeded()
        }
    }

    var alertViewTopConstraint: NSLayoutConstraint!
    
    lazy var alertView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.backgroundColor = notificationConfig.alertViewBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var alertViewHeight: CGFloat { 116 } /// should not be less than 116
    
    func setupNonintrusiveAlertView() {
        
        guard let view = self.hostController?.view,
              let navigationView = self.hostController?.navigationController?.view else {
            return
        }
        
        alertView.removeFromSuperview()
        alertView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        let alertTextLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 3
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = notificationConfig.labelColor
            label.textAlignment = .center
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlertButtonPressed)))
            return label
        }()
        let yesAlertButton: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(notificationConfig.labelColor, for: .normal)
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 3
            button.layer.borderColor = UIColor.lightGray.cgColor
            return button
        }()
        let dismissAlertButton: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(notificationConfig.labelColor, for: .normal)
            button.isUserInteractionEnabled = true
            button.isEnabled = true
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 3
            button.layer.borderColor = UIColor.lightGray.cgColor
            return button
        }()
        
        
        navigationView.addSubview(alertView)
        alertView.addSubview(alertTextLabel)
        alertView.addSubview(yesAlertButton)
        alertView.addSubview(dismissAlertButton)
        
        yesAlertButton.addTarget(self, action: #selector(yesAlertButtonPressed), for: .touchUpInside)
        dismissAlertButton.addTarget(self, action: #selector(dismissAlertButtonPressed), for: .touchUpInside)

        alertView.heightAnchor.constraint(equalToConstant: alertViewHeight).isActive = true
        alertView.centerXAnchor.constraint(equalTo: navigationView.centerXAnchor).isActive = true
        alertView.widthAnchor.constraint(equalToConstant: navigationView.bounds.width - 32).isActive = true
        
        alertViewTopConstraint = alertView.topAnchor.constraint(equalTo: navigationView.topAnchor)
        alertViewTopConstraint?.isActive = true
        if #available(iOS 11.0, *) {
            self.alertViewTopConstraint.constant = -view.safeAreaInsets.top - alertViewHeight
        } else {
            self.alertViewTopConstraint.constant = -alertViewHeight
        }
        
        alertTextLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        alertTextLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
        alertTextLabel.widthAnchor.constraint(equalTo: alertView.widthAnchor, constant: -32).isActive = true
        alertTextLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 16).isActive = true

        yesAlertButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        yesAlertButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -16).isActive = true
        yesAlertButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        yesAlertButton.leftAnchor.constraint(equalTo: alertView.leftAnchor, constant: 16).isActive = true
        
        dismissAlertButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        dismissAlertButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -16).isActive = true
        dismissAlertButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dismissAlertButton.rightAnchor.constraint(equalTo: alertView.rightAnchor, constant: -16).isActive = true
        
        alertTextLabel.text = notificationConfig.enableLabelText
        yesAlertButton.setTitle(notificationConfig.enableButtonTitle, for: .normal)
        dismissAlertButton.setTitle(notificationConfig.dismissButtonTitle, for: .normal)
    }
    
    func presentPermissionAlertController() {
        self.hostController?.present(alertViewController, animated: true, completion: nil)
    }

    
    lazy var alertViewController: UIViewController = {
        let vc = UIViewController()
        vc.view.layer.cornerRadius = 5
        vc.view.layer.borderWidth = 1
        vc.view.layer.borderColor = UIColor.lightGray.cgColor
        vc.view.backgroundColor = notificationConfig.alertViewBackgroundColor
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    func setupAlertViewController() {
        
        alertViewController.view.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        let alertImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "notification")
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        let alertTextLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 21, weight: .regular)
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlertButtonPressed)))
            return label
        }()
        let yesAlertButton: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = .systemBlue
            button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
            button.setTitleColor(.white, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.cornerRadius = 5
            return button
        }()
        
        let dismissAlertButton: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitleColor(notificationConfig.labelColor, for: .normal)
            button.isUserInteractionEnabled = true
            button.isEnabled = true
            return button
        }()
        
        alertViewController.view.addSubview(alertImageView)
        alertViewController.view.addSubview(alertTextLabel)
        alertViewController.view.addSubview(yesAlertButton)
        alertViewController.view.addSubview(dismissAlertButton)
                
        yesAlertButton.addTarget(self, action: #selector(yesAlertButtonPressed), for: .touchUpInside)
        dismissAlertButton.addTarget(self, action: #selector(dismissAlertButtonPressed), for: .touchUpInside)
        
        alertViewController.view.heightAnchor.constraint(equalToConstant: alertViewHeight).isActive = true
        
        alertImageView.heightAnchor.constraint(equalTo: alertViewController.view.heightAnchor, multiplier: 0.3).isActive = true
        alertImageView.widthAnchor.constraint(equalTo: alertViewController.view.widthAnchor, multiplier: 0.7).isActive = true
        alertImageView.centerXAnchor.constraint(equalTo: alertViewController.view.centerXAnchor).isActive = true
        alertImageView.bottomAnchor.constraint(equalTo: alertViewController.view.centerYAnchor, constant: 0).isActive = true
        
        alertTextLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
        alertTextLabel.centerXAnchor.constraint(equalTo: alertViewController.view.centerXAnchor).isActive = true
        alertTextLabel.widthAnchor.constraint(equalTo: alertViewController.view.widthAnchor, multiplier: 0.7).isActive = true
        alertTextLabel.topAnchor.constraint(equalTo: alertViewController.view.centerYAnchor, constant: 0).isActive = true
        
        yesAlertButton.topAnchor.constraint(greaterThanOrEqualTo: alertTextLabel.bottomAnchor, constant: 16).isActive = true
        
        yesAlertButton.centerXAnchor.constraint(equalTo: alertViewController.view.centerXAnchor).isActive = true
        yesAlertButton.bottomAnchor.constraint(equalTo: dismissAlertButton.topAnchor, constant: -12).isActive = true
        yesAlertButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        yesAlertButton.widthAnchor.constraint(equalTo: alertViewController.view.widthAnchor, multiplier: 0.7).isActive = true
   
        dismissAlertButton.centerXAnchor.constraint(equalTo: alertViewController.view.centerXAnchor).isActive = true
        dismissAlertButton.bottomAnchor.constraint(equalTo: alertViewController.view.bottomAnchor, constant: -80).isActive = true
        dismissAlertButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        dismissAlertButton.widthAnchor.constraint(equalTo: alertViewController.view.widthAnchor, multiplier: 0.7).isActive = true
        
        alertTextLabel.text = notificationConfig.enableLabelText
        yesAlertButton.setTitle(notificationConfig.enableButtonTitle, for: .normal)
        dismissAlertButton.setTitle(notificationConfig.dismissButtonTitle, for: .normal)
    }
}
