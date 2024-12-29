import SwiftUI
import UIKit
import UniformTypeIdentifiers
import ImageIO

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else {
            close()
            return
        }
        
        let textDataType = UTType.plainText.identifier
        let imageDataType = UTType.image.identifier
        let urlDataType = UTType.url.identifier
        
        if itemProvider.hasItemConformingToTypeIdentifier(textDataType) {
            itemProvider.loadItem(forTypeIdentifier: textDataType, options: nil) { (providedText, error) in
                if error != nil {
                    self.close()
                    return
                }
                
                if let text = providedText as? String {
                    DispatchQueue.main.async {
                        let contentView = UIHostingController(rootView: ShareExtensionView(text: text, imageFileURL: nil, url: nil))
                        self.addChild(contentView)
                        self.view.addSubview(contentView.view)
                        self.setupConstraints(for: contentView)
                    }
                } else {
                    self.close()
                }
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier(imageDataType) {
            itemProvider.loadItem(forTypeIdentifier: imageDataType, options: nil) { (providedImage, error) in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    self.close()
                    return
                }
                
                if let secureCodingObject = providedImage as? NSSecureCoding {
                    if let imageURL = secureCodingObject as? URL {
                        DispatchQueue.main.async {
                            self.processImage(at: imageURL)
                        }
                    }
                }
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier(urlDataType) {
            itemProvider.loadItem(forTypeIdentifier: urlDataType, options: nil) { (providedURL, error) in
                if error != nil {
                    self.close()
                    return
                }
                
                if let url = providedURL as? URL {
                    DispatchQueue.main.async {
                        let contentView = UIHostingController(rootView: ShareExtensionView(text: "", imageFileURL: nil, url: url))
                        self.addChild(contentView)
                        self.view.addSubview(contentView.view)
                        self.setupConstraints(for: contentView)
                    }
                } else {
                    self.close()
                }
            }
        } else {
            close()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.close()
            }
        }
    }
    
    private func processImage(at url: URL) {
        let fileName = UUID().uuidString + ".jpg"
        let savedPaths = saveImageWithThumbnailFromFile(at: url, fileName: fileName)
        
        if let fullImageURL = savedPaths.fullImageURL {
            print("Full image saved at: \(fullImageURL)")
        }
        
        if let thumbnailURL = savedPaths.thumbnailURL {
            print("Thumbnail saved at: \(thumbnailURL)")
        }
        
        let contentView = UIHostingController(rootView: ShareExtensionView(text: "", imageFileURL: savedPaths.fullImageURL, url: nil))
        self.addChild(contentView)
        self.view.addSubview(contentView.view)
        self.setupConstraints(for: contentView)
    }
    
    func saveImageWithThumbnailFromFile(at url: URL, fileName: String) -> (fullImageURL: URL?, thumbnailURL: URL?) {
        let fileManager = FileManager.default
        guard let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.parthant.Stickers") else {
            print("Error accessing shared container")
            return (nil, nil)
        }

        let fullImageURL = containerURL.appendingPathComponent(fileName)
        let thumbnailURL = containerURL.appendingPathComponent("thumbnail_\(fileName)")
        
        do {
            try fileManager.copyItem(at: url, to: fullImageURL) // Save the full image directly
            
            // Generate thumbnail without loading the entire image
            if let thumbnail = generateThumbnail(from: url, targetSize: CGSize(width: 300, height: 300)) {
                let thumbnailData = thumbnail.jpegData(compressionQuality: 1.0)
                try thumbnailData?.write(to: thumbnailURL)
            }
            
            return (fullImageURL, thumbnailURL)
        } catch {
            print("Error saving image to disk: \(error)")
            return (nil, nil)
        }
    }

    func generateThumbnail(from url: URL, targetSize: CGSize) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            print("Failed to create CGImageSource")
            return nil
        }
        
        // Set thumbnail generation options
        let options: [NSString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(targetSize.width, targetSize.height),
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            print("Failed to generate thumbnail")
            return nil
        }
        
        // Normalize the image orientation
        let originalImage = UIImage(cgImage: cgImage)
        return normalizeOrientation(for: originalImage)
    }

    // Helper function to normalize image orientation
    private func normalizeOrientation(for image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else {
            return image // No need to normalize if orientation is already correct
        }

        return UIGraphicsImageRenderer(size: image.size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    func setupConstraints(for contentView: UIHostingController<ShareExtensionView>) {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
