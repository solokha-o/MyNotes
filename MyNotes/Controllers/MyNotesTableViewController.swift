//
//  MyNotesTableViewController.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 01.06.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import UIKit

class MyNotesTableViewController: UITableViewController, DetailNoteTableViewControllerDelegate {
    
    //create array of Note
    var notes = [Note]()
    //create instance CRUDModel to work with core date
    let crudModel = CRUDModel()
    //create bool instance for update core data
    var isUpdateCoreData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetch notes
        notes = crudModel.fetchNote(notes: notes)
        //call setup and configure function
        configureDesignController()
        tableView.tableFooterView = UIView()
        // setup leftBarButtonItem
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    // configure numberOfSections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    //configure numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }
    // configure cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as? NoteTableViewCell else { return UITableViewCell() }
        cell.setCell(note: notes[indexPath.row])
        return cell
    }
    //configure height For Row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            crudModel.removeNote(note: notes[indexPath.row])
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadSections([indexPath.section], with: .fade)
        }
    }
    // configure didSelectRowAt to show detail note
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailNoteTVC = storyboard?.instantiateViewController(identifier: "DetailNoteTableViewController") as? DetailNoteTableViewController else { return }
        detailNoteTVC.isEditingNote = true
        _ = detailNoteTVC.view
        detailNoteTVC.titleNoteTextField.text = notes[indexPath.row].title
        detailNoteTVC.bodyNoteTextView.text = notes[indexPath.row].body
        detailNoteTVC.editNote.id = notes[indexPath.row].id ?? ""
        detailNoteTVC.editNote.date = notes[indexPath.row].date ?? ""
        detailNoteTVC.editNote.favourite = notes[indexPath.row].favourite
        detailNoteTVC.delegate = self
        isUpdateCoreData = true
        show(detailNoteTVC, sender: true)
    }
    //configure view For Footer In Section
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        footerView.backgroundColor = .white
        let countNoteLable = UILabel(frame: CGRect(x: 100, y: 0, width: tableView.frame.size.width, height: 40))
        countNoteLable.text = "You have \(notes.count) notes"
        countNoteLable.textColor = .systemGray
        footerView.addSubview(countNoteLable)
        return footerView
    }
    // configure design Controller
    func configureDesignController() {
        navigationItem.title = "My notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .systemYellow
        navigationController?.navigationBar.backgroundColor = .systemYellow
    }
    //configure delegate parameters
    func addNote(_ detailNoteTableViewController: DetailNoteTableViewController, didAddNote noteModel: NoteModel) {
        // if state edit coreData we find note for id and update in coreData and  tableview
        if isUpdateCoreData {
            crudModel.updatenote(notes: notes, noteModel: noteModel)
            notes = crudModel.fetchNote(notes: notes)
            isUpdateCoreData = false
        } else {
            notes.append(crudModel.saveNote(noteModel: noteModel))
        }
        tableView.reloadData()
    }
    // configure segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let destinationVC = segue.destination as? DetailNoteTableViewController else { return }
        destinationVC.delegate = self
        isUpdateCoreData = false
    }
}
