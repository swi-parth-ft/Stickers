//
//  HomeView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-18.
//

import SwiftUI

struct HomeView: View {
    @StateObject var manager: SharedItemManager
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationStack {
            VStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(.black)
                    .frame(height: 120)
                    .shadow(color: .white.opacity(0.3), radius: 1, x: 0, y: 2)
                
                Spacer()
                
                VStack {
                    NavigationLink {
                        FoldersView(manager: manager)
                    } label: {
                        HStack {
                            Image(systemName: "folder")
                            Text("Folders")
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.gray.quinary)
                        .cornerRadius(22)
                        .padding(.horizontal)
                        
                    }
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(.gray.quinary)
                                .frame(height: 150)
                            
                            Image(.favFolderBG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                            
                            VStack {
                                Spacer()
                                
                                NavigationLink {
                                    
                                } label: {
                                    HStack {
                                        Text("Favorites")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                        
                                    }
                                    .padding()
                                    .foregroundStyle(.white)
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .background(.black)
                                    
                                }
                                
                                
                            }
                            .frame(height: 150)
                            .cornerRadius(22)
                            
                            
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(.gray.quinary)
                            
                                .frame(height: 150)
                            
                            Image(.priorityFolderBG)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                            
                            VStack {
                                Spacer()
                                
                                NavigationLink {
                                    
                                } label: {
                                    HStack {
                                        Text("Priority")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                        
                                    }
                                    .padding()
                                    .foregroundStyle(.white)
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .background(.black)
                                    
                                }
                            }
                            .frame(height: 150)
                            .cornerRadius(22)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Text("Upload")
                                .padding(10)
                                .foregroundColor(.primary)
                                .padding(.horizontal)

                            Spacer()
                            
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .padding(10)
                                .background(.gray)
                                .cornerRadius(22)
                                .padding(3)
                        }
                        .font(.title2)
                        .foregroundColor(.black)
                        .bold()
                        .overlay(
                            RoundedRectangle(cornerRadius: 22) // Adjust cornerRadius for shape
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4])) // Dashed line
                                .foregroundColor(.gray) // Line color
                        )
                        
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        List {
                            Section("Recently Saved") {
                                ForEach(manager.items.sorted(by: { $0.timestamp > $1.timestamp })) { item in
                                    HStack(alignment: .top, spacing: 10) {
                                        // Display an SF Symbol based on the content type
                                        Image(systemName: symbol(for: item))
                                            .font(.title2)
                                            .foregroundColor(.gray) // Adjust color if needed
                                        
                                        VStack(alignment: .leading) {
                                            if let caption = item.caption {
                                                Text(caption == "" ? "No caption" : caption)
                                                    .foregroundColor(.white)
                                            }
                                            Text(item.timestamp.formatted(date: .numeric, time: .omitted)) // For shortest date
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text(item.timestamp.formatted(date: .omitted, time: .shortened))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                    }
                                    .padding(10) // Padding within the row
                                    .listRowBackground(
                                        Color(red: 36 / 255, green: 36 / 255, blue: 36 / 255)                                              )
                                    
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // Rem
                                    
                                }
                            }
                            
                        }
                        .scrollContentBackground(.hidden)
                    }
                    .cornerRadius(22)

                    
                }
                
                Spacer()
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                manager.fetchItems() // Fetch items when the view appears
                print("Items count: \(manager.items.count)")
                print("First item caption: \(manager.items.first?.caption ?? "No Caption")")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Yellow John!")
                        .foregroundStyle(.white)
                        .font(.title2)
                        .bold()
                        .padding()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gear")
                            .foregroundStyle(.white)
                            .font(.title2)
                            .bold()
                            .padding()
                    }
                }
            }
        }
    }
    
    func symbol(for item: SharedItem) -> String {
        guard let content = item.decodedContent() else { return "questionmark.circle" }
        switch content {
        case .text:
            return "text.bubble" // Icon for text content
        case .imageURL:
            return "photo" // Icon for image content
        case .url:
            return "link" // Icon for URL content
        }
    }
}

#Preview {
    HomeView(manager: SharedItemManager())
}
