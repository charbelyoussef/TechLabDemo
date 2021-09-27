//
//  FoodsVCContentCell.swift
//  TechLabDemo
//
//  Created by Youssef on 9/27/21.
//

import UIKit
import SDWebImage

class FoodsVCContentCell: UICollectionViewCell {
    

    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var ivHeader: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrepTime: UILabel!
    @IBOutlet weak var lblSmallDescription: UILabel!
    
    override func awakeFromNib() {
        vContainer.layer.cornerRadius = 10
        vContainer.layer.borderWidth = 1
        vContainer.layer.borderColor = UIColor(hexString: "D1D1D6").cgColor
    }
    
    func configureCell(receipeObject: Structs.Receipe?){
        ivHeader.sd_setImage(with: URL(string: receipeObject?.imageurl?.safeURL() ?? "N/A"), completed: nil)
        lblTitle.text = receipeObject?.name
        lblPrepTime.text = receipeObject?.timetoprepare
        lblSmallDescription.text = receipeObject?.smalldescription
    }

}
