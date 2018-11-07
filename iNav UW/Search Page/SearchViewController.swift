//
//  SearchViewController.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/5/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak private var searchTextField: UITextField!
    @IBOutlet weak private var resultsTableView: UITableView!
    @IBOutlet private var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchTextField()
        setupTableView()
        addDarkBlurBackground(toView: contentView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupSearchTextField() {
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [
            NSAttributedStringKey.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        ])
    }
    
    private func setupTableView() {
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.layer.borderWidth = 1
        resultsTableView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor
        resultsTableView.layer.cornerRadius = 10
        resultsTableView.layer.masksToBounds = true
    }
    
    @IBAction func backButtonPressed(_ sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        searchTextField.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        cell.setMainTitle(to: "Cell \(indexPath.item)")
        cell.setSubtitle(to: "Smol Cell \(indexPath.item)")
        
        let index = indexPath.item % 3
        switch index {
            case 0: cell.setCircleColor(to: Constants.uwLightRed)
            case 1: cell.setCircleColor(to: Constants.uwOffWhite)
            case 2: cell.setCircleColor(to: Constants.uwDarkRed)
            default: cell.setCircleColor(to: .green)
        }
        
        return cell
    }
    
}
