//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found
// in the LICENSE.md file in the root directory of this source tree.
// 

import UIKit
import RealmSwift
import SDWebImage
import OneTimePassword
import AVFoundation

class MainPasswordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    /// Is programatically set to true if user tapped the search button
    var startSearching: Bool = false
    
    var isSearching: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomPadding: NSLayoutConstraint!
    
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    /// The text cell identifiers of passwords (so they can be reused, just like ViewHolders in Android)
    let textCellIdentifierTOTP = "TimeBasedPasswordCell"
    let textCellIdentifierHOTP = "CounterBasedPasswordCell"
    
    /// Empty TableView cached views
    var tableViewEmptyList: UIView? = nil
    var tableViewEmptySearch: UIView? = nil
    
    /// Keep track of Realm result set changes using this notification token
    /// More info can be found on realm.io (https://realm.io/docs/swift/latest/#collection-notifications)
    var notificationToken: NotificationToken? = nil
    
    /// The Realm result set
    var results: Results<Password>?

    /// Triggered when the view did load (before visible)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewEmptyList = loadXIBAsUIView("UIPasswordsEmptyListView")
        tableViewEmptySearch = loadXIBAsUIView("UIPasswordsEmptySearchView")
        
        initializeSearchBar()
        initializeTableView()
        
        let realm = try! Realm()
        results = realm.objects(Password.self).filter("deleted == 0").sorted(byKeyPath: "issuer", ascending: true)

        initializeTableViewNotifications()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc func appMovedToForeground() {
        self.updateTableCellStates()
    }
    
    /// Remove Realm notifications
    deinit {
        notificationToken?.invalidate()
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
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
    
    private func initializeSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search..."
        searchBar.returnKeyType = .done
        navigationItem.titleView = searchBar
    }

    private func initializeTableView() {
        tableView.register(UINib(nibName: textCellIdentifierTOTP, bundle: Bundle.main), forCellReuseIdentifier: textCellIdentifierTOTP)
        tableView.register(UINib(nibName: textCellIdentifierHOTP, bundle: Bundle.main), forCellReuseIdentifier: textCellIdentifierHOTP)
        tableView.backgroundView = tableViewEmptyList
        
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
            tableView.backgroundView = tableViewEmptySearch
            results = results?.filter(QueryHelper.passwordSearch(searchText))
        } else {
            tableView.backgroundView = tableViewEmptyList
        }
        
        initializeTableViewNotifications()
        
        tableView.reloadData()
        updateTableCellStates()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let resultCount = results?.count ?? 0
        
        tableView.backgroundView?.isHidden = resultCount != 0
        searchBar.isUserInteractionEnabled = resultCount != 0 || isSearching
        searchBar.alpha = !(resultCount != 0 || isSearching) ? CGFloat(0.5) : CGFloat(1.0)
        
        return resultCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let password = results![indexPath.row]
        var cell:PasswordCell?
        
        switch password.kind {
        case PasswordKindFormOption.OPTION_HOTP.value:
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
        
        let current = password.getToken().currentPassword!
        
        // Copy to clipboard, vibrate and show banner
        UIPasteboard.general.string = current
        BannerHelper.success(BannerHelper.boldText("Copied \(current) to your clipboard!"), seconds: 0.5)

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

        delete.image = UIImage(named: "action-delete")


        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            if let result = self.results?[indexPath.row] {
                self.performSegue(withIdentifier: "PasswordSelectedSegue", sender: result)
            }
        }

        edit.backgroundColor = UIColor.lightGray
        edit.image = UIImage(named: "action-edit")

        return [delete, edit]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
        
        if segue.identifier == "PasswordSelectedSegue" {
            guard let destination = segue.destination as? MainEditPasswordViewController else {
                return
            }
            
            guard let password = sender as? Password else {
                return
            }
            
            destination.password = password
        }
    }
    
}
