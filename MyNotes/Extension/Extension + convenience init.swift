//
//  Extension + convenience init.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 06.03.2021.
//  Copyright © 2021 Oleksandr Solokha. All rights reserved.
//

import Foundation
import CoreData

//configure init for Type Note with snapshot and insertIntoManagedObjectContext
extension Note {
    convenience init?(shapshot: [String: AnyObject], insertIntoManagedObjectContext context: NSManagedObjectContext) {
        self.init()
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else {return}
        self.init(entity: entity, insertInto: context)
        self.title = shapshot["title"] as? String ?? ""
        self.body = shapshot["body"] as? String ?? ""
        self.date = shapshot["date"] as? String ?? ""
        self.favourite = shapshot["favourite"] as? Bool ?? false
        self.id = shapshot["title"] as? String ?? ""
    }
}
