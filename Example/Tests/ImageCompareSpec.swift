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
                    var diffHistogram: [UInt32]!
                    beforeEach {
                        let difference = diff(cgImage1, cgImage2)
                        diffHistogram = histogram(ciImage: difference.outputImage!)
                    }
                    context("histogram") {
                        var totalPixels: Int!
                        beforeEach {
                            totalPixels = cgImage1.height * cgImage1.width
                        }
                        it("sum should equal to number of pixels") {
                            let sum = diffHistogram.reduce(.zero, +)
                            expect(sum) == UInt32(totalPixels) * 4
                        }
                        it("should be mostly zeros") {
                            let ratioHistogram = diffHistogram.map {
                                Double($0) / Double(totalPixels)
                            }
                            expect(ratioHistogram).to(beCloseTo([
                                0.9512, 0.9814, 0.9957, 0,
                                0.0488, 0.0186, 0.0043
                            ] + .init(repeating: 0.0, count: 64 * 4 - 8)
                            + [1.0], within: 0.008)) // should be 0.001 <-- clarify why histogram on Monterey produce different results
                        }

                        context("maxColorDiff") {
                            it("should be 1.5%") {
                                expect(maxColorDiff(histogram: diffHistogram)) ≈ 0.0156
                            }
                        }
                    }
                }
            }
        }
    }
}
