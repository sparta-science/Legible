import XCTest
@testable import Legible

/**
 Compare performance of image comparison
 using CoreImage vs vImage frameworks

 on iMacPro
 for preloaded images
 performance of CoreImage is 4 times faster (0.0015753 vs 0.0060786)

 including image load
 performance of CoreImage is 1.5 times slower (0.018587 vs 0.011776)
 */
class PerformanceTest: XCTestCase {
    let bundle = Bundle(for: PerformanceTest.self)
    var image1Url: URL!
    var image2Url: URL!

    override func setUpWithError() throws {
        image1Url = bundle.urlForImageResource("AvatarView-1.png")!
        image2Url = bundle.urlForImageResource("AvatarView-2.png")!
    }

    func test_CoreImage_AndLoad_Performance() throws {
        measure {
            let image1 = CIImage(contentsOf: image1Url)!
            let image2 = CIImage(contentsOf: image2Url)!
            let diffOperation = diff(image1, image2)
            let diffOutput = diffOperation.outputImage!
            _ = maxColorDiff(histogram: histogram(ciImage: diffOutput))
        }
    }

    func test_CoreImage_Performance() throws {
        let image1 = CIImage(contentsOf: image1Url)!
        let image2 = CIImage(contentsOf: image2Url)!
        let diffOperation = diff(image1, image2)
        let diffOutput = diffOperation.outputImage!
        let diff = maxColorDiff(histogram: histogram(ciImage: diffOutput))
        XCTAssertEqual(0.015625, diff)

        measure {
            _ = maxColorDiff(histogram: histogram(ciImage: diffOutput))
        }
    }

    func test_vImage_Buffer_Performance() throws {
        let data1 = try! Data(contentsOf: image1Url)
        let data2 = try! Data(contentsOf: image2Url)
        let cgImage2 = NSBitmapImageRep(data: data2)!.cgImage!

        XCTAssertNotEqual(data1, data2, "different files")
        XCTAssertFalse(significantlyDifferentImages(data1, cgImage2),
                       "close enough images")

        measure {
            _ = significantlyDifferentImages(data1, cgImage2)
        }
    }

    func test_vImage_Buffer_AndLoad_Performance() throws {
        measure {
            let data1 = try! Data(contentsOf: image1Url)
            let data2 = try! Data(contentsOf: image2Url)
            let cgImage2 = NSBitmapImageRep(data: data2)!.cgImage!
            _ = significantlyDifferentImages(data1, cgImage2)
        }
    }
}
