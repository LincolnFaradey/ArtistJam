//
//  CoreDataStack.swift
//  WorldCup
//
//  Created by Pietro Rea on 8/2/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
  
    var context: NSManagedObjectContext
    var psc: NSPersistentStoreCoordinator
    var model: NSManagedObjectModel
    var store: NSPersistentStore?

    init() {
        let bundle = Bundle.main
        let modelURL = bundle.url(forResource: "Model", withExtension:"momd")
        model = NSManagedObjectModel(contentsOf: modelURL!)!

        psc = NSPersistentStoreCoordinator(managedObjectModel:model)

        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc

        let documentsURL = CoreDataStack.applicationDocumentsDirectory()

        let storeURL = documentsURL.appendingPathComponent("Artist_Jam")
        print(storeURL)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]

        var error: NSError? = nil
        do {
            store = try psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: storeURL,
                options: options)
        } catch let error1 as NSError {
              error = error1
              store = nil
        }

        if store == nil {
            print("Error adding persistent store: \(String(describing: error))")
          abort()
        }
    }
    
  
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save: \(error), \(error.userInfo)")
            }
        }
    }
  
    class func applicationDocumentsDirectory() -> URL {

        let fileManager = FileManager.default

        let urls = fileManager.urls(for: .documentDirectory,
                                    in: .userDomainMask)

        return urls[0]
    }
  
}
