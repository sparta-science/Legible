import Nimble
import Quick
import Legible
import SwiftUI


struct HDivider: View {
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
    }
}

#if DEBUG
public struct HDivider_Previews: PreviewProvider {
    public static var previews: some View {
        HDivider(color: .green)
            .frame(width: 100)
    }
}
#endif

class StandardScaleWindow: NSWindow {
    override var backingScaleFactor: CGFloat {
        1
    }
}


class SwiftUISpec: QuickSpec {
    override func spec() {
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
                        window = StandardScaleWindow()
                        window.colorSpace = .sRGB
                        window.contentView = subject
                    }
                    it("should use windows's color space") {
                        window.contentView = subject
                        let bitmap = subject.bitmapImageRepForCachingDisplay(in: frame)!
                        expect(bitmap).notTo(beNil())
                        subject.cacheDisplay(in: frame, to: bitmap)
                        expect(bitmap.colorSpace) == .sRGB
                        var colors = [0, 0, 0, 0]
                        bitmap.getPixel(&colors, atX: 0, y: 0)
                        expect(colors) == [50, 215, 75, 255]

                        let pngData = bitmap.representation(using: .png, properties: [:])!
                        expect(pngData).to(haveCount(169))
                        try! pngData.write(to: URL(fileURLWithPath: "/tmp/view-in-window.png"))
                    }
                }
            }
        }
    }
}
