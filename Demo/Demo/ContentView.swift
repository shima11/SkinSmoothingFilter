import Foundation
import SwiftUI
import SkinSmoothingFilter

struct ContentView: View {

  @State var edittedImage: Image? = nil

  var body: some View {
    ScrollView {
      VStack {
        Image("sample1")
          .resizable()
          .scaledToFit()
        if let edittedImage {
          edittedImage
            .resizable()
            .scaledToFit()
        }

        Button("Apply") {
          guard
            let image = UIImage(named: "sample1"),
            let ciImage = CIImage(image: image)
          else { return }
          let filter = SkinSmoothingFilter()
          filter.inputImage = ciImage

          if let result = filter.outputImage?.toUIImage() {
            edittedImage = .init(uiImage: result)
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
  ContentView()
}
