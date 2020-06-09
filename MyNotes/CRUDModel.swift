//
//  CRUDModel.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 01.06.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct CRUDModel {
    // add save note to coreData
    func saveItem(note: NoteModel) -> Note {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newNote = Note(context: context)
        newNote.title = note.title
        newNote.body = note.body
        newNote.date = note.date
        newNote.favorite = note.favorite
        newNote.id = note.id
        do {
            try context.save()
        } catch let error {
            print("Error \(error).")
        }
        return newNote
    }
    // fetch note from coreData
    func fetchItem(notes: [Note]) -> [Note]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        var fetchNotes = notes
        let fetchRequest = Note.fetchRequest() as NSFetchRequest<Note>
        do {
            fetchNotes = try context.fetch(fetchRequest)
        } catch let error {
            print("Error: \(error).")
        }
        return fetchNotes
    }
}
