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
                            expect(diffHistogram) == [
                                152_193, 157_017, 159_319, 0,
                                7_807, 2_983, 6_81
                            ]
                            + .init(repeating: 0, count: 64 * 4 - 8)
                            + [160_000]
                            let sum = diffHistogram.reduce(.zero, +)
                            expect(sum) == 400 * 400 * 4
                        }
                    }
                }
            }
        }
    }
}
