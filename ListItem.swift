//
//  ListItem.swift
//  MessageKit
//
//  Created by Gerard Heng on 16/12/24.
//

import Foundation

/// A protocol used to represent the data for a contact message.
public protocol ListItem {
    
    /// list id
    var listId: String { get }
    
    /// list title
    var listTitle: String { get }
    
}
