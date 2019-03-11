//
//  CustomImageView.swift
//  SearchTweetsMVC
//
//  Created by Shibili Areekara on 06/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

class  CustomImageView: UIImageView {
    
    var imageUrlString: String?
    
    /// Load image from url String
    func loadImageFromUrl(urlString: String) {
        
        imageUrlString = urlString
        image = nil
        
        guard let url: URL = URL(string: urlString) else { return }
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            self.roundedCorners()
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, _, error) in
            if error != nil {
                print("ImageDownload Error : \(error?.localizedDescription ?? "")")
                return
            }
            DispatchQueue.main.async {
                if let imageToCache = UIImage(data: data!) {
                    
                    if self?.imageUrlString == urlString {
                        self?.image = imageToCache
                    }
                    imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
                    self?.roundedCorners()
                }
            }
        }).resume()
    }
}

private extension UIView {
    func roundedCorners(cRadius: CGFloat = 5.0) {
        self.layer.cornerRadius = cRadius
        layer.masksToBounds = true
    }
}
