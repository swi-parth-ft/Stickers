//
//  ImageCache.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-27.
//

import Foundation
import UIKit


class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}
