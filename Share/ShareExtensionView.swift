import SwiftUI
import Vision
import CoreML

struct ShareExtensionView: View {
    @State private var text: String
    @State private var imageFileURL: URL?
    @State private var url: URL?
    @StateObject private var manager = SharedItemManager()
    @State private var caption: String = ""
    @State private var imageCategory: String?
    @State private var newCategory: String = "" // To store the new category input

    
    init(text: String, imageFileURL: URL?, url: URL?) {
        _text = State(initialValue: text)
        _imageFileURL = State(initialValue: imageFileURL)
        _url = State(initialValue: url)
    }
    
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
    
    func classifyImage(_ image: UIImage) {
        // Resize the image to reduce memory usage
        guard let resizedImage = resizeImage(image, targetSize: CGSize(width: 224, height: 224)),
              let ciImage = CIImage(image: resizedImage) else {
            print("Unable to create CIImage or resize image.")
            return
        }
        
        let request = VNClassifyImageRequest { request, error in
            if let results = request.results as? [VNClassificationObservation], !results.isEmpty {
                let topResult = results.first!
                DispatchQueue.main.async {
                    self.imageCategory = "\(topResult.identifier) (\(Int(topResult.confidence * 100))%)"
                    print("Category: \(topResult.identifier), Confidence: \(Int(topResult.confidence * 100))%")
                    if topResult.identifier == "document" {
                        self.imageCategory = "Screenshots"
                        manager.selectedCategory = "Screenshots"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.imageCategory = "Unknown"
                    print("Unable to classify image.")
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform Vision request: \(error.localizedDescription)")
            }
        }
    }

    // Helper function to resize the image
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let imageFileURL = imageFileURL, let image = UIImage(contentsOfFile: imageFileURL.path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding()
                        .onAppear {
                            classifyImage(image)
                        }
                    
                    TextField("Caption", text: $caption)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                } else if let url = url {
                    Link("Open Link", destination: url)
                        .padding()
                    
                    TextField("Caption", text: $caption)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                } else {
                    TextField("Text", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    TextField("Caption", text: $caption)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                Picker("Select Category", selection: $manager.selectedCategory) {
                                    ForEach(manager.categories, id: \.self) { category in
                                        Text(category).tag(category as String?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()

                                // Add New Category
                                HStack {
                                    TextField("New Category", text: $newCategory)
                                        .textFieldStyle(.roundedBorder)

                                    Button("Add") {
                                        if !newCategory.isEmpty {
                                            manager.addCategory(newCategory)
                                            manager.selectedCategory = newCategory
                                            newCategory = ""
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .padding()
                Button {
                    if let imageFileURL = imageFileURL {
                        let imageContent = SharedContent.imageURL(imageFileURL)
                        manager.saveItem(content: imageContent, caption: caption)
                    } else if let url = url {
                        let urlContent = SharedContent.url(url)
                        manager.saveItem(content: urlContent, caption: caption)
                    } else {
                        let textContent = SharedContent.text(text)
                        manager.saveItem(content: textContent, caption: caption)
                    }
                    close()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share Extension")
            .toolbar {
                Button("Cancel") {
                    close()
                }
            }
        }
    }
}
