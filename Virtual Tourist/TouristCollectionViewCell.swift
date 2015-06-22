//
//  TouristCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 5/30/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit

/**
A custom UICollectionView cell that inherits from TaskCancelingTableViewCell.

*/

class TouristCollectionViewCell: TaskCancelingTableViewCell {
    /// The cell's image.
    @IBOutlet weak var cellImage: UIImageView!
    /// The cell's activity view.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}
