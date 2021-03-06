//
//  FirebaseCloudStorageModel.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 04.03.2021.
//  Copyright © 2021 Oleksandr Solokha. All rights reserved.
//

import Foundation
import Firebase

struct RealTimeDataBaseModel {
    //create reference to path with notes in Database
    let ref = Database.database().reference(withPath: "notes")
    //create single instance to RealTimeDataBaseModel
    static var shared = RealTimeDataBaseModel()
    //write note to Database
    func writeValue(for user: User?, in note: NoteModel) {
        guard let uid = user?.uid else { return }
        let noteRef = self.ref.child(uid).child(note.title)
        noteRef.setValue(note.anyObject)
    }
    //read note from Database and write it on Core Data
    func getValue(for user: User?, completion: @escaping (([Note]) -> Void)) {
        if let uid = user?.uid {
            ref.child(uid).observe(.value) { snapshot in
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                print(postDict)
                var notes = [Note]()
                for (_, value)  in postDict {
                    print(value)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    if let note = Note(shapshot: value as? [String : AnyObject] ?? [:], insertIntoManagedObjectContext: context) {
                        print("Get note\(note)")
                        notes.append(note)
                    }
                }
                DispatchQueue.main.async {
                    completion(notes)
                    print(notes)
                }
            }
        }
    }
    //update note in Database
    func upDateValue(for note: NoteModel) {
        
    }
    //delete note from Database
    func deleteValue(to note: NoteModel) {
        
    }
    
}

