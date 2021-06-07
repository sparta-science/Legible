import Nimble
import Quick
@testable import Legible

class ImageCompareSpec: QuickSpec {
    override func spec() {
        describe("significantlyDifferentImages") {
            var data1: Data!
            var data2: Data!
            beforeEach {
                let bundle = Bundle(for: Self.self)
                let image1Url = bundle.urlForImageResource("AvatarView-1.png")!
                data1 = try! Data(contentsOf: image1Url)

                let image2Url = bundle.urlForImageResource("AvatarView-2.png")!
                data2 = try! Data(contentsOf: image2Url)
            }
            context("data") {
                it("should be different") {
                    expect(data1) != data2
                }
            }

            context("CGImage") {
                var cgImage1: CGImage!
                var cgImage2: CGImage!
                beforeEach {
                    cgImage1 = NSBitmapImageRep(data: data1)!.cgImage!
                    cgImage2 = NSBitmapImageRep(data: data2)!.cgImage!
                }
                context("significantlyDifferentImages") {
                    it("should be false") {
                        expect(significantlyDifferentImages(data1, cgImage2)) == false
                    }
                }
                context("diff") {
                    context("histogram") {
                        it("should be mostly zeros") {
                            let difference = diff(cgImage1, cgImage2)
                            let diffHistogram = histogram(ciImage: difference.outputImage!)
                            let totalPixels = cgImage1.height * cgImage1.width
                            let ratioHistogram = diffHistogram.map {
                                Double($0) / Double(totalPixels)
                            }
                            expect(ratioHistogram) ≈ [
                                0.9512, 0.9814, 0.9957, 0,
                                0.0488, 0.0186, 0.0043
                            ] + .init(repeating: 0.0, count: 64 * 4 - 8)
                            + [1.0]
                            let sum = diffHistogram.reduce(.zero, +)
                            expect(sum) == UInt32(totalPixels) * 4
                        }
                    }
                }
            }
        }
    }
}
