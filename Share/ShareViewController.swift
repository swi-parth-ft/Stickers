import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure access to extensionItem and itemProvider
        guard
            let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else {
            close()
            return
        }
        
        // Check for supported types: text, image, and URL
        let textDataType = UTType.plainText.identifier
        let imageDataType = UTType.image.identifier
        let urlDataType = UTType.url.identifier
        
        // Handle text, image, and URL data types
        if itemProvider.hasItemConformingToTypeIdentifier(textDataType) {
            itemProvider.loadItem(forTypeIdentifier: textDataType, options: nil) { (providedText, error) in
                if error != nil {
                    self.close()
                    return
                }
                
                if let text = providedText as? String {
                    DispatchQueue.main.async {
                        let contentView = UIHostingController(rootView: ShareExtensionView(text: text, image: nil, url: nil))
                        self.addChild(contentView)
                        self.view.addSubview(contentView.view)
                        self.setupConstraints(for: contentView)
                    }
                } else {
                    self.close()
                }
            }
        }   else if itemProvider.hasItemConformingToTypeIdentifier(imageDataType) {
            itemProvider.loadItem(forTypeIdentifier: imageDataType, options: nil) { (providedImage, error) in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    self.close()
                    return
                }

                if let secureCodingObject = providedImage as? NSSecureCoding {
                    print("Received image type: \(type(of: secureCodingObject))")
                    
                    if let image = secureCodingObject as? UIImage {
                        DispatchQueue.main.async {
                            let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 300, height: 300))
                            let contentView = UIHostingController(rootView: ShareExtensionView(text: "", image: resizedImage, url: nil))
                            self.addChild(contentView)
                            self.view.addSubview(contentView.view)
                            self.setupConstraints(for: contentView)
                        }
                    }
                    else if let imageData = secureCodingObject as? Data {
                        if let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 300, height: 300))
                                let contentView = UIHostingController(rootView: ShareExtensionView(text: "", image: resizedImage, url: nil))
                                self.addChild(contentView)
                                self.view.addSubview(contentView.view)
                                self.setupConstraints(for: contentView)
                            }
                        }
                    }
                    else if let imageURL = secureCodingObject as? URL {
                        do {
                            let imageData = try Data(contentsOf: imageURL)
                            if let image = UIImage(data: imageData) {
                                DispatchQueue.main.async {
                                    let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 300, height: 300))
                                    let contentView = UIHostingController(rootView: ShareExtensionView(text: "", image: resizedImage, url: nil))
                                    self.addChild(contentView)
                                    self.view.addSubview(contentView.view)
                                    self.setupConstraints(for: contentView)
                                }
                            }
                        } catch {
                            print("Error loading image from URL: \(error)")
                            self.close()
                        }
                    }
                }
            }
        }
         else if itemProvider.hasItemConformingToTypeIdentifier(urlDataType) {
            itemProvider.loadItem(forTypeIdentifier: urlDataType, options: nil) { (providedURL, error) in
                if error != nil {
                    self.close()
                    return
                }
                
                if let url = providedURL as? URL {
                    DispatchQueue.main.async {
                        let contentView = UIHostingController(rootView: ShareExtensionView(text: "", image: nil, url: url))
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
    
    func setupConstraints(for contentView: UIHostingController<ShareExtensionView>) {
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    }
    
    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    // Resize image before using it
    
}
