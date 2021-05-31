import Quick
import Nimble
import SwiftUI


struct Preview<T> where T: PreviewProvider {
    let name: String
    let view: NSView
    let size: NSSize?

    init(_ type: T.Type = T.self, size: NSSize? = nil) {
        name = String(describing: T.self)
            .replacingOccurrences(of: "_Previews", with: "")
        view = NSHostingView(rootView: T.previews)
        self.size = size
    }
}

extension Preview: Snapshotting {}

protocol Snapshotting {
    var name: String { get }
    var view: NSView { get }
    var size: NSSize? { get }
}

struct SwiftUIView {
    let name: String
    let view: NSView
    let size: NSSize?

    init<T>(_ someView: T, name: String = String(describing: T.self), size: NSSize? = nil) where T: View {
        self.name = name
        self.size = size
        view = NSHostingView(rootView: someView)
    }
}

extension SwiftUIView: Snapshotting {}

class MatchingSnapshot: Behavior<Snapshotting> {
    static var appearanceName = NSAppearance.Name.darkAqua
    static var windowScale = 2
    override class var name: String {
        "Snapshot for \(Snapshotting.self)"
    }
    override class func spec(_ aContext: @escaping () -> Snapshotting) {
        var snapshotUrl: URL!
        var window: NSWindow!
        var subject: NSView!
        var size: NSSize!
        beforeEach {
            let specUrl = URL(fileURLWithPath: $0.example.callsite.file)
            let snapshotsFolder = specUrl
                .deletingLastPathComponent()
                .appendingPathComponent("Snapshots")
            snapshotUrl = snapshotsFolder
                .appendingPathComponent(aContext().name)
                .appendingPathExtension("png")

            subject = aContext().view
            NSApp.appearance = .init(named: appearanceName)!
            window = StandardScaleWindow(scale: windowScale)
            window.colorSpace = .sRGB
            window.contentView = subject
            size = aContext().size ?? subject.fittingSize
        }

        it("should match snapshot") {
            let frame = NSRect(origin: .zero, size: size)
            subject.frame = frame
            let bitmap: NSBitmapImageRep! = subject.bitmapImageRepForCachingDisplay(in: frame)
            expect(bitmap).notTo(beNil())
            subject.cacheDisplay(in: frame, to: bitmap)
            let pngData: Data! = bitmap.representation(using: .png, properties: [:])
            XCTContext.runActivity(named: "compare png") {
                let attachment = XCTAttachment(
                    data: pngData,
                    uniformTypeIdentifier: String(kUTTypePNG)
                )
                attachment.name = "actual-" + aContext().name
                $0.add(attachment)
                if let existingPng = try? Data(contentsOf: snapshotUrl) {
                    let existing = XCTAttachment(
                        data: existingPng,
                        uniformTypeIdentifier: String(kUTTypePNG)
                    )
                    existing.name = "expected-" + aContext().name
                    $0.add(existing)
                    if existingPng != pngData {
                        try! pngData.write(to: snapshotUrl)
                        fail("\(snapshotUrl.lastPathComponent) was different, now recorded")
                    }
                } else {
                    try! pngData.write(to: snapshotUrl)
                    fail("\(snapshotUrl.lastPathComponent) was missing, now recorded")
                }
            }
        }
    }
}
