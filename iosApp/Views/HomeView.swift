//
//  HomeView.swift
//  iosApp
//
//  Created by Varun Ananthakrishnan on 5/17/25.
//

import SwiftUI

struct HomeView: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var showDescription = false
    
    var body: some View {
        ScrollView {
            // Track scroll position
            GeometryReader { geometry in
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self,
                                      value: geometry.frame(in: .global).minY)
            }
            .frame(height: 0)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
                
                // Show description when scrolled down enough
                if value < -50 && !showDescription {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showDescription = true
                    }
                } else if value >= -50 && showDescription {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showDescription = false
                    }
                }
            }
            
            VStack(spacing: 20) {
                // Spacer to push content down initially
                Spacer().frame(height: 100)
                
                // Logo and title section with parallax effect
                GeometryReader { geometry in
                    let minY = geometry.frame(in: .global).minY
                    let scrollEffect = minY > 0 ? minY / 2 : 0
                    
                    VStack {
                        Image(systemName: "clock.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color("#6DD3B2"))
                            .padding(.top, 40 + scrollEffect)
                            .scaleEffect(1 + scrollEffect / 500)
                        
                        Text("Re: Me")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(Color("#6DD3B2"))
                            .padding(.top, 10)
                            .scaleEffect(1 + scrollEffect / 1000)
                        
                        Text("Your Personal Time Capsule")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                        
                        // Scroll indicator
                        VStack {
                            Text("Scroll down to see features")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color("#6DD3B2"))
                                .font(.system(size: 20))
                                .padding(.top, 5)
                                .opacity(0.8)
                        }
                        .padding(.bottom, 30)
                    }
                    .frame(width: geometry.size.width)
                }
                .frame(height: 350)
                
                // Description section with scroll-triggered animations
                VStack(alignment: .leading, spacing: 20) {
                    if showDescription {
                        Group {
                            descriptionSection(
                                icon: "book.fill",
                                title: "Journal Your Thoughts",
                                description: "Capture your daily experiences, thoughts, and feelings in a secure, private journal."
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            
                            descriptionSection(
                                icon: "message.fill",
                                title: "Chat with Your Past Self",
                                description: "Have meaningful conversations with an AI that understands your past entries and helps you reflect."
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .animation(.easeInOut.delay(0.1), value: showDescription)
                            
                            descriptionSection(
                                icon: "calendar",
                                title: "Time-Based Organization",
                                description: "Organize your memories by month and easily navigate through your personal history."
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .animation(.easeInOut.delay(0.2), value: showDescription)
                            
                            descriptionSection(
                                icon: "lock.fill",
                                title: "Private & Secure",
                                description: "Your memories stay on your device, ensuring your personal reflections remain private."
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .animation(.easeInOut.delay(0.3), value: showDescription)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Add extra space at the bottom to allow scrolling
                Spacer().frame(height: 300)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    // Helper function to create consistent description sections
    private func descriptionSection(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color("#6DD3B2"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Preference key to track scroll position
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
