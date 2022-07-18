//
//  DataController.swift
//  TwittermentGauge
//
//  Created by Georgi Markov on 7/6/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    // Responsiblities:
    // 1. Hold persistentContainer instance
    // 2. Load persistenat store
    // 3. Access Context
    
    // 1.
    let persistentContainer: NSPersistentContainer
    
    // 3.
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // 2.
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
}
