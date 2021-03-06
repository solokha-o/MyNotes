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
    convenience init?(snapshot: [String: AnyObject], insertIntoManagedObjectContext context: NSManagedObjectContext) {
        self.init()
        guard let entity = NSEntityDescription.entity(forEntityName: "Note", in: context) else {return}
        self.init(entity: entity, insertInto: context)
        self.title = snapshot["title"] as? String ?? ""
        self.body = snapshot["body"] as? String ?? ""
        self.date = snapshot["date"] as? String ?? ""
        self.favourite = snapshot["favourite"] as? Bool ?? false
        self.id = snapshot["title"] as? String ?? ""
    }
}
