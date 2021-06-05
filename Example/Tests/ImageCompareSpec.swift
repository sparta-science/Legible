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

            context("significantlyDifferentImages") {
                it("should be false") {
                    let cgImage2 = NSBitmapImageRep(data: data2)!.cgImage!
                    expect(significantlyDifferentImages(data1, cgImage2)) == false
                }
            }
        }
    }
}
