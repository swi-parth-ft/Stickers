import SwiftUI
import UniformTypeIdentifiers


struct ShareExtensionView: View {
    @State private var text: String
    @State private var image: UIImage?
    @State private var url: URL?
    @StateObject private var manager = SharedItemManager()
    
    init(text: String, image: UIImage?, url: URL?) {
        _text = State(initialValue: text)
        _image = State(initialValue: image)
        _url = State(initialValue: url)
    }
    
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding()
                } else if let url = url {
                    Link("Open Link", destination: url)
                        .padding()
                } else {
                    TextField("Text", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                
                Button {
                    if let image = image {
                        if let imageData = image.pngData() {
                            let imageContent = SharedContent.image(imageData)
                            manager.saveItem(content: imageContent)
                        }
                        
                    } else if let url = url {
                        let urlContent = SharedContent.url(url)
                        manager.saveItem(content: urlContent)
                    } else {
                        let textContent = SharedContent.text(text)
                        manager.saveItem(content: textContent)
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
