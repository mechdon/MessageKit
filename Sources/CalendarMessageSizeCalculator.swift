//
//  CalendarMessageSizeCalculator.swift
//  MessageKit
//
//  Created by Gerard Heng on 16/12/24.
//

import Foundation
import UIKit

open class CalendarMessageSizeCalculator: MessageSizeCalculator {
    
    open override func messageContainerSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        switch message.kind {
        case .calendar(let calendarItem):
            
            let width: CGFloat = 280
            let padding: CGFloat = 12
            let rowHeight: CGFloat = 20
            let rowSpacing: CGFloat = 8
            
            // Title height (allow for up to 2 lines)
            let titleFont = UIFont.boldSystemFont(ofSize: 17)
            let titleWidth = width - (padding * 2)
            let titleHeight = calendarItem.calendarEventTitle.height(withConstrainedWidth: titleWidth, font: titleFont)
            
            // Separator
            let separatorHeight: CGFloat = 1
            
            // 3 rows: date, time, venue (each rowHeight + rowSpacing)
            let detailRowsHeight = (rowHeight + rowSpacing) * 3
            
            // Venue can wrap to 2 lines
            let venueFont = UIFont.systemFont(ofSize: 14)
            let venueWidth = width - (padding * 2) - 26 // account for icon width
            let venueHeight = calendarItem.calendarEventVenue.height(withConstrainedWidth: venueWidth, font: venueFont)
            let extraVenueHeight = max(0, venueHeight - rowHeight) // extra height if venue wraps
            
            // RSVP section: separator + buttons + going/not going sections
            let rsvpSeparatorHeight: CGFloat = 1
            let rsvpButtonsHeight: CGFloat = 28
            let goingSectionHeight: CGFloat = 44  // label (16) + spacing (4) + avatars (24)
            let notGoingSectionHeight: CGFloat = 44
            let rsvpTotalHeight = rowSpacing + 4   // space before rsvp separator
                + rsvpSeparatorHeight
                + rowSpacing                        // space after separator
                + rsvpButtonsHeight
                + rowSpacing                        // space after buttons
                + goingSectionHeight
                + 4                                 // space between sections
                + notGoingSectionHeight
            
            let totalHeight = padding          // top padding
                + titleHeight
                + rowSpacing                   // between title and separator
                + separatorHeight
                + rowSpacing                   // between separator and date row
                + detailRowsHeight
                + extraVenueHeight
                + rsvpTotalHeight
                + padding                      // bottom padding
            
            return CGSize(width: width, height: totalHeight)
            
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
