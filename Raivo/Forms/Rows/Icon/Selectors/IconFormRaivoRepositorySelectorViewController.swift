//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// Modification, duplication or distribution of this software (in 
// source and binary forms) for any purpose is strictly prohibited.
//
// https://github.com/tijme/raivo/blob/master/LICENSE.md
// 

import Foundation
import UIKit
import Eureka
import Alamofire

public class IconFormRaivoRepositorySelectorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    var refreshButton: UIBarButtonItem? = nil
    
    let reuseIdentifierIcon = "IconFormCell"
    
    let reuseIdentifierFooter = "IconFormSelectorViewFooter"
    
    let reuseIdentifierFooterHidden = "IconFormSelectorViewFooterHidden"
    
    var isSearching: Bool = false
    
    var isRefreshing: Bool = false
    
    var senderRow: IconFormRow?
    
    var dismissCallback: (() -> Void)?
    
    var lastSearchText: String = ""
    
    var allResults: Dictionary<String, Array<String>>? = nil
    
    var searchResults: [String] = []
    
    /// Empty TableView cached views
    var collectionViewEmptyList: UIView? = nil
    var collectionViewEmptySearch: UIView? = nil
    var collectionViewEmptyError: UIView? = nil
  
    func set(iconFormRow: IconFormRow) {
        self.senderRow = iconFormRow
    }
    
    func set(dismissCallback: @escaping () -> Void) {
        self.dismissCallback = dismissCallback
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initializeCollectionView()
        initializeRefreshButton()
        initializeSearchBar()
        
        refresh()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: If positive, the view is being added to the window using an animation
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = false
        attachKeyboardConstraint(self)
    }

    /// Notifies the view controller that its view is about to be removed from a view hierarchy.
    ///
    /// - Parameter animated: If positive, the disappearance of the view is being animated.
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        detachKeyboardConstraint(self)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if searchResults.count > 0 {
            searchBar.becomeFirstResponder()
        }
    }
    
    private func initializeCollectionView() {
        collectionViewEmptyList = loadXIBAsUIView("IconFormSelectorViewEmptyList")
        collectionViewEmptySearch = loadXIBAsUIView("IconFormSelectorViewEmptySearch")
        collectionViewEmptyError = loadXIBAsUIView("IconFormSelectorViewEmptyError")
        collectionView.backgroundView = collectionViewEmptyList
        
        collectionView.register(
            UINib(nibName: reuseIdentifierIcon, bundle: Bundle.main),
            forCellWithReuseIdentifier: reuseIdentifierIcon
        )
        
        collectionView.register(
            UINib(nibName: reuseIdentifierFooter, bundle: Bundle.main),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: reuseIdentifierFooter
        )
        
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: reuseIdentifierFooterHidden
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func initializeSearchBar() {
        searchBar.placeholder = "Search..."
        searchBar.returnKeyType = .search
        navigationItem.titleView = searchBar
        navigationItem.title = "Icons"
        
        searchBar.delegate = self
    }
    
    private func initializeRefreshButton() {
        refreshButton = UIBarButtonItem(
            image: UIImage(named: "icon-refresh"),
            style: .plain,
            target: self,
            action: #selector(refreshTapped)
        )
        
        refreshButton?.isEnabled = !isRefreshing
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    @objc func refreshTapped() {
        self.refresh(withoutCache: true)
    }
    
    private func isRefreshing(_ isRefreshing: Bool) {
        self.isRefreshing = isRefreshing
        
        self.refreshButton?.isEnabled = !isRefreshing
    }
    
    private func getRequestManager(_ withoutCache: Bool) -> SessionManager {
        if withoutCache {
            return AlamofireHelper.cacheless
        } else {
            return AlamofireHelper.default
        }
    }
    
    private func refresh(withoutCache: Bool = false) {
        self.isRefreshing(true)
        
        getRequestManager(withoutCache).request(AppHelper.iconsURL + "search.json").responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? Dictionary<String, Array<String>> {
                    self.allResults = json
                    self.searchResults(self.lastSearchText)
                    self.isRefreshing(false)
                }
            case .failure(let error):
                BannerHelper.shared.error("Error", error.localizedDescription, wrapper: self.view)
                
                self.collectionView.backgroundView = self.collectionViewEmptyError
                self.collectionView.backgroundView?.isHidden = self.searchResults.count != 0
                
                self.isRefreshing(false)
                
                log.warning(error)
            }
        }
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        refresh()
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let identifier = searchResults.count == 0 ? reuseIdentifierFooterHidden : reuseIdentifierFooter
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
        default:
            return UICollectionReusableView()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.backgroundView?.isHidden = self.searchResults.count != 0
        return self.searchResults.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierIcon, for: indexPath as IndexPath) as! IconFormCell
        
        cell.imageView.sd_setImage(
            with: URL(string: AppHelper.iconsURL + self.searchResults[indexPath.item]),
            placeholderImage: UIImage(named: "vector-empty-item"),
            context: [.imageTransformer: ImageFilterHelper.shared.getCurrentTransformerPipeline(self)]
        )
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        senderRow?.iconType = PasswordIconTypeFormOption.OPTION_RAIVO_REPOSITORY.value
        senderRow?.iconValue = self.searchResults[indexPath.item]
        
        navigationController?.popViewController(animated: true)
        self.dismissCallback!()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearching = false
        self.lastSearchText = ""
        self.searchBar(self.searchBar, textDidChange: "")
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        
        searchBar.resignFirstResponder()
    }
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchBar.showsCancelButton = true
        self.isSearching = true
        return true
    }
    
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.lastSearchText = searchText
        self.searchResults(searchText)
    }
    
    private func searchResults(_ userQuery: String = "") {
        collectionView.backgroundView = userQuery.count > 0 ? collectionViewEmptySearch : collectionViewEmptyList
        
        searchResults.removeAll()
        
        guard let allResults = self.allResults else {
            log.verbose("No icons available to search in.")
            return collectionView.reloadData()
        }
        
        guard userQuery.count > 0 else {
            for (_, icons) in allResults {
                searchResults += icons
            }
            
            searchResults = self.sortAndMakeUnique(searchResults)
            return collectionView.reloadData()
        }
        
        let userTerms = userQuery.components(separatedBy: " ")
        
        for (term, icons) in allResults {
            if termMatchesUserTerm(term, userTerms) {
                searchResults += icons
            }
        }
        
        searchResults = self.sortAndMakeUnique(searchResults)
        collectionView.reloadData()
    }
    
    private func termMatchesUserTerm(_ iconTerm: String, _ userTerms: [String]) -> Bool {
        for userTerm in userTerms {
            if userTerm.lowercased().contains(iconTerm.lowercased()) {
                return true
            }
            
            if iconTerm.lowercased().contains(userTerm.lowercased()) {
                return true
            }
        }
        
        return false
    }
    
    private func sortAndMakeUnique(_ searchResults: [String]) -> [String] {
        let unique = Array(Set(searchResults))
        return unique.sorted()
    }

}
