import Foundation
import SwiftUI
import SkinSmoothingFilter
import PhotosUI

@available(iOS 16.0, *)
struct ContentView: View {

  @State private var selectedPhotoItem: PhotosPickerItem? = nil
  @State var originalImage: Image? = nil
  @State var edittedImage: Image? = nil

  var body: some View {
    NavigationView {
      ScrollView {
        VStack {

          if let originalImage {
            originalImage
              .resizable()
              .scaledToFit()
          }

          if let edittedImage {
            edittedImage
              .resizable()
              .scaledToFit()
          }

        }
        .onChange(of: selectedPhotoItem) { selectedPhotoItem in
          Task {
            do {
              if let data = try await selectedPhotoItem?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                  originalImage = .init(uiImage: uiImage)

                  let ciImage = CIImage(image: uiImage)!

                  let filter = SkinSmoothingFilter()
                  filter.inputImage = ciImage

                  if let result = filter.outputImage?.toUIImage() {
                    edittedImage = .init(uiImage: result)
                  }
                }
              }
            } catch {
              print(error)
            }
          }
        }
      }
      .navigationTitle("SkinSmoothingFilter Demo")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            Image(systemName: "photo")
          }
        }
      }
    }
  }
}

extension CIImage {
  func toCGImage() -> CGImage? {
    let context = { CIContext(options: nil) }()
    return context.createCGImage(self, from: self.extent)
  }

  func toUIImage() -> UIImage? {
    guard let cgImage = self.toCGImage() else { return nil }
    return UIImage(cgImage: cgImage)
  }
}

#Preview {
  if #available(iOS 16.0, *) {
    ContentView()
  } else {
    EmptyView()
  }
}
