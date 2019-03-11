//
//  TweetsTableViewController.swift
//  SearchTweetsMVC
//
//  Created by Shibili Areekara on 02/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import UIKit

class TweetsTableViewController: UITableViewController {
    
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    private var tweetViewModels = [[TweetViewModel]]()
    
    private var lastTwitterRequest: Request?
    
    var searchController: UISearchController!
    
    let tweetTVCellId = "TweetTableViewCell"
    
    var searchText: String? {
        didSet {
            
            searchController?.searchBar.text = searchText
            searchController?.searchBar.placeholder = (searchText ?? "").isEmpty ? "Search Tweets" : searchText
            
            if (searchText ?? "").isEmpty {
                self.clearTweets()
            } else {
                searchForTweets()
            }
            
        }
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialiseVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    // MARK: - Functionalities
    
    private func initialiseVC () {
        
        self.setUpTableView()
        
        self.setUpSortButton()
        
        self.setupSearchController()

    }
    
    private func setUpTableView() {
        self.registerCustomTableViewCells()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func setUpSortButton() {
        self.sortButton.target = self
        self.sortButton.action = #selector(sortAction)
    }
    
    private func setupSearchController() {
        
        searchText = "iOS developer"
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = searchText
        
        searchController.searchBar.tintColor = UIColor.white
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    private func registerCustomTableViewCells () {
        let tweetTableVCNib = UINib(nibName: tweetTVCellId, bundle: nil)
        self.tableView.register(tweetTableVCNib, forCellReuseIdentifier: tweetTVCellId)
    }
    
    private func twitterRequest(resultType: Request.SearchResultType = .recent) -> Request? {
        if let queryText = searchText, !queryText.isEmpty {
            return Request(search: queryText, count: 100, resultType: resultType)
        } else {
            self.clearTweets()
        }
        
        return nil
    }
    
    private func searchForTweets(resultType: Request.SearchResultType = .recent) {
        if let request = twitterRequest(resultType: resultType) {
            self.lastTwitterRequest = request
            
            request.fetchTweets({ [weak self] (newTweets) in
                DispatchQueue.main.async {
                    
                    self?.tweetViewModels.removeAll()
                    self?.tableView.reloadData()
                    
                    if request == self?.lastTwitterRequest {
                        
                        self?.tweetViewModels.insert(newTweets.map({ return TweetViewModel(tweet: $0)}), at: 0)
                        self?.tableView.insertSections([0], with: .fade)
                    }
                    
                    print("\n\t***Tweets Count:: \(self?.tweetViewModels.count ?? 0)")
                }
            })
        }
        
    }
    
    @objc func sortAction() {
        searchController.searchBar.resignFirstResponder()
        searchForTweets(resultType: .popular)
    }
    
    private func clearTweets () {
        tweetViewModels.removeAll()
        tableView.reloadData()
    }
}

// MARK: - Table View Data Source
extension TweetsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweetViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetViewModels[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureTweetTableViewCell(tableView, indexPath)
    }
    
    fileprivate func configureTweetTableViewCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tweetTVCellId, for: indexPath) as? TweetTableViewCell else { return UITableViewCell () }
        
        let tweetViewModel = tweetViewModels[indexPath.section][indexPath.row]
        
        cell.tweetViewModel = tweetViewModel
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension TweetsTableViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar == searchController.searchBar {
            searchBar.placeholder = searchText
            searchBar.text = searchText
            
            self.sortButton.isEnabled =  false
        }
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar == searchController.searchBar {
            searchText = searchBar.text
            searchController.isActive = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar == searchController.searchBar {
            self.searchText = searchText
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.sortButton.isEnabled =  true
        
        return true
    }
}
