//
//  ListMessageSizeCalculator.swift
//  MessageKit
//
//  Created by Gerard Heng on 16/12/24.
//

import Foundation

open class ListMessageSizeCalculator: MessageSizeCalculator {
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        switch message.kind {
        case .list:
            return CGSize(width: 300, height: 100)
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
            
        }
    }
}
