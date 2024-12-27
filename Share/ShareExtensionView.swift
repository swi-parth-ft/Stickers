import SwiftUI

struct ShareExtensionView: View {
    @State private var text: String
    @State private var imageFileURL: URL?
    @State private var url: URL?
    @StateObject private var manager = SharedItemManager()
    @State private var caption: String = ""
    
    init(text: String, imageFileURL: URL?, url: URL?) {
        _text = State(initialValue: text)
        _imageFileURL = State(initialValue: imageFileURL)
        _url = State(initialValue: url)
    }
    
    func close() {
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
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
