//
//  PollMessageSizeCalculator.swift
//  MessageKit
//
//  Created by Gerard Heng on 7/4/26.
//

import Foundation
import UIKit

open class PollMessageSizeCalculator: MessageSizeCalculator {
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        switch message.kind {
        case .poll(let pollItem):
            
            let width: CGFloat = 280
            let padding: CGFloat = 12
            
            // Title height ("📊 Question") — uses String.height extension from CalendarMessageSizeCalculator
            let titleFont = UIFont.boldSystemFont(ofSize: 16)
            let titleWidth = width - (padding * 2)
            let titleText = "📊 " + pollItem.pollQuestion
            let titleHeight = titleText.height(withConstrainedWidth: titleWidth, font: titleFont)
            
            // Placeholder for options (will be loaded dynamically)
            // Estimate 3 options by default, each ~44pt (button + progress bar)
            let estimatedOptionHeight: CGFloat = 44
            let estimatedOptionCount: CGFloat = 3
            let optionsHeight = estimatedOptionHeight * estimatedOptionCount
            
            // Footer
            let footerHeight: CGFloat = 20
            
            // Close poll button area
            let closePollHeight: CGFloat = 36
            
            let totalHeight = padding
                + titleHeight
                + 8    // spacing
                + optionsHeight
                + 8    // spacing
                + footerHeight
                + 4    // spacing
                + closePollHeight
                + padding
            
            return CGSize(width: width, height: totalHeight)
            
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }
}
