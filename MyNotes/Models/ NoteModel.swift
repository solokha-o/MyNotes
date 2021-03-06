//
//   NoteModel.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 01.06.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import Foundation
//create model of note
struct  NoteModel {
    var title : String = ""
    var body : String = ""
    var date : String = ""
    var favourite : Bool = false
    var id : String = ""
}
// extension that to convert note to any object
extension NoteModel {
    var anyObject: Any {
        ["title": title,
         "body": body,
         "date": date,
         "favourite": favourite,
         "id": id]
    }
}
