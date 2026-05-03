//
//  PollItem.swift
//  MessageKit
//
//  Created by Gerard Heng on 7/4/26.
//

import Foundation

/// A protocol used to represent the data for a poll message.
public protocol PollItem {
    
    /// The unique poll identifier
    var pollId: String { get }
    
    /// The poll question text
    var pollQuestion: String { get }
}
