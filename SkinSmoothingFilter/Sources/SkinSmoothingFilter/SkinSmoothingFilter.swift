import Foundation
import CoreImage

public final class SkinSmoothingFilter: CIFilter {

  public var inputImage: CIImage?
  public var inputAmount: Double = 0.5
  public var inputSharpness: Double = 0.3
  public var inputRadius: Double = 8.0

  override public var outputImage: CIImage? {
    guard let inputImage = self.inputImage else { return nil }

    let colorFilter = ColorOverlayBlendFilter()
    colorFilter.inputImage = inputImage

    let highpassFilter = HighpassFilter()
    highpassFilter.inputImage = colorFilter.outputImage
    highpassFilter.inputAmount = inputRadius

    let hardLightBlendFilter1 = CIFilter(name: "CIHardLightBlendMode")!
    hardLightBlendFilter1.setValue(highpassFilter.outputImage, forKey: kCIInputImageKey)
    hardLightBlendFilter1.setValue(highpassFilter.outputImage, forKey: kCIInputBackgroundImageKey)

    let hardLightBlendFilter2 = CIFilter(name: "CIHardLightBlendMode")!
    hardLightBlendFilter2.setValue(hardLightBlendFilter1.outputImage, forKey: kCIInputImageKey)
    hardLightBlendFilter2.setValue(hardLightBlendFilter1.outputImage, forKey: kCIInputBackgroundImageKey)

    let hardLightBlendFilter3 = CIFilter(name: "CIHardLightBlendMode")!
    hardLightBlendFilter3.setValue(hardLightBlendFilter2.outputImage, forKey: kCIInputImageKey)
    hardLightBlendFilter3.setValue(hardLightBlendFilter2.outputImage, forKey: kCIInputBackgroundImageKey)

    let toneFilter = CIFilter(name: "CIToneCurve")!
    toneFilter.setValue(inputImage, forKey: kCIInputImageKey)
    toneFilter.setValue(CIVector(x: 0.0,  y: 0), forKey: "inputPoint0")
    //              toneFilter.setValue(CIVector(x: 0.25, y: ), forKey: "inputPoint1")
    toneFilter.setValue(CIVector(x: 120/255.0,  y: 146/255.0), forKey: "inputPoint1")
    //              toneFilter.setValue(CIVector(x: 0.75, y: ), forKey: "inputPoint3")
    toneFilter.setValue(CIVector(x: 1.0,  y: 1.0), forKey: "inputPoint2")

    let blendWithMaskFilter = CIFilter(name: "CIBlendWithMask")!
    blendWithMaskFilter.setValue(inputImage, forKey: kCIInputImageKey)
    blendWithMaskFilter.setValue(toneFilter.outputImage, forKey: kCIInputBackgroundImageKey)
    blendWithMaskFilter.setValue(hardLightBlendFilter3.outputImage, forKey: kCIInputMaskImageKey)

    let sharpenFilter = CIFilter(name: "CISharpenLuminance")!
    sharpenFilter.setValue(inputSharpness*inputAmount, forKey: kCIInputSharpnessKey)
    sharpenFilter.setValue(blendWithMaskFilter.outputImage, forKey: kCIInputImageKey)

    return sharpenFilter.outputImage
  }
}

final class ColorOverlayBlendFilter: CIFilter {

  var inputImage: CIImage?

  static var kernel: CIKernel = { () -> CIKernel in

    let url = Bundle.module.url(
      forResource: "default",
      withExtension: "metallib"
    )!

    let data = try! Data(contentsOf: url)
    let kernel = try! CIColorKernel(
      functionName: "greenBlueOverlayBlendKernel",
      fromMetalLibraryData: data
    )
    return kernel
  }()

  override var outputImage : CIImage? {
    guard let input = inputImage else {
      return nil
    }

    let ciImage = Self.kernel.apply(
      extent: input.extent,
      roiCallback: { index, rect in
        return rect
      },
      arguments: [input]
    )
    return ciImage
  }
}

final class HighpassFilter: CIFilter {
  var inputImage: CIImage?
  var blurInputImage: CIImage?
  var inputAmount: Double = 5.0

  override public var outputImage: CIImage? {
    guard let inputImage = self.inputImage else {
      return nil
    }
    let blurInputImage = self.blurInputImage ?? makeBluredImage(from: inputImage)
    guard let highpassKernel = HighpassFilter.kernel else {
      return nil
    }
    return highpassKernel.apply(extent: inputImage.extent, arguments: [inputImage, blurInputImage])
  }

  private func makeBluredImage(from inputImage: CIImage) -> CIImage {
    return inputImage.clampedToExtent().applyingGaussianBlur(sigma: inputAmount).cropped(to: inputImage.extent)
  }

  private static var kernel: CIColorKernel? {
    guard let url = Bundle.module.url(forResource: "default", withExtension: "metallib") else { return nil }
    guard let data = try? Data(contentsOf: url) else { return nil }
    return try? CIColorKernel(functionName: "highpass", fromMetalLibraryData: data)
  }
}
