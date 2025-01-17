
#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;

[[stitchable]] float4 highpass(coreimage::sample_t image, coreimage::sample_t blurredImage) {
  return float4(float3(image.rgb - blurredImage.rgb) + 0.5, image.a);
}

float overlayBlend(float base, float blend) {
  return base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend));
}

[[stitchable]] float4 greenBlueOverlayBlendKernel(coreimage::sample_t image) {

  float green = image.g;
  float blue = image.b;

  float blendedGreen = overlayBlend(green, green);
  float blendedBlue = overlayBlend(blue, blue);

  return float4(0, blendedGreen, blendedBlue, image.a);
}
