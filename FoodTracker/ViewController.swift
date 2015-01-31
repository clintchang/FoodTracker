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
    
    //these are provided to us from nutritionix
    let kAppId = "55e11913"
    let kAppKey = "c30c07eb497936758b2a106d64b123a3"
    
    
    //going to add a searchController
    var searchController:UISearchController!
    
    var suggestedSearchFoods:[String] = []
    var filteredSuggestedSearchFoods:[String] = []
    
    var apiSearchForFoods:[(name:String, idValue:String)] = []
    
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    var jsonResponse:NSDictionary!
    
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

    //MARK: - UITableViewDataSource
    
    //the tableview protocal requires these 2 functions - cellforrowatindexpath and numberofrowsinsection
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //this returns what goes into each cell. use our "Cell" from storyboard
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var foodName:String
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active {
                
                foodName = filteredSuggestedSearchFoods[indexPath.row]
                
            } else {
                
                foodName = suggestedSearchFoods[indexPath.row]
            }
            
        } else if selectedScopeButtonIndex == 1 {
            //pull out the name from the tuple
            foodName = apiSearchForFoods[indexPath.row].name
        } else {
            foodName = ""
        }
        
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
        

        //will return a blank tableviewcell
        //return UITableViewCell()
    }
    
    
    //Mark - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //find out which index we are at in the searchbar
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            var searchFoodName:String
            //only do this if the search controller is active
            if self.searchController.active {
                searchFoodName = filteredSuggestedSearchFoods[indexPath.row]
            } else {
                searchFoodName = suggestedSearchFoods[indexPath.row]
            }
            self.searchController.searchBar.selectedScopeButtonIndex = 1
            makeRequest(searchFoodName)
            
        } else if selectedScopeButtonIndex == 1 {
            
            
        } else {
            
            
        }
        
        
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            //if we're currently searching, use the number of results,otherwise use full length of list of foods
            if self.searchController.active {
                return self.filteredSuggestedSearchFoods.count
            } else {
                return self.suggestedSearchFoods.count
            }
        } else if selectedScopeButtonIndex == 1 {
            return self.apiSearchForFoods.count
        } else {
            return 0
        }
        
        
    }
    
    // Mark - UIsearchResults updating delegate
    
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
    
    
    //MARK: - UISearchBarDelegate
    
    //when you select different scopes on the search bar, it calls this function
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        self.searchController.searchBar.selectedScopeButtonIndex = 1
        
        //pass in whatever is in our searchbar to the makeREquest function
        makeRequest(searchBar.text)
    }
    
    func makeRequest (searchString:String) {
        
        //THIS CODE IS HOW TO MAKE A HTTP GET REQUEST
//        let url = NSURL (string: "https://api.nutritionix.com/v1_1/search/\(searchString)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(kAppId)&appKey=\(kAppKey)")
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
//            
//            //this converts the data we retrieve into a string
//            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            println(stringData)
//            println(response)
//        })
//        //this executes the request
//        task.resume()
        
        
        //want to create an NSURL request
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search/")!)
        //create session so we can make a request
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        //setting up our dictionary
        var params = [
            "appId" : kAppId,
            "appKey" : kAppKey,
            "fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
            "limit" : "50",
            "query" : searchString,
            "filters" : ["exists":["usda_fields": true]]
        ]
        
        //set up error
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        //helping out the request by specifying these things
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create our nsurl data session task. creates our http request
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //println(stringData)
            var conversionError: NSError?
            //we convert to json dictionary to make it usable data
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &conversionError) as? NSDictionary
            //println(jsonDictionary)
            
            if conversionError != nil {
                println(conversionError!.localizedDescription)
                let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error in parsing \(errorString)")
            } else {
                
                if jsonDictionary != nil {
                    self.jsonResponse = jsonDictionary!
                    self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(jsonDictionary!)
                    
                    //this is running on a background thread so we need to force it update. this dispatch gives us access to the main thread
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                    
                } else {
                    let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON \(errorString)")
                }
            }
            
        })
        task.resume()
    }
    
    
}

