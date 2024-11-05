import Nimble
import Quick
import Legible
import SwiftUI

class SwiftUISpec: QuickSpec {
    override class func spec() {
        describe("HDivider") {
            context("preview") {
                var subject: NSView!
                var frame: NSRect!
                beforeEach {
                    subject = NSHostingView(rootView: HDivider_Previews.previews)
                    frame = NSRect(origin: .zero, size: subject.intrinsicContentSize)
                }
                context("with window") {
                    var window: NSWindow!
                    beforeEach {
                        NSApp.appearance = .init(named: .darkAqua)!
                        window = StandardScaleWindow(scale: 2)
                        window.colorSpace = .sRGB
                        window.contentView = subject
                    }
                    it("should use windows's color space") {
                        window.contentView = subject
                        let bitmap = subject.bitmapImageRepForCachingDisplay(in: frame)!
                        expect(bitmap).notTo(beNil())
                        subject.cacheDisplay(in: frame, to: bitmap)
                        expect(bitmap.colorSpace) == .sRGB
                        var colors = [Int](repeating: .min, count: 4)
                        bitmap.getPixel(&colors, atX: 0, y: 0)
                        expect(colors) == [50, 215, 75, 255]
                        let pngData = bitmap.representation(using: .png, properties: [:])!
                        XCTContext.runActivity(named: "save png") {
                            let attachment = XCTAttachment(data: pngData, uniformTypeIdentifier: String(kUTTypePNG))
                            attachment.lifetime = .keepAlways
                            $0.add(attachment)
                        }
                        expect(pngData.count).to(beGreaterThanOrEqualTo(259))
                        try! pngData.write(to: URL(fileURLWithPath: "/tmp/view-in-window.png"))
                    }
                }
            }
        }
    }
}
