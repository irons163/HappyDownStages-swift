//
//  DatabaseManager.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import Foundation
import CoreData
import UIKit

class DatabaseManager {

    static let shared = DatabaseManager()
    private init() {}

    var managedObjectContext: NSManagedObjectContext? {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        return context
    }

    func insert(name: String, score: Int) {
        guard let context = managedObjectContext else { return }
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Entity", into: context)
        entity.setValue(name, forKey: "name")
        entity.setValue(score, forKey: "score")

        do {
            try context.save()
        } catch let error as NSError {
            print("Whoops, couldn't save: \(error.localizedDescription)")
        }
    }

    func load() -> [NSManagedObject] {
        guard let context = managedObjectContext else { return [] }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
        let sortByScore = NSSortDescriptor(key: "score", ascending: false)
        fetchRequest.sortDescriptors = [sortByScore]

        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            return fetchedObjects
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
            return []
        }
    }
}
