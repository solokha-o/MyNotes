//
//  DetailNoteTableViewController.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 01.06.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import UIKit
// create protocol to pass Note
protocol DetailNoteTableViewControllerDelegate {
    func addNote(_ detailNoteTableViewController: DetailNoteTableViewController, didAddNote Note: Note )
}

class DetailNoteTableViewController: UITableViewController {
    
    // enum for state of controller to save or to edit note
    enum State {
        case saveNote, editNote
        
        var rightButtonTitle: String {
            switch self {
            case .saveNote: return "Save"
            case .editNote: return "Edit"
            }
        }
    }
    
    @IBOutlet weak var saveNoteButtonOutlet: UIBarButtonItem! {
        didSet {
            // configure saveNoteButtonOutlet
            saveNoteButtonOutlet.title = currentState.rightButtonTitle
        }
    }
    @IBOutlet weak var titleNoteTextField: UITextField! {
        didSet {
            // configure titleNoteTextField
            titleNoteTextField.placeholder = "Note's title"
            titleNoteTextField.font = .preferredFont(forTextStyle: .title2)
            titleNoteTextField.clearButtonMode = .whileEditing
        }
    }
    @IBOutlet weak var bodyNoteTextView: UITextView! {
        didSet {
            // configure bodyNoteTextView
            bodyNoteTextView.isScrollEnabled = false
            let placeHolder = "Enter your note"
            bodyNoteTextView.text = placeHolder
            bodyNoteTextView.textColor = .lightGray
            bodyNoteTextView.font = .preferredFont(forTextStyle: .body)
        }
    }
    
    //    var isEditingNote = true
    // create state of controller
    var currentState = State.saveNote
    // add scrollView
    let scrollView = UIScrollView()
    //create delegate of DetailNoteTableViewControllerDelegate
    var delegate: DetailNoteTableViewControllerDelegate?
    //create current date
    let date = Date()
    //create date formatter
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyNoteTextView.delegate = self
        //configure dateFormatter
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    // configure title of section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleSection = ""
        switch section {
        case 0:
            titleSection = "Title"
        case 1:
            titleSection = "Note's body"
        default:
            break
        }
        return titleSection
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    // configure saveNoteButtonAction
    @IBAction func saveNoteButtonAction(_ sender: Any) {
        // create Note instance and add to it value
        let note = Note()
        note.title = titleNoteTextField.text
        note.body = bodyNoteTextView.text
        note.favorite = false
        note.id = UUID() .uuidString
        note.date = dateFormatter.string(from: date)
        // pass to delegate Note
        delegate?.addNote(self, didAddNote: note)
    }
}

extension DetailNoteTableViewController: UITextViewDelegate {
    // configure size of textView when enter text
    func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        // Resize the cell only when cell's size is changed
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "bodyCell") else { return }
            if let thisIndexPath = tableView?.indexPath(for: cell) {
                tableView?.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
            }
        }
    }
    //    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    //        scrollView.setContentOffset(CGPoint(x: 0, y: textView.superview?.frame.origin.y ?? 0), animated: true)
    //        return true
    //    }
    //
    //    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    //        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    //        return true
    //    }
    //configure textView that you can see placeholder and color of text
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your note"
            textView.textColor = UIColor.lightGray
        }
    }
}
