//
//  PasswordsViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 06/03/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage
import OneTimePassword
import AVFoundation
import Haptica

class PasswordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    /// Is programatically set to true if user tapped the search button
    var startSearching: Bool = false
    
    var isSearching: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    /// The text cell identifiers of passwords (so they can be reused, just like ViewHolders in Android)
    let textCellIdentifierTOTP = "TimeBasedPasswordCell"
    let textCellIdentifierHOTP = "CounterBasedPasswordCell"
    
    /// Keep track of Realm result set changes using this notification token
    /// More info can be found on realm.io (https://realm.io/docs/swift/latest/#collection-notifications)
    var notificationToken: NotificationToken? = nil
    
    /// The Realm result set
    var results: Results<Password>?

    /// Triggered when the view did load (before visible)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeSearchBar()
        initializeTableView()
        
        adjustConstraintToKeyboard()
        
        let realm = try! Realm()
        results = realm.objects(Password.self).filter("deleted == 0").sorted(byKeyPath: "issuer", ascending: true)

        initializeTableViewNotifications()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appMovedToForeground() {
        self.updateTableCellStates()
    }
    
    /// Remove Realm notifications
    deinit {
        notificationToken?.invalidate()
    }
    
    private func initializeTableViewNotifications() {
        notificationToken?.invalidate()
        
        notificationToken = results?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .none)
                tableView.endUpdates()
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }

            self!.updateTableCellStates()
        }
    }
    
    override func getConstraintToAdjustToKeyboard() -> NSLayoutConstraint? {
        return bottomPadding
    }
    
    private func initializeSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search..."
        searchBar.returnKeyType = .done
        navigationItem.titleView = searchBar
    }

    private func initializeTableView() {
        tableView.register(UINib(nibName: textCellIdentifierTOTP, bundle: Bundle.main), forCellReuseIdentifier: textCellIdentifierTOTP)
        tableView.register(UINib(nibName: textCellIdentifierHOTP, bundle: Bundle.main), forCellReuseIdentifier: textCellIdentifierHOTP)
        tableView.backgroundView = loadXIBAsUIView("PasswordsViewEmptyList")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTableCellStates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if startSearching && !isSearching {
            showSearchBar()
        }
    }
    
    private func updateTableCellStates() {
        for cell in tableView.visibleCells {
            (cell as! PasswordCell).updateState(force: true)
        }
    }
    
    func showSearchBar() {
        if results?.count == 0 && !isSearching {
            let refreshAlert = UIAlertController(title: "Youre vault is empty!", message: "Do you want to add your first OTP?", preferredStyle: .alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.performSegue(withIdentifier: "ScanPassword", sender: nil)
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                refreshAlert.dismiss(animated: true, completion: nil)
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        } else {
            self.searchBar.becomeFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar(self.searchBar, textDidChange: "")
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        
        isSearching = false
        startSearching = false
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.isSearching = true
        self.searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let realm = try! Realm()
        results = realm.objects(Password.self).filter("deleted == 0").sorted(byKeyPath: "issuer", ascending: true)
        
        if (searchText.count > 0) {
            self.searchBar.showsCancelButton = true
            tableView.backgroundView = loadXIBAsUIView("PasswordsViewEmptySearch")
            results = results?.filter(QueryHelper.passwordSearch(searchText))
        } else {
            tableView.backgroundView = loadXIBAsUIView("PasswordsViewEmptyList")
        }
        
        initializeTableViewNotifications()
        
        tableView.reloadData()
        updateTableCellStates()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let resultCount = results?.count ?? 0
        
        tableView.backgroundView?.isHidden = resultCount != 0
        
        return resultCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let password = results![indexPath.row]
        var cell:PasswordCell?
        
        switch password.kind {
        case Password.Kinds.HOTP:
            cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifierHOTP, for: indexPath as IndexPath) as! CounterBasedPasswordCell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifierTOTP, for: indexPath as IndexPath) as! TimeBasedPasswordCell
        }
        
        cell!.setPassword(password)
        cell!.updateState(force: true)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let password = self.results?[indexPath.row] else {
            return
        }
        
        let token = password.getToken()
        let formatted = TokenHelper.formatPassword(token)
        
        // Copy to clipboard, vibrate and show banner
        UIPasteboard.general.string = password.getToken().currentPassword
        Haptic.notification(.success).generate()
        BannerHelper.show(BannerHelper.attributedText("Copied OTP \"\(formatted)\" to the clipboard!", formatted))

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let deleteAlert = UIAlertController(title: "Warning!", message: "Do you want to delete this password?", preferredStyle: UIAlertController.Style.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                if let result = self.results?[indexPath.row] {
                    let realm = try! Realm()
                    try! realm.write {
                        result.deleted = true
                        result.syncing = true
                        result.synced = false
                    }
                }
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                deleteAlert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(deleteAlert, animated: true, completion: nil)
        }
        
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            if let result = self.results?[indexPath.row] {
                self.performSegue(withIdentifier: "PasswordSelectedSegue", sender: result)
            }
        }
        
        edit.backgroundColor = UIColor.lightGray
        
        return [delete, edit]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
        
        if segue.identifier == "PasswordSelectedSegue" {
            guard let destination = segue.destination as? EditPasswordViewController else {
                return
            }
            
            guard let password = sender as? Password else {
                return
            }
            
            destination.password = password
        }
    }
    
}
