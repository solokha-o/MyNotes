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
    func saveNote(note: NoteModel) -> Note {
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
    func fetchNote(notes: [Note]) -> [Note]{
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
    // remove note from coreDate
    func removeNote(note: Note?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        if let note = note {
            context.delete(note)
        }
        do{
            try context.save()
        } catch let error {
            print("Error \(error).")
        }
    }
    // update note in coreDate
    func updatenote(notes: [Note], id: String, note: Note) {
        for i in notes.indices {
            if notes[i].id == id {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = Note.fetchRequest() as NSFetchRequest<Note>
                do {
                    let updateContext = try context.fetch(fetchRequest)
                    if updateContext.count > 0 {
                        let objUpdate =  updateContext[i] as NSManagedObject
                        objUpdate.setValue(note.title, forKey: "title")
                        objUpdate.setValue(note.body, forKey: "body")
                        objUpdate.setValue(note.favorite, forKey: "favorite")
                        
                        do {
                            try context.save()
                        } catch let error {
                            print("Error \(error).")
                        }
                    }
                } catch let error {
                        print("Error \(error).")
                }
            }
        }
    }
}
