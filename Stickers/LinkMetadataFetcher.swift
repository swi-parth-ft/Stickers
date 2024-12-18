//
//  LinkMetadataFetcher.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-18.
//


import LinkPresentation
import UIKit

struct LinkMetadataFetcher {
    static func fetchMetadata(for url: URL, completion: @escaping (LPLinkMetadata?) -> Void) {
        let metadataProvider = LPMetadataProvider()
        metadataProvider.startFetchingMetadata(for: url) { metadata, error in
            if let error = error {
                print("Error fetching metadata: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(metadata)
            }
        }
    }
}