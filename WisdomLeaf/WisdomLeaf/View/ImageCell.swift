//
//  ImageCell.swift
//  WisdomLeaf
//
//  Created by DDP on 29/05/23.
//

import UIKit

class ImageCell: UITableViewCell {

    @IBOutlet weak var chcekBox: UIImageView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var rolledImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
