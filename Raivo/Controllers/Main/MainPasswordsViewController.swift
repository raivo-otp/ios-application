//
// Raivo OTP
//
// Copyright (c) 2023 Mobime. All rights reserved.
//
// View the license that applies to the Raivo OTP source
// code and published services to learn how you can use
// Raivo OTP.
//
// https://raivo-otp.com/license/.

import UIKit
import RealmSwift
import SDWebImage
import OneTimePassword
import SwipeCellKit
import AVFoundation

class MainPasswordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate, UISearchBarDelegate {
    
    static var isAddedNew = false
    
    /// Is programatically set to true if user tapped the search button
    var startSearching: Bool = false
    var isSearching: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        setNeedsStatusBarAppearanceUpdate()
        
        tableViewEmptyList = loadXIBAsUIView("UIPasswordsEmptyListView")
        tableViewEmptySearch = loadXIBAsUIView("UIPasswordsEmptySearchView")
        
        initializeSearchBar()
        initializeTableView()
        
        autoreleasepool {
            if let realm = try? RealmHelper.shared.getRealm() {
                let sortProperties = [
                    SortDescriptor(keyPath: "pinned", ascending: false),
                    SortDescriptor(keyPath: "issuer"),
                    SortDescriptor(keyPath: "account")
                ]
                results = realm.objects(Password.self).filter("deleted == 0").sorted(by: sortProperties)
            }
        }

        initializeTableViewNotifications()
        
        NotificationHelper.shared.listen(to: UIApplication.willEnterForegroundNotification, distinctBy: id(self)) { _ in
            self.appMovedToForeground()
        }
    }
    
    @objc func appMovedToForeground() {
        self.updateTableCellStates()
    }
    
    /// Remove Realm notifications
    deinit {
        notificationToken?.invalidate()
        
        NotificationHelper.shared.discard(UIApplication.willEnterForegroundNotification, byDistinctName: id(MainPasswordsViewController.self))
    }
    
    private func initializeTableViewNotifications() {
        notificationToken?.invalidate()
        notificationToken = nil
        
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
                
                if !insertions.isEmpty || !modifications.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        self?.popupRating(isAddNew: Self.isAddedNew)
                    }
                }
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }

            self?.updateTableCellStates()
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
        attachKeyboardConstraint(self)
        updateTableCellStates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        detachKeyboardConstraint(self)
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy
    ///
    /// - Parameter animated: Positive if the transition was animated
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
            let refreshAlert = UIAlertController(title: "Your vault is empty!", message: "Do you want to add your first OTP?", preferredStyle: .alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.performSegue(withIdentifier: "MainScanQuickResponseCodeSegue", sender: nil)
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
        autoreleasepool {
            if let realm = try? RealmHelper.shared.getRealm(feedbackOnError: false) {
                let sortProperties = [
                    SortDescriptor(keyPath: "pinned", ascending: false),
                    SortDescriptor(keyPath: "issuer"),
                    SortDescriptor(keyPath: "account")
                ]
                
                results = realm.objects(Password.self).filter("deleted == 0").sorted(by: sortProperties)
            }
        }
        
        if (searchText.count > 0) {
            self.searchBar.showsCancelButton = true
            tableView.backgroundView = tableViewEmptySearch
            results = results?.filter(QueryHelper.shared.passwordSearch(searchText))
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
        
        cell?.delegate = self
        cell!.setPassword(password)
        cell!.updateState(force: true)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let password = self.results?[indexPath.row] else {
            return
        }
        
        // Prepare banner message
        let message = ReceiverHelper.shared.hasReceivers() ? "Copied to your clipboard and sending it to MacOS" : "Copied to your clipboard"
        
        // Copy to clipboard, vibrate and show banner
        UIPasteboard.general.string = password.getToken().currentPassword!
        BannerHelper.shared.done(TokenHelper.shared.formatPassword(password.getToken()), message, wrapper: view)
        
        // Also send to receivers if applicable
        ReceiverHelper.shared.sendPassword(password)
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .left {
            guard self.results?[indexPath.row].kind == PasswordKindFormOption.OPTION_HOTP.value else { return nil }
            
            let hotpAction = SwipeAction(style: .default, title: "Increase") { action, indexPath in
                autoreleasepool {
                    if let realm = try? RealmHelper.shared.getRealm() {
                        try? RealmHelper.shared.writeBlock(realm) {
                            self.results?[indexPath.row].counter += 1
                            self.results?[indexPath.row].syncing = SyncerHelper.shared.getSyncer().recordsRequireSync
                            self.results?[indexPath.row].synced = !SyncerHelper.shared.getSyncer().recordsRequireSync
                        }
                    }
                }
            }
            
            hotpAction.backgroundColor = UIColor.gray
            hotpAction.image = UIImage(named: "icon-hotp")?.sd_tintedImage(with: UIColor.white)

            return [hotpAction]
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let deleteAlert = UIAlertController(title: "Warning!", message: "Do you want to permanently delete this password?", preferredStyle: UIAlertController.Style.alert)
            
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                if let result = self.results?[indexPath.row] {
                    autoreleasepool {
                        if let realm = try? RealmHelper.shared.getRealm() {
                            try? RealmHelper.shared.writeBlock(realm) {
                                result.deleted = true
                                result.syncing = SyncerHelper.shared.getSyncer().recordsRequireSync
                                result.synced = !SyncerHelper.shared.getSyncer().recordsRequireSync
                            }
                        }
                    }
                }
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                deleteAlert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(deleteAlert, animated: true, completion: nil)
        }

        deleteAction.backgroundColor = UIColor.getTintRed()
        deleteAction.image = UIImage(named: "icon-trash")?.sd_tintedImage(with: UIColor.white)
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            if let result = self.results?[indexPath.row] {
                self.performSegue(withIdentifier: "MainOneTimePasswordSelectedSegue", sender: result)
            }
        }
        
        editAction.backgroundColor = UIColor.darkGray
        editAction.image = UIImage(named: "icon-edit")?.sd_tintedImage(with: UIColor.white)
        
        let qrcodeAction = SwipeAction(style: .default, title: "QR code") { action, indexPath in
            if let result = self.results?[indexPath.row] {
                self.performSegue(withIdentifier: "MainQuickResponseCodeSelectedSegue", sender: result)
            }
        }
        
        qrcodeAction.backgroundColor = UIColor.gray
        qrcodeAction.image = UIImage(named: "icon-qrcode")?.sd_tintedImage(with: UIColor.white)
        
        let pinActionTitle = self.results?[indexPath.row].pinned ?? false ? "Unpin" : "Pin"
        let pinAction = SwipeAction(style: .default, title: pinActionTitle) { action, indexPath in
            if let result = self.results?[indexPath.row] {
                autoreleasepool {
                    if let realm = try? RealmHelper.shared.getRealm() {
                        try? RealmHelper.shared.writeBlock(realm) {
                            result.pinned = !result.pinned
                            result.syncing = SyncerHelper.shared.getSyncer().recordsRequireSync
                            result.synced = !SyncerHelper.shared.getSyncer().recordsRequireSync
                        }
                    }
                }
            }
        }
        
        pinAction.backgroundColor = UIColor.lightGray
        pinAction.image = UIImage(named: "icon-pin")?.sd_tintedImage(with: UIColor.white)
        
        return [deleteAction, editAction, qrcodeAction, pinAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border
        return options
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
        
        if segue.identifier == "MainOneTimePasswordSelectedSegue" {
            guard let destination = segue.destination as? MainEditPasswordViewController else {
                return
            }
            
            guard let password = sender as? Password else {
                return
            }
            
            destination.password = password
        }
        
        if segue.identifier == "MainQuickResponseCodeSelectedSegue" {
            guard let destination = segue.destination as? MainQuickResponseCodeViewController else {
                return
            }
            
            guard let password = sender as? Password else {
                return
            }
            
            destination.password = password
        }
    }
    
    func popupRating(isAddNew: Bool) {
        let isRated = UserDefaults.standard.bool(forKey: "com.mobime.raivo.rating")
        //let OTP_Added = UserDefaults.standard.bool(forKey: "OTP_Added")
        
        //if already rated?
        if (isRated) {
            return
        }

        if (isAddNew) {
            popupRatingWhenAdd()
        } else {
            popupRatingForImport()
        }

        Self.isAddedNew = false
    }
    
    func popupRatingForImport() {
        let alert = UIAlertController(title: "Hooray", message: "You've successfully recovered your keys with Raivo 🚀🚀🚀\n\nWe're thrilled that you had a smooth experience. If you're as excited as we are, we'd love to hear your thoughts.", preferredStyle: UIAlertController.Style.alert)
        
        let laterAction = UIAlertAction(title: "later", style: UIAlertAction.Style.default, handler: nil)
        laterAction.setValue(UIColor.lightGray, forKey: "titleTextColor")
        
        let yesAction = UIAlertAction(title: "Yes, Sure ❤️", style: UIAlertAction.Style.default, handler: { action in
            UserDefaults.standard.setValue(true, forKey: "com.mobime.raivo.rating")
            UIApplication.shared.open(URL(string: "https://apps.apple.com/app/id1459042137?action=write-review")!, options: [:], completionHandler: nil)
        })
        
        yesAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(laterAction)
        alert.addAction(yesAction)
        
        alert.preferredAction = yesAction
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func popupRatingWhenAdd() {
        let alert = UIAlertController(title: "Congratulations", message: "It looks like you're enjoying Raivo Authenticator! If you have a moment, we'd love to hear from you", preferredStyle: UIAlertController.Style.alert)
        
        let laterAction = UIAlertAction(title: "Later", style: UIAlertAction.Style.default, handler: nil)
        laterAction.setValue(UIColor.lightGray, forKey: "titleTextColor")
        
        let yesAction = UIAlertAction(title: "Yes, Sure", style: UIAlertAction.Style.default, handler: { action in
            UserDefaults.standard.setValue(true, forKey: "com.mobime.raivo.rating")
            UIApplication.shared.open(URL(string: "https://apps.apple.com/app/id1459042137?action=write-review")!, options: [:], completionHandler: nil)
        })
        
        yesAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(laterAction)
        alert.addAction(yesAction)
        
        alert.preferredAction = yesAction
        
        self.present(alert, animated: true, completion: nil)
    }
}
