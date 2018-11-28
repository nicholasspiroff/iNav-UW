//
//  SearchViewController.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/5/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate,
    UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var dismissKeyGesture: UITapGestureRecognizer!
    @IBOutlet weak private var searchTextField: UITextField!
    @IBOutlet weak private var resultsTableView: UITableView!
    @IBOutlet private var contentView: UIView!
    
    var filteredLocations = [iNavLocation]()
    var filteredStringRanges = [Range<String.Index>]()
    var isFiltering = false
    var parentVC: MainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        setupSearchTextField()
        setupTableView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupSearchTextField() {
        searchTextField.delegate = self
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [
            NSAttributedStringKey.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        ])
        searchTextField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    private func setupTableView() {
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.layer.borderWidth = 1
        resultsTableView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor
        resultsTableView.layer.cornerRadius = 2
        resultsTableView.layer.masksToBounds = true
        resultsTableView.allowsSelection = true
    }
    
    @IBAction func backButtonPressed(_ sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @objc
    private func textFieldDidChange() {
        if searchTextField.text == "" {
            isFiltering = false
            resultsTableView.reloadData()
        }
        else {
            isFiltering = true
            filterContent(searchText: searchTextField.text!)
        }
    }
    
    private func filterContent(searchText: String) {
        filteredStringRanges.removeAll()
        
        filteredLocations = Locations.list.filter({ (loc: iNavLocation) -> Bool in
            if let range = loc.name.lowercased().range(of: searchText.lowercased()) {
                filteredStringRanges.append(range)
                return true
            }
            
            return false
        })
        
        resultsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredLocations.count + 1
        }
        else {
            return Locations.list.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionLabel", for: indexPath) as! SectionTitleTableViewCell
            
            if isFiltering {
                cell.setTitle(to: "Results")
            }
            else {
                cell.setTitle(to: "Locations")
            }
            
            return cell
        }
        
        var location: iNavLocation!
        if isFiltering {
            location = filteredLocations[indexPath.item - 1]
        }
        else {
            location = Locations.list[indexPath.item - 1]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        cell.setMainTitle(to: location.name)
        
        if isFiltering {
            cell.filterTitle(withRange: filteredStringRanges[indexPath.item - 1])
        }
        
        if location.type == .room {
            cell.setSubtitle(to: "Room")
            cell.setIcon(to: #imageLiteral(resourceName: "room"))
        }
        else if location.type == .mensBathroom {
            cell.setSubtitle(to: "Men's Bathroom")
            cell.setIcon(to: #imageLiteral(resourceName: "mensBthrm"))
        }
        else if location.type == .womensBathroom {
            cell.setSubtitle(to: "Women's Bathroom")
            cell.setIcon(to: #imageLiteral(resourceName: "womenBthrm"))
        }
        
        let index = indexPath.item % 3
        switch index {
            case 0: cell.setCircleColor(to: Constants.uwLightRed)
            case 1: cell.setCircleColor(to: Constants.uwDarkRed)
            case 2: cell.setCircleColor(to: Constants.uwOffWhite)
            default: cell.setCircleColor(to: .green)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedLocation: iNavLocation!
        
        if isFiltering {
            selectedLocation = filteredLocations[indexPath.item - 1]
        }
        else {
            selectedLocation = Locations.list[indexPath.item - 1]
        }
        
        dismiss(animated: true, completion: {
            self.parentVC.map.followUser = true
            self.parentVC.wayfindForLocation(selectedLocation)
        })
    }
    
}
