
#include <metal_stdlib>
#include <CoreImage/CoreImage.h>

using namespace metal;

//extern "C" { namespace coreimage {
//
//  float4 highpass(sample_t image, sample_t blurredImage) {
//    return float4(float3(image.rgb - blurredImage.rgb) + 0.5, image.a);
//  }
//
//  float overlayBlend(float base, float blend) {
//    return base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend));
//  }
//
//  float4 greenBlueOverlayBlendKernel(sample_t image) {
//
//    float green = image.g;
//    float blue = image.b;
//
//    float blendedGreen = overlayBlend(green, green);
//    float blendedBlue = overlayBlend(blue, blue);
//
//    return float4(0, blendedGreen, blendedBlue, image.a);
//  }
//
//}}

kernel void highpass(texture2d<float, access::sample> image [[texture(0)]],
                     texture2d<float, access::sample> blurredImage [[texture(1)]],
                     texture2d<float, access::write> output [[texture(2)]],
                     uint2 gid [[thread_position_in_grid]])
{
  constexpr sampler imgSampler(coord::normalized, address::clamp_to_edge, filter::linear);

  float2 uv = float2(gid) / float2(output.get_width(), output.get_height());
  float4 imgColor = image.sample(imgSampler, uv);
  float4 blurredColor = blurredImage.sample(imgSampler, uv);

  float4 highpassResult = float4(float3(imgColor.rgb - blurredColor.rgb) + 0.5, imgColor.a);

  output.write(highpassResult, gid);
}

// オーバーレイブレンド関数の定義
float overlayBlend(float base, float blend) {
  return base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend));
}

// カーネル関数の定義
kernel void greenBlueOverlayBlendKernel(texture2d<float, access::sample> inputTexture [[texture(0)]],
                                        texture2d<float, access::write> outputTexture [[texture(1)]],
                                        uint2 gid [[thread_position_in_grid]]) {
  // サンプラーの定義（リニアフィルタリングとクランプトゥエッジを使用）
  constexpr sampler textureSampler(coord::normalized, address::clamp_to_edge, filter::linear);

  // 入力テクスチャからピクセルをサンプリング
  const float2 uv = float2(gid) / float2(outputTexture.get_width(), outputTexture.get_height());
  float4 pixelColor = inputTexture.sample(textureSampler, uv);

  // 緑と青のチャンネルにオーバーレイブレンドを適用
  float blendedGreen = overlayBlend(pixelColor.g, pixelColor.g);
  float blendedBlue = overlayBlend(pixelColor.b, pixelColor.b);

  // 出力ピクセルの設定（赤は変更せず、緑と青はブレンド後の値を使用）
  float4 outputColor = float4(pixelColor.r, blendedGreen, blendedBlue, pixelColor.a);

  // 出力テクスチャに書き込み
  outputTexture.write(outputColor, gid);
}
