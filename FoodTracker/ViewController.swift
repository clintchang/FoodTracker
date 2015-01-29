//
//  ViewController.swift
//  FoodTracker
//
//  Created by Clint on 1/28/15.
//  Copyright (c) 2015 Republic. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    
    @IBOutlet weak var tableView: UITableView!
    
    //going to add a searchController
    var searchController:UISearchController!
    
    var suggestedSearchFoods:[String] = []
    var filteredSuggestedSearchFoods:[String] = []
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //initialize the searchcontroller 
        self.searchController = UISearchController(searchResultsController: nil)
        
        self.searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        //don't want it to go up into nav bar

        self.searchController.hidesNavigationBarDuringPresentation = false
        
        //define size of the frame
        self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.delegate = self
        //a quirk in ios we need to specify this
        self.definesPresentationContext = true
        
        self.suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "candy", "carrots", "cheddar cheese", "chicen breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "garbonzo beans", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Mark - UITableViewDataSource
    
    //the tableview protocal requires these 2 functions - cellforrowatindexpath and numberofrowsinsection
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //this returns what goes into each cell. use our "Cell" from storyboard
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var foodName:String
        if self.searchController.active {
            
            foodName = filteredSuggestedSearchFoods[indexPath.row]
            
        } else {
            
            foodName = suggestedSearchFoods[indexPath.row]
        }
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
        //will return a blank tableviewcell
        //return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //if we're currently searching, use the number of results,otherwise use full length of list of foods
        if self.searchController.active {
            return self.filteredSuggestedSearchFoods.count
        } else {
            return self.suggestedSearchFoods.count
        }
    }
    
    //UIsearchResults updating delegate
    
    //this is called whenever the search parameters are chnaged. this is coming from the protocol
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        //reload table data
        self.tableView.reloadData()
    }
    
    func filterContentForSearch (searchText: String, scope: Int) {
        self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food:String) -> Bool in
            var foodMatch = food.rangeOfString(searchText)
            return foodMatch != nil
        })
    }
    
    
}

