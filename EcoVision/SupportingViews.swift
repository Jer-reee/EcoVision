//
//  SupportingViews.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI
import PhotosUI
import AVFoundation

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Waste Category View

struct WasteCategoryView: View {
    let title: String
    let imageName: String
    let color: Color
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: min(geometry.size.height * 0.02, 16)) {
            Text(title)
                .font(.system(size: min(geometry.size.width * 0.035, 15), weight: .medium))
                .foregroundColor(Color.brandVeryDarkBlue)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: min(geometry.size.width * 0.18, 80), height: min(geometry.size.width * 0.18, 80))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brandWhite)
        .padding(.vertical, min(geometry.size.height * 0.025, 20))
    }
}

// MARK: - Navigation Tab View

struct NavigationTabView: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? Color.brandSkyBlue : Color.brandMutedBlue)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? Color.brandSkyBlue : Color.brandMutedBlue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                isSelected ? 
                Color.brandVeryDarkBlue.opacity(0.1) : 
                Color.clear
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Floating Back Button

struct FloatingBackButton: View {
    let action: () -> Void
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                        Text("Back")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.brandSkyBlue)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                }
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isVisible)
                
                Spacer()
            }
            .padding(.bottom, 30)
        }
        .allowsHitTesting(isVisible)
    }
}

// MARK: - Scrollable View with Floating Back Button

struct ScrollableViewWithFloatingBack<Content: View>: View {
    let content: Content
    let backAction: () -> Void
    @State private var scrollOffset: CGFloat = 0
    @State private var lastScrollOffset: CGFloat = 0
    @State private var isFloatingButtonVisible = false
    
    init(backAction: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.backAction = backAction
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                    }
                    .frame(height: 0)
                    
                    content
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
                updateFloatingButtonVisibility()
            }
            
            FloatingBackButton(action: backAction, isVisible: $isFloatingButtonVisible)
        }
    }
    
    private func updateFloatingButtonVisibility() {
        // For now, always show the button to test
        let shouldShow = true
        
        print("🔍 Scroll offset: \(scrollOffset), shouldShow: \(shouldShow), isVisible: \(isFloatingButtonVisible)")
        
        if shouldShow != isFloatingButtonVisible {
            print("🔄 Updating button visibility to: \(shouldShow)")
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isFloatingButtonVisible = shouldShow
            }
        }
        
        lastScrollOffset = scrollOffset
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
