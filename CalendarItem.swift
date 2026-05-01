//
//  CalendarItem.swift
//  MessageKit
//
//  Created by Gerard Heng on 16/12/24.
//

import Foundation

/// A protocol used to represent the data for a contact message.
public protocol CalendarItem {
    
    /// event id
    var calendarEventId: String { get }
    
    /// event title
    var calendarEventTitle: String { get }
    
    /// event date
    var calendarEventDate: String { get }
    
    /// event start time
    var calendarEventStartTime: String { get }
    
    /// event end time
    var calendarEventEndTime: String { get }
    
    /// event venue
    var calendarEventVenue: String { get }
}
