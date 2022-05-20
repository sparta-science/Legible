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
 
 on Macbook Pro
 3.5 faster (0.0021594 vs 0.0073569)
 with load 1.7 times slower (0.024396 vs 0.014482)
 */
class DiffPerformanceTest: XCTestCase {
    let bundle = Bundle(for: DiffPerformanceTest.self)
    var image1Url: URL!
    var image2Url: URL!

    override func setUpWithError() throws {
        image1Url = bundle.url(forResource: "AvatarView-1", withExtension: "png")!
        image2Url = bundle.url(forResource: "AvatarView-2", withExtension: "png")!
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
        let cgImage2 = Bitmap(data: data2)!.cgImage!

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
            let cgImage2 = Bitmap(data: data2)!.cgImage!
            _ = significantlyDifferentImages(data1, cgImage2)
        }
    }
}
