//
//  Entity.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import Foundation
import CoreData

@objc(Entity)
public class Entity: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var score: NSNumber?
}
