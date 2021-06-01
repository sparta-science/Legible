import Quick
import Nimble
import SwiftUI

class MatchingSnapshot: Behavior<Snapshotting> {
    static var appearanceName = NSAppearance.Name.darkAqua
    static var windowScale = 2
    static var snapshotsFolderUrl: URL?

    override class func spec(_ aContext: @escaping () -> Snapshotting) {
        var snapshotUrl: URL!
        var window: NSWindow!
        var subject: NSView!
        var size: NSSize!
        var previousAppearance: NSAppearance?
        beforeEach {
            let exampleFileUrl = URL(fileURLWithPath: $0.example.callsite.file)
            let snapshotsFolder = exampleFileUrl
                .deletingLastPathComponent()
                .appendingPathComponent("Snapshots")
            snapshotUrl = (snapshotsFolderUrl ?? snapshotsFolder)
                .appendingPathComponent(aContext().name)
                .appendingPathExtension("png")

            subject = aContext().view
            previousAppearance = NSApp.appearance
            NSApp.appearance = .init(named: appearanceName)!
            window = StandardScaleWindow(scale: windowScale)
            window.colorSpace = .sRGB
            window.contentView = subject
            size = aContext().size ?? subject.fittingSize
        }
        
        afterEach {
            NSApp.appearance = previousAppearance
        }

        it(aContext().name + " should match snapshot") {
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
