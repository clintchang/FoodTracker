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


let kUSDAItemCompleted = "USDAItemInstanceComplete"

class DataController {
    
    class func jsonAsUSDAIdAndNameSearchResults (json : NSDictionary) -> [(name: String, idValue: String)] {
        
        var usdaItemsSearchResults:[(name : String, idValue : String)] = []
        var searchResult: (name : String, idValue : String)
        
        if json["hits"] != nil {
            
            println("hello data controller")
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
        
        
        println("save USDA Item for ID")
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
                        
                        println("The item was already saved!")
                        //The item is already saved so we don't want to save it again
                        return
                    } else {
                        
                        println("Lets save this to CoreData!")
                        
                        //create our entity
                        let entityDescription = NSEntityDescription.entityForName("USDAItem", inManagedObjectContext: managedObjectContext!)
                        let usdaItem = USDAItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                        usdaItem.idValue = itemDictionary["_id"]! as String
                        //creates default NSDate which is the current date
                        usdaItem.dateAdded = NSDate()
                        
                        //access the fields dictionary
                        if itemDictionary["fields"] != nil {
//                            println ("inside itemdictionary")
                            let fieldsDictionary = itemDictionary["fields"]! as NSDictionary
                            if fieldsDictionary["item_name"] != nil {
                                usdaItem.name = fieldsDictionary["item_name"]! as String
                                
                            }
                            
                            if fieldsDictionary["usda_fields"] != nil {
                                let usdaFieldsDictionary = fieldsDictionary["usda_fields"]! as NSDictionary
                                
                                //Calcium
                                if usdaFieldsDictionary["CA"] != nil {
                                    let calciumDictionary = usdaFieldsDictionary["CA"]! as NSDictionary
                                    if calciumDictionary["value"] != nil {
                                        //we don't know if calcium value is a string or number so we convert it to a variable here
                                        let calciumValue: AnyObject = calciumDictionary["value"]!
                                        usdaItem.calcium = "\(calciumValue)"
                                    } else {
                                        usdaItem.calcium = "N/A"
                                    }
                                } else {
                                    usdaItem.calcium = "N/A"
                                }
                                
                                //Carbohydrates
                                if usdaFieldsDictionary["CHOCDF"] != nil {
                                    let carbohydrateDictionary = usdaFieldsDictionary["CHOCDF"]! as NSDictionary
                                    if carbohydrateDictionary["value"] != nil {
                                        let carbohydrateValue:AnyObject = carbohydrateDictionary["value"]!
                                        usdaItem.carbohydrate = "\(carbohydrateValue)"
                                    }
                                } else {
                                    usdaItem.carbohydrate = "N/A"
                                }
                                
                                //Fat
                                if usdaFieldsDictionary["FAT"] != nil {
                                    let fatTotalDictionary = usdaFieldsDictionary["FAT"]! as NSDictionary
                                    if fatTotalDictionary["value"] != nil {
                                        let fatTotalValue:AnyObject = fatTotalDictionary["value"]!
                                        usdaItem.fatTotal = "\(fatTotalValue)"
                                    }
                                } else {
                                    usdaItem.fatTotal = "N/A"
                                }
                                
                                // Cholesterol Grouping (optional to add this comment)
                                if usdaFieldsDictionary["CHOLE"] != nil {
                                    let cholesterolDictionary = usdaFieldsDictionary["CHOLE"]! as NSDictionary
                                    if cholesterolDictionary["value"] != nil {
                                        let cholesterolValue: AnyObject = cholesterolDictionary["value"]!
                                        usdaItem.cholesterol = "\(cholesterolValue)"
                                    }
                                }
                                else {
                                    usdaItem.cholesterol = "0"
                                }
                                
                                // Protein Grouping (optional to add this comment)
                                if usdaFieldsDictionary["PROCNT"] != nil {
                                    let proteinDictionary = usdaFieldsDictionary["PROCNT"]! as NSDictionary
                                    if proteinDictionary["value"] != nil {
                                        let proteinValue: AnyObject = proteinDictionary["value"]!
                                        usdaItem.protein = "\(proteinValue)"
                                    }
                                }
                                else {
                                    usdaItem.protein = "0"
                                }
                                
                                // Sugar Total
                                if usdaFieldsDictionary["SUGAR"] != nil {
                                    let sugarDictionary = usdaFieldsDictionary["SUGAR"]! as NSDictionary
                                    if sugarDictionary["value"] != nil {
                                        let sugarValue:AnyObject = sugarDictionary["value"]!
                                        usdaItem.sugar = "\(sugarValue)"
                                    }
                                }
                                else {
                                    usdaItem.sugar = "0"
                                }
                                
                                // Vitamin C
                                if usdaFieldsDictionary["VITC"] != nil {
//                                    println("Vitamin C")
                                    let vitaminCDictionary = usdaFieldsDictionary["VITC"]! as NSDictionary
                                    if vitaminCDictionary["value"] != nil {
                                        let vitaminCValue: AnyObject = vitaminCDictionary["value"]!
                                        usdaItem.vitaminC = "\(vitaminCValue)"
                                    }
                                }
                                else {
                                    usdaItem.vitaminC = "0"
                                }
                                
                                // Energy
                                if usdaFieldsDictionary["ENERC_KCAL"] != nil {
//                                    println("Energy")
                                    let energyDictionary = usdaFieldsDictionary["ENERC_KCAL"]! as NSDictionary
                                    if energyDictionary["value"] != nil {
                                        let energyValue: AnyObject = energyDictionary["value"]!
                                        usdaItem.energy = "\(energyValue)"
                                    }
                                }
                                else {
                                    usdaItem.energy = "0"
                                }
                                
                                //SAVE YOUR DATA
                                
                                (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                                
//                                println("saving")
                                
                                //going to create a radio station to send notifications to different controllers
                                NSNotificationCenter.defaultCenter().postNotificationName(kUSDAItemCompleted, object: usdaItem)
                                
                                
                                
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
    
    }
    
}

