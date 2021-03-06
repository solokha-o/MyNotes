//
//  DetailNoteTableViewController.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 01.06.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import UIKit
import Firebase
// create protocol to pass Note
protocol DetailNoteTableViewControllerDelegate {
    func addNote(_ detailNoteTableViewController: DetailNoteTableViewController, didAddNote noteModel: NoteModel )
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
        var navigationTitle: String {
            switch self {
                case .saveNote: return "New note"
                case .editNote: return "My note"
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
            if isEditingNote {
                titleNoteTextField.isUserInteractionEnabled = false
            }
        }
    }
    @IBOutlet weak var bodyNoteTextView: UITextView! {
        didSet {
            // configure bodyNoteTextView
            bodyNoteTextView.isScrollEnabled = false
            let placeHolder = "Enter your note"
            bodyNoteTextView.text = placeHolder
            if isEditingNote {
                bodyNoteTextView.isUserInteractionEnabled = false
            } else {
                bodyNoteTextView.textColor = .lightGray
            }
            bodyNoteTextView.font = .preferredFont(forTextStyle: .body)
        }
    }
    // create Bool state editing note
    var isEditingNote = false
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
    // create instance CRUDModel
    let crudModel = CRUDModel()
    // create instance NoteModel for pass property in edit state
    var editNote = NoteModel()
    // create bool instance for check edit note
    var isSaveEditNote = false
    //create current user when controller to view
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isEditingNote {
            currentState = .editNote
        }
        bodyNoteTextView.delegate = self
        titleNoteTextField.delegate = self
        //configure dateFormatter
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "dd.MM.yyyy"
        //call setup and configure functions
        //        updateSaveNoteButtonOutletState()
        configureDesignController()
        // create NotificationCenter for keyboardWillShowNotification and keyboardWillHideNotification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    //configure height For Row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    // configure saveNoteButtonAction
    @IBAction func saveNoteButtonAction(_ sender: UIBarButtonItem) {
        // create NoteModel instance and add to it value
        var noteModel = NoteModel()
        
        
        //configure button for state save or edit
        switch isEditingNote {
            case false:
                if isSaveEditNote {
                    if sender.title == "Save" {
                        editNote.title = titleNoteTextField.text ?? ""
                        editNote.body = bodyNoteTextView.text ?? ""
                        print(editNote.id)
                        if titleNoteTextField.text == "" || (bodyNoteTextView.text == "Enter your note" || bodyNoteTextView.text == "") {
                            let alert = UIAlertController(title: "You forgot", message: "The field must be filled!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            // pass to delegate noteModel
                            delegate?.addNote(self, didAddNote: editNote)
                            navigationController?.popToRootViewController(animated: true)
                            isSaveEditNote = false
                        }
                    }
                } else {
                    let titleNote = titleNoteTextField.text ?? ""
                    let bodyNote = bodyNoteTextView.text ?? ""
                    noteModel.title = titleNote
                    noteModel.body = bodyNote
                    noteModel.favourite = false
                    noteModel.id = UUID() .uuidString
                    noteModel.date = dateFormatter.string(from: date)
                    if titleNoteTextField.text == "" || (bodyNoteTextView.text == "Enter your note" || bodyNoteTextView.text == "") {
                        let alert = UIAlertController(title: "You forgot", message: "The field must be filled!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        // pass to delegate noteModel and write note to Database
                        delegate?.addNote(self, didAddNote: noteModel)
                        navigationController?.popViewController(animated: true)
                        RealTimeDataBaseModel.shared.writeValue(for: user, in: noteModel)
                    }
                }
            case true:
                currentState = .editNote
                sender.title = "Save"
                navigationItem.title = "Edit note"
                titleNoteTextField.isUserInteractionEnabled = true
                bodyNoteTextView.isUserInteractionEnabled = true
                isSaveEditNote = true
                isEditingNote = false
        }
    }
    // configure design Controller
    func configureDesignController() {
        navigationItem.title = currentState.navigationTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .systemYellow
        navigationController?.navigationBar.backgroundColor = .systemYellow
        tableView.backgroundColor = .systemYellow
        saveNoteButtonOutlet.title = currentState.rightButtonTitle
    }
    // configur function keyboardWillAppear and keyboardWillHide
    @objc func keyboardWillAppear(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print(notification)
    }
    //Deinit NotificationCenter
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
// extension to UITextViewDelegate
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
// extension to UITextFieldDelegate
extension DetailNoteTableViewController: UITextFieldDelegate {
    
}
