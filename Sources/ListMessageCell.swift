//
//  ListMessageCell.swift
//  MessageKit
//
//  Created by Gerard Heng on 16/12/24.
//

import UIKit

/// A subclass of `MessageContentCell` used to display list messages.
open class ListMessageCell: MessageContentCell {
    
    /// Image view for calendar image
    public lazy var listIconImageView: UIImageView = {
       
        let listIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        if #available(iOS 13.0, *) {
            listIconImageView.image = UIImage(systemName: "checklist")
        } else {
            // Fallback on earlier versions
            listIconImageView.image = UIImage(named: "checklist.png")
        }
        return listIconImageView
    }()
    
    
    /// list title label
    public lazy var listTitleNameLabel: UILabel = {
        let listTitleNameLabel = UILabel(frame: CGRect.zero)
        listTitleNameLabel.textAlignment = .center
        listTitleNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        listTitleNameLabel.text = "Layers Project"
        return listTitleNameLabel
    }()
    
    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
    open func setupConstraints() {
        
        listIconImageView.constraint(equalTo: CGSize(width: 50, height: 50))
        listIconImageView.addConstraints(left: messageContainerView.leftAnchor, centerY: messageContainerView.centerYAnchor, leftConstant: 5)
        listTitleNameLabel.addConstraints(left: listIconImageView.rightAnchor, right: messageContainerView.rightAnchor, centerY: listIconImageView.centerYAnchor, leftConstant: 5, rightConstant: 5)
        
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        
        messageContainerView.addSubview(listIconImageView)
        messageContainerView.addSubview(listTitleNameLabel)
        setupConstraints()
        
    }
    
    // MARK: - Configure Cell

    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        
        
        
    }
    
    
}
