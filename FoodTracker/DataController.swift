//
//  DataController.swift
//  FoodTracker
//
//  Created by Clint on 1/31/15.
//  Copyright (c) 2015 Republic. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataController {
    
    class func jsonAsUSDAIdAndNameSearchResults (json : NSDictionary) -> [(name: String, idValue: String)] {
        
        var usdaItemsSearchResults:[(name : String, idValue : String)] = []
        var searchResult: (name : String, idValue : String)
        
        if json["hits"] != nil {
            
            let results:[AnyObject] = json ["hits"]! as [AnyObject]
            
            for itemDictionary in results {
                
                if itemDictionary["_id"] != nil {
                    if itemDictionary["fields"] != nil {
                        let fieldsDictionary = itemDictionary["fields"] as NSDictionary
                        if fieldsDictionary["item_name"] != nil {
                            let idValue:String = itemDictionary["_id"]! as String
                            let name:String = fieldsDictionary["item_name"]! as String
                            searchResult = (name : name, idValue : idValue)
                            usdaItemsSearchResults += [searchResult]
                        }
                    }
                }
                
            }
        }
        return usdaItemsSearchResults
    }
    
    //this is an instance function and not a class function
    func saveUSDAItemForId(idValue: String, json: NSDictionary ){
        
        //going to search in the json dictionary
        if json["hits"] != nil {
            
            let results:[AnyObject] = json ["hits"]! as [AnyObject]
            //going to iterate through all the objects in results dict
            for itemDictionary in results {
                
                if itemDictionary["_id"] != nil && itemDictionary["_id"] as String == idValue {
                    
                    //create a managedobject context which will allow us to do a search
                    
                    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
                    
                    var requestForUSDAItem = NSFetchRequest(entityName: "USDAItem")
                    
                    let itemDictionaryId = itemDictionary["_id"]! as String
                    
                    //need to check coredatea if we've already saved this item before
                    let predicate = NSPredicate(format: "idValue == %@", itemDictionaryId)
                    
                    requestForUSDAItem.predicate = predicate
                    
                    var error:NSError?
                    
                    //this will execute the request
                    var items = managedObjectContext?.executeFetchRequest(requestForUSDAItem, error: &error)
                    
                    if items?.count != 0 {
                        //The item is already saved so we don't want to save it again
                        return
                    } else {
                        
                        println("Lets save this to CoreData!")
                        
                        
                    }
                
                    
                    
                }
                
                
                
            }
            
        }
        
        
    }
    
    
    
    
}

