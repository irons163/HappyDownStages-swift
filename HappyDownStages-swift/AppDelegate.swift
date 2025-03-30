//
//  AppDelegate.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/29.
//

import UIKit
import CoreData
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var launchCount = 0

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Rank")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        launchCount = UserDefaults.standard.integer(forKey: "launchCount") + 1
        UserDefaults.standard.set(launchCount, forKey: "launchCount")

        if launchCount == 10 {
            requestReview()
        }

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // 可選：你也可以在這邊再次呼叫 requestReview()
    }

    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }

    func applicationDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
}
