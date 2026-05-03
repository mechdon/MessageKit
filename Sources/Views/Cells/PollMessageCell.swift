//
//  PollMessageCell.swift
//  MessageKit
//
//  Created by Gerard Heng on 7/4/26.
//

import UIKit

// MARK: - PollMessageCellDelegate

/// Delegate for PollMessageCell interactions.
/// Implemented by GroupChatViewController which has access to Firebase.
public protocol PollMessageCellDelegate: AnyObject {
    /// Called when the user taps a vote option
    func pollCell(_ cell: PollMessageCell, didVoteForOption index: Int, pollId: String)
    /// Called when the cell needs Firebase listeners attached for this poll
    func pollCell(_ cell: PollMessageCell, attachListenersForPollId pollId: String)
    /// Called when the cell is being reused — detach Firebase listeners
    func pollCellWillReuse(_ cell: PollMessageCell)
}

// MARK: - PollMessageCell

/// A subclass of `MessageContentCell` used to display poll messages.
open class PollMessageCell: MessageContentCell {
    
    // MARK: - Delegate
    
    public weak var pollDelegate: PollMessageCellDelegate?
    
    // MARK: - State
    
    public var currentPollId: String?
    
    // MARK: - UI Elements
    
    /// Poll question label
    public lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 3
        return label
    }()
    
    /// Container for poll option rows
    public lazy var optionsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 6
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    /// Footer label (vote count + status)
    public lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    /// Close Poll button (visible to creator only)
    public lazy var closePollButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("Close Poll", comment: ""), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    // MARK: - Lifecycle
    
    open override func setupSubviews() {
        super.setupSubviews()
        
        messageContainerView.addSubview(questionLabel)
        messageContainerView.addSubview(optionsStackView)
        messageContainerView.addSubview(footerLabel)
        messageContainerView.addSubview(closePollButton)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        pollDelegate?.pollCellWillReuse(self)
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        closePollButton.isHidden = true
        currentPollId = nil
    }
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard case .poll(let pollItem) = message.kind else { return }
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else { return }
        
        questionLabel.text = "📊 " + pollItem.pollQuestion
        currentPollId = pollItem.pollId
        
        layoutPollSubviews()
        
        // Ask display delegate to set pollDelegate (same pattern as CalendarMessageCell)
        displayDelegate.configurePollCell(self, message: message)
        
        // After delegate is set, ask it to attach Firebase listeners
        if !pollItem.pollId.isEmpty {
            pollDelegate?.pollCell(self, attachListenersForPollId: pollItem.pollId)
        }
    }
    
    // MARK: - Layout
    
    private func layoutPollSubviews() {
        let padding: CGFloat = 12
        let containerWidth = messageContainerView.bounds.width
        let contentWidth = containerWidth - (padding * 2)
        
        questionLabel.frame = CGRect(
            x: padding,
            y: padding,
            width: contentWidth,
            height: 0
        )
        questionLabel.sizeToFit()
        questionLabel.frame.size.width = contentWidth
        
        optionsStackView.frame = CGRect(
            x: padding,
            y: questionLabel.frame.maxY + 8,
            width: contentWidth,
            height: 0
        )
        
        footerLabel.frame = CGRect(
            x: padding,
            y: optionsStackView.frame.maxY + 8,
            width: contentWidth,
            height: 16
        )
        
        closePollButton.frame = CGRect(
            x: padding,
            y: footerLabel.frame.maxY + 4,
            width: contentWidth,
            height: 28
        )
    }
    
    // MARK: - Public Methods (called by delegate)
    
    /// Build or rebuild the options UI with vote data.
    /// Called by GroupChatViewController when Firebase data changes.
    public func updateOptions(
        options: [String],
        voteCounts: [Int],
        totalVotes: Int,
        myVotes: Set<Int>,
        allowMultiple: Bool,
        pollClosed: Bool,
        isDeadlinePassed: Bool,
        isCreator: Bool,
        deadline: String?,
        showResultsBeforeVote: Bool = true
    ) {
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let canVote = !pollClosed && !isDeadlinePassed
        let userHasVoted = !myVotes.isEmpty
        let showResults = userHasVoted || pollClosed || showResultsBeforeVote
        
        let accentColor = UIColor.systemGreen
        
        for (i, optionText) in options.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .vertical
            rowStack.spacing = 2
            
            // Header: selector + text + count
            let headerStack = UIStackView()
            headerStack.axis = .horizontal
            headerStack.spacing = 8
            headerStack.alignment = .center
            
            // Selector button (circle or checkmark)
            let selectorBtn = UIButton(type: .system)
            selectorBtn.tag = i
            let isSelected = myVotes.contains(i)
            
            if isSelected {
                selectorBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                selectorBtn.tintColor = accentColor
            } else {
                selectorBtn.setImage(UIImage(systemName: "circle"), for: .normal)
                selectorBtn.tintColor = .systemGray3
            }
            
            selectorBtn.isEnabled = canVote
            if canVote {
                selectorBtn.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            }
            
            selectorBtn.widthAnchor.constraint(equalToConstant: 24).isActive = true
            selectorBtn.heightAnchor.constraint(equalToConstant: 24).isActive = true
            
            // Option text
            let textLabel = UILabel()
            textLabel.text = optionText
            textLabel.font = UIFont.systemFont(ofSize: 14)
            textLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            textLabel.numberOfLines = 2
            textLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            // Count label
            let countLabel = UILabel()
            countLabel.font = UIFont.systemFont(ofSize: 13)
            countLabel.textColor = .gray
            countLabel.textAlignment = .right
            if showResults {
                countLabel.text = "\(voteCounts[i])"
            }
            countLabel.setContentHuggingPriority(.required, for: .horizontal)
            countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            headerStack.addArrangedSubview(selectorBtn)
            headerStack.addArrangedSubview(textLabel)
            headerStack.addArrangedSubview(countLabel)
            
            rowStack.addArrangedSubview(headerStack)
            
            // Progress bar
            if showResults && totalVotes > 0 {
                let progressBg = UIView()
                progressBg.backgroundColor = UIColor(white: 0.88, alpha: 1)
                progressBg.layer.cornerRadius = 3
                progressBg.clipsToBounds = true
                progressBg.heightAnchor.constraint(equalToConstant: 6).isActive = true
                
                let progressFg = UIView()
                let fraction = CGFloat(voteCounts[i]) / CGFloat(totalVotes)
                progressFg.backgroundColor = isSelected ? accentColor : UIColor.systemBlue.withAlphaComponent(0.5)
                progressFg.layer.cornerRadius = 3
                progressBg.addSubview(progressFg)
                
                // We'll set the frame after layout
                progressFg.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    progressFg.leadingAnchor.constraint(equalTo: progressBg.leadingAnchor),
                    progressFg.topAnchor.constraint(equalTo: progressBg.topAnchor),
                    progressFg.bottomAnchor.constraint(equalTo: progressBg.bottomAnchor),
                    progressFg.widthAnchor.constraint(equalTo: progressBg.widthAnchor, multiplier: fraction)
                ])
                
                rowStack.addArrangedSubview(progressBg)
            }
            
            optionsStackView.addArrangedSubview(rowStack)
        }
        
        // Footer
        var footerStr: String
        if totalVotes == 1 {
            footerStr = String(format: NSLocalizedString("%d vote", comment: ""), totalVotes)
        } else {
            footerStr = String(format: NSLocalizedString("%d votes", comment: ""), totalVotes)
        }
        if pollClosed || isDeadlinePassed {
            footerStr += " · " + NSLocalizedString("Poll ended", comment: "")
        } else if let deadline = deadline, !deadline.isEmpty {
            let isoFormatter = DateFormatter()
            isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            isoFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let deadlineDate = isoFormatter.date(from: deadline) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM dd"
                footerStr += " · Ends " + displayFormatter.string(from: deadlineDate)
            }
        }
        footerLabel.text = footerStr
        
        // Close poll button
        if isCreator && !pollClosed && !isDeadlinePassed {
            closePollButton.isHidden = false
        } else {
            closePollButton.isHidden = true
        }
        
        // Re-layout
        optionsStackView.layoutIfNeeded()
        let stackHeight = optionsStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        optionsStackView.frame.size.height = stackHeight
        
        footerLabel.frame.origin.y = optionsStackView.frame.maxY + 8
        closePollButton.frame.origin.y = footerLabel.frame.maxY + 4
        
        // Force visual refresh so Firebase-triggered updates display immediately
        messageContainerView.setNeedsLayout()
        messageContainerView.layoutIfNeeded()
        messageContainerView.setNeedsDisplay()
    }
    
    // MARK: - Touch Handling
    
    /// Override MessageKit's tap gesture handler to intercept taps on option buttons.
    /// The gesture recognizer consumes touches before UIButton can process them,
    /// so we check the hit area and invoke button actions manually.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: messageContainerView)
        
        // Check if tap is on any option selector button
        for subview in optionsStackView.arrangedSubviews {
            guard let rowStack = subview as? UIStackView else { continue }
            // The first arranged subview of each row is a horizontal headerStack
            guard let headerStack = rowStack.arrangedSubviews.first as? UIStackView else { continue }
            // The first element of headerStack is the selector button
            guard let selectorBtn = headerStack.arrangedSubviews.first as? UIButton else { continue }
            
            let btnFrame = selectorBtn.convert(selectorBtn.bounds, to: messageContainerView)
            // Expand the hit area to include the full row for easier tapping
            let rowFrame = rowStack.convert(rowStack.bounds, to: messageContainerView)
            let expandedFrame = CGRect(x: rowFrame.origin.x, y: rowFrame.origin.y, width: rowFrame.width, height: rowFrame.height)
            
            if expandedFrame.contains(touchLocation) && selectorBtn.isEnabled {
                optionTapped(selectorBtn)
                return
            }
        }
        
        // Check close poll button
        if !closePollButton.isHidden {
            let closeFrame = closePollButton.convert(closePollButton.bounds, to: messageContainerView)
            if closeFrame.contains(touchLocation) {
                closePollButton.sendActions(for: .touchUpInside)
                return
            }
        }
        
        // Not on a button — let MessageKit handle normally (fires didTapMessage)
        super.handleTapGesture(gesture)
    }
    
    // MARK: - Actions
    
    @objc private func optionTapped(_ sender: UIButton) {
        guard let pollId = currentPollId else { return }
        pollDelegate?.pollCell(self, didVoteForOption: sender.tag, pollId: pollId)
    }
}
