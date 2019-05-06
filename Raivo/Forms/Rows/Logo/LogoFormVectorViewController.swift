//
//  LogoFormVectorViewController.swift
//  Raivo
//
//  Created by Tijme Gommers on 05/05/2019.
//  Copyright © 2019 Tijme Gommers. All rights reserved.
//

import Foundation
import UIKit
import Eureka

public class LogoFormVectorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifier = "LogoFormVectorCell"
    
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    var row: LogoFormRow?
    
    func set(logoFormRow: LogoFormRow) {
        self.row = logoFormRow
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: reuseIdentifier, bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.title = "Logo"
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        row.value = Bundle.main.url(forResource: "twitter", withExtension: "svg", subdirectory: "Issuers/vectors")
    }
    
    // tell the collection view how many cells to make
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! LogoFormVectorCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.label.text = self.items[indexPath.item]
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        log.error("You selected cell #\(indexPath.item)!")
    }
}
