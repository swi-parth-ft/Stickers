//
//  LinkMetadataFetcher.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-18.
//

import LinkPresentation
import UIKit

class LinkMetadataCache {
    static let shared = LinkMetadataCache()
    private var cache = NSCache<NSURL, LPLinkMetadata>()

    private init() {}

    func getMetadata(for url: URL) -> LPLinkMetadata? {
        return cache.object(forKey: url as NSURL)
    }

    func setMetadata(_ metadata: LPLinkMetadata, for url: URL) {
        cache.setObject(metadata, forKey: url as NSURL)
    }
}

struct LinkMetadataFetcher {
    static func fetchMetadata(for url: URL, completion: @escaping (LPLinkMetadata?) -> Void) {
        // Check cache first
        if let cachedMetadata = LinkMetadataCache.shared.getMetadata(for: url) {
            completion(cachedMetadata)
            return
        }

        // Fetch metadata if not cached
        let metadataProvider = LPMetadataProvider()
        metadataProvider.startFetchingMetadata(for: url) { metadata, error in
            if let error = error {
                print("Error fetching metadata: \(error.localizedDescription)")
                completion(nil)
            } else if let metadata = metadata {
                // Cache the metadata
                LinkMetadataCache.shared.setMetadata(metadata, for: url)
                completion(metadata)
            }
        }
    }
}
