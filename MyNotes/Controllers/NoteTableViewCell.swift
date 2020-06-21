//
//  NoteTableViewCell.swift
//  MyNotes
//
//  Created by Oleksandr Solokha on 06.06.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleNoteLable: UILabel!
    @IBOutlet weak var bodyNoteLable: UILabel!
    @IBOutlet weak var dateNoteLable: UILabel!
    @IBOutlet weak var favoriteNoteImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    //setup cell function
    func setCell (note: Note) {
        titleNoteLable.text = note.title
        bodyNoteLable.text = note.body
        dateNoteLable.text = note.date
        if note.favourite {
            favoriteNoteImageView.image = UIImage(systemName: "star.fill")
        } else {
            favoriteNoteImageView.image = UIImage(systemName: "star")
        }
    }
}
