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
                    it("bitmap should be nil") {
                        let scale = NSScreen.main!.backingScaleFactor
                        let bitmap = subject.bitmapImageRepForCachingDisplay(in: frame)!
                        subject.cacheDisplay(in: frame, to: bitmap)
                        expect(bitmap.pixelsWide) == 200
                        expect(bitmap.size) == NSSize(width: 100, height: 1)
                        let pngData = bitmap.representation(using: .png, properties: [:])!
                        try! pngData.write(to: URL(fileURLWithPath: "/tmp/no-window.png"))
                        expect(pngData).to(haveCount(1288))
                    }
                }
                context("with window") {
                    var window: NSWindow!
                    beforeEach {
                        window = NSWindow()
                        window.contentView = subject
                    }
                    it("should be rendered to png") {
                        window.contentView = subject
                        expect(window.backingScaleFactor) == 2
                        let bitmap = subject.bitmapImageRepForCachingDisplay(in: frame)!
                        expect(bitmap).notTo(beNil())
                        subject.cacheDisplay(in: frame, to: bitmap)
                        expect(bitmap.pixelsWide) == 200
                        expect(bitmap.pixelsHigh) == 2
                        expect(bitmap.size) == NSSize(width: 100, height: 1)
                        let pngData = bitmap.representation(using: .png, properties: [:])!
                        expect(pngData).to(haveCount(259))
                        try! pngData.write(to: URL(fileURLWithPath: "/tmp/view.png"))
                    }
                }
            }
        }
    }
}
