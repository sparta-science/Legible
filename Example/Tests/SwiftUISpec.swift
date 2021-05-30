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
                context("without window") {
                    it("should use generic color space") {
                        let bitmap = subject.bitmapImageRepForCachingDisplay(in: frame)!
                        subject.cacheDisplay(in: frame, to: bitmap)
                        expect(bitmap.pixelsWide) == Int(NSScreen.main!.backingScaleFactor) * 100
                        expect(bitmap.size) == NSSize(width: 100, height: 1)
                        expect(bitmap.colorSpace) == .genericRGB
                        var colors = [Int](arrayLiteral: 0,0,0,0)
                        bitmap.getPixel(&colors, atX: 0, y: 0)

                        let color = bitmap.colorAt(x: 0, y: 0)!
                        expect(color.colorSpace) == .genericRGB
                        expect(color.type) == .componentBased
                        expect(color.redComponent) ≈ 0.1882
                        expect(color.greenComponent) ≈ 0.8274
                        expect(color.blueComponent) ≈ 0.2313

                        let pngData = bitmap.representation(using: .png, properties: [:])!


                        try! pngData.write(to: URL(fileURLWithPath: "/tmp/view-with-no-window.png"))
                        expect(pngData).to(haveCount(1288))
                    }
                }
                context("with window") {
                    var window: NSWindow!
                    beforeEach {
                        window = NSWindow()
                        window.colorSpace = .sRGB
                        window.contentView = subject
                    }
                    it("should use windows's color space") {
                        window.contentView = subject
                        let bitmap = subject.bitmapImageRepForCachingDisplay(in: frame)!
                        expect(bitmap).notTo(beNil())
                        subject.cacheDisplay(in: frame, to: bitmap)
                        expect(bitmap.colorSpace) == .sRGB
                        let color = bitmap.colorAt(x: 0, y: 0)!
                        expect(color.colorSpace) == .genericRGB
                        expect(color.type) == .componentBased
                        expect(color.redComponent) ≈ 0.1960
                        expect(color.greenComponent) ≈ 0.8431
                        expect(color.blueComponent) ≈ 0.2941

                        let pngData = bitmap.representation(using: .png, properties: [:])!
                        expect(pngData).to(haveCount(259))
                        try! pngData.write(to: URL(fileURLWithPath: "/tmp/view-in-window.png"))
                    }
                }
            }
        }
    }
}
