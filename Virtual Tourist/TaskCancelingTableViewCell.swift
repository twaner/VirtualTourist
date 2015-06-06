//
//  TaskCancelingTableViewCell.swift
//  Virtual Tourist
//
//  Created by Taiowa Waner on 6/4/15.
//  Copyright (c) 2015 Taiowa Waner. All rights reserved.
//

import UIKit

class TaskCancelingTableViewCell: UICollectionViewCell {
    var imageName: String = ""
    
    var taskToCancelIfCellIsReused: NSURLSessionTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}
