//
//  MyNotesTableViewController.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 01.06.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class MyNotesTableViewController: UITableViewController, DetailNoteTableViewControllerDelegate {
    //create and configure log out from account button
    @IBOutlet weak var logOutButtonOutlet: UIBarButtonItem!{
        didSet {
            logOutButtonOutlet.title = "Log out"
        }
    }
    
    //create array of Note
    var notes = [Note]()
    //create instance CRUDModel to work with core date
    let crudModel = CRUDModel()
    //create bool instance for update core data
    var isUpdateCoreData = false
    // create property for search bar and filtered results
    let search = UISearchController(searchResultsController: nil)
    var filteredNotes = [Note]()
    var isSearchBarEmpty: Bool {
        return search.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return search.isActive && !isSearchBarEmpty
    }
    //create current user when controller to view
    let user = Auth.auth().currentUser
    //create google ads banner
    var bannerView: GADBannerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetch notes
        //        notes = crudModel.fetchNote(notes: notes)
        getDataFromFireBase()
        //call setup and configure function
        configureDesignController()
        setSearch()
        tableView.tableFooterView = UIView()
        // setup leftBarButtonItem
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-5473593541867943/6048671865"
        bannerView.rootViewController = self
        requestIDFA()
        bannerView.delegate = self
        addBannerViewToView(bannerView)
    }
    
    // MARK: - Table view data source
    // configure numberOfSections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //configure numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredNotes.count
        }
        return notes.count
    }
    // configure cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as? NoteTableViewCell else { return UITableViewCell() }
        if isFiltering {
            cell.setCell(note: filteredNotes[indexPath.row])
        } else {
            cell.setCell(note: notes[indexPath.row])
        }
        return cell
    }
    //configure height For Row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source and Database
            RealTimeDataBaseModel.shared.deleteValue(for: user, to: notes[indexPath.row].id)
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
    //configure action leading Swipe For Row
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favourite = favouriteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [favourite])
    }
    //configure action to make note favourite
    func favouriteAction (at indexPath: IndexPath) -> UIContextualAction {
        let note = notes[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Favourite") { (action, view, complition) in
            var modelNote = NoteModel()
            if let title = note.title, let body = note.body, let date = note.date, let id = note.id {
                modelNote.title = title
                modelNote.body = body
                modelNote.date = date
                modelNote.id = id
                modelNote.favourite = !note.favourite
                RealTimeDataBaseModel.shared.upDateValue(for: self.user, in: modelNote)
                self.crudModel.updatenote(notes: self.notes, noteModel: modelNote)
                self.tableView.reloadData()
                complition(true)
            }
        }
        action.backgroundColor = note.favourite ? .systemPink : .systemGray
        action.image = note.favourite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        return action
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
        // if state edit coreData we find note for id and update in coreData and  Database
        if isUpdateCoreData {
            RealTimeDataBaseModel.shared.upDateValue(for: user, in: noteModel)
            crudModel.updatenote(notes: notes, noteModel: noteModel)
            //            notes = crudModel.fetchNote(notes: notes)
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
    //configure search controller
    func setSearch() {
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = true
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search note"
        definesPresentationContext = true
    }
    // func for filter Content For Search Text
    func filterContentForSearchText(_ searchText: String) {
        filteredNotes = notes.filter { (note: Note) -> Bool in
            if let title = note.title, let body = note.body, let date = note.date {
                return (title.lowercased().contains(searchText.lowercased())) || (body.lowercased().contains(searchText.lowercased())) || (date.lowercased().contains(searchText.lowercased()))
            }
            return true
        }
        tableView.reloadData()
    }
    //get note from Database to tableView sorted by date of note
    func getDataFromFireBase() {
        RealTimeDataBaseModel.shared.getValue(for: user) { [weak self] notes in
            self?.notes = notes.sorted {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yy"
                if let noteDate0 = $0.date, let noteDate1 = $1.date {
                    if let date0 = dateFormatter.date(from: noteDate0), let date1 = dateFormatter.date(from: noteDate1) {
                        if date0 > date1 {
                            return true
                        } else {
                            return false
                        }
                    }
                }
                return true
            }
            self?.tableView.reloadData()
        }
    }
    //configure google ads banner
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: tableView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Tracking authorisation completed. Start loading ads here.
                self.bannerView.load(GADRequest())
            })
        } else {
            bannerView.load(GADRequest())
        }
    }
    //configure action for log out button
    @IBAction func logOutButtonAction(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            //configure transition to SignInViewController  when user log out
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let signInVC = storyboard.instantiateViewController(identifier: "SignInViewController") as? SignInViewController else { return }
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            UIView.transition(with: window, duration: 0.5, options: .transitionCurlDown) {
                window.rootViewController = signInVC
            }
            window.makeKeyAndVisible()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
//configure extension MyNotesTableViewController to UISearchResultsUpdating
extension MyNotesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = search.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

//configure extension with GADBannerViewDelegate protocol
extension MyNotesTableViewController: GADBannerViewDelegate {
    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    // Tells the delegate that a full-screen view will be presented in response
    // to the user clicking on an ad.
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    // Tells the delegate that the full-screen view will be dismissed.
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    // Tells the delegate that the full-screen view has been dismissed.
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    // Tells the delegate that a user click will open another app (such as
    // the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
