import Foundation
import SwiftUI
import SkinSmoothingFilter
import PhotosUI

@available(iOS 16.0, *)
struct ContentView: View {

  @State var selectedPhotoItem: PhotosPickerItem? = nil
  @State var originalImage: UIImage? = nil
  @State var inputAmount: Double = 0.5
  @State var inputSharpness: Double = 0.3
  @State var inputRadius: Double = 8.0
  @State var edittedImage: Image? = nil

  var body: some View {
    NavigationView {
      ScrollView {
        VStack {

          if let originalImage = originalImage {
            Image(uiImage: originalImage)
              .resizable()
              .scaledToFit()
          }

          if let edittedImage = edittedImage {
            edittedImage
              .resizable()
              .scaledToFit()
          }

          VStack {
            Text("amount: \(inputAmount)")
            Slider(value: $inputAmount, in: 0...1, step: 0.1)
            Text("sharpness: \(inputSharpness)")
            Slider(value: $inputSharpness, in: 0...1, step: 0.1)
            Text("radius: \(inputRadius)")
            Slider(value: $inputRadius, in: 0...40, step: 1)
          }
          .padding(.top, 24)
          .padding(.horizontal, 24)

        }
        .onChange(of: originalImage, perform: { _ in
          perform()
        })
        .onChange(of: [inputAmount, inputSharpness, inputRadius], perform: { _ in
          perform()
        })
        .onChange(of: selectedPhotoItem) { selectedPhotoItem in
          Task {
            do {
              if let data = try await selectedPhotoItem?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                  originalImage = uiImage
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

  private func perform() {
    guard let uiImage = originalImage else { return }
    let ciImage = CIImage(image: uiImage)!

    let filter = SkinSmoothingFilter()
    filter.inputImage = ciImage
    filter.inputAmount = inputAmount
    filter.inputSharpness = inputSharpness
    filter.inputRadius = inputRadius

    if let result = filter.outputImage?.toUIImage() {
      edittedImage = .init(uiImage: result)
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
