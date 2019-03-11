//
//  TweetTableViewCell.swift
//  SearchTweetsMVC
//
//  Created by Shibili Areekara on 02/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var handleAndCreatedAtLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetImageView: CustomImageView!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var tweetImageViewHeightConstraint: NSLayoutConstraint!
    private var defaultTweetImageViewHeightConstraint: CGFloat!
    
    var tweetViewModel: TweetViewModel? { didSet { updateUI() } }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView?.image = nil
        tweetImageView?.image = nil
        
        if tweetImageViewHeightConstraint != nil && defaultTweetImageViewHeightConstraint != nil {
            tweetImageViewHeightConstraint.constant = defaultTweetImageViewHeightConstraint
        }
    }
    
    private func updateUI() {
        
        tweetTextLabel?.text = tweetViewModel?.text ?? ""
        fullNameLabel?.text = tweetViewModel?.fullName ?? ""
        
        handleAndCreatedAtLabel?.text = tweetViewModel?.handleAndcreatedAt ?? ""
        
        retweetButton.setTitle(tweetViewModel?.retweetCount ?? " 0", for: .normal)
        likeButton.setTitle(tweetViewModel?.favoriteCount ?? " 0", for: .normal)
        
        if let profileImageURL = tweetViewModel?.profileImageUrl {
            self.profileImageView.loadImageFromUrl(urlString: profileImageURL)
        }

        if let mediaURL = tweetViewModel?.tweetImageUrl {
            self.tweetImageView.loadImageFromUrl(urlString: mediaURL)
        } else {
            self.updateForNoTweetImage()
        }
    }
    
    private func updateForNoTweetImage () {
        tweetImageView?.image = nil
        defaultTweetImageViewHeightConstraint = tweetImageViewHeightConstraint.constant
        tweetImageViewHeightConstraint.constant = 0
        layoutIfNeeded()
    }
}
