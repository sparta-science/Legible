import XCTest
import SwiftUI
@testable import Legible

/**
 Compare performance of image snapshot
 using CoreImage vs vImage frameworks
 */
class SnapshotPerformanceTest: XCTestCase {
    var expectedImageUrl: URL!

    override func setUpWithError() throws {
        let bundle = Bundle(for: SnapshotPerformanceTest.self)
        expectedImageUrl = bundle.urlForImageResource("AvatarView-2.png")!
    }

    func getBitmap() -> NSBitmapImageRep {
        let window = StandardScaleWindow(scale: 2)
        window.colorSpace = .sRGB
        let subject = NSHostingView(rootView: AvatarView_Previews.previews)
        window.contentView = subject
        let size = subject.fittingSize
        let frame = NSRect(origin: .zero, size: size)
        let bitmap: NSBitmapImageRep! = subject.bitmapImageRepForCachingDisplay(in: frame)
        subject.cacheDisplay(in: frame, to: bitmap)
        return bitmap
    }

    func test_CoreImage_Performance() throws {
        measure {
            let bitmap = getBitmap()

            let oldImage = CIImage(contentsOf: expectedImageUrl)!
            let newImage = CIImage(bitmapImageRep: bitmap)!
            let diffOperation = diff(oldImage, newImage)
            let diffOutput = diffOperation.outputImage!

            let diff = maxColorDiff(histogram: histogram(ciImage: diffOutput))
            XCTAssertEqual(0.015625, diff)
        }
    }

    func test_vImage_Buffer_Performance() throws {
        measure {
            let bitmap = getBitmap()
            let data1 = try! Data(contentsOf: expectedImageUrl)
            let cgImage2 = bitmap.cgImage!
            let areDifferent = significantlyDifferentImages(data1, cgImage2)
            XCTAssertFalse(areDifferent)
            let size = bitmap.size
            let diffImage = diff(data1, cgImage2, size: size)
            XCTAssertEqual(diffImage.size, size)
        }
    }
}
