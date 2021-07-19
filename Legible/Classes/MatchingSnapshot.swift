import Quick
import Nimble
import SwiftUI

public class SnapshotConfiguration {
    static public var usedSnapshots = [URL]()
    public var windowScale = 1
    public var snapshotsFolderUrl: URL?
    public var maxColorDifference: Float = 0.033

    public func folderUrl(testFile: URL) -> URL {
        if let configured = snapshotsFolderUrl {
            return configured
        }
        return testFile
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
    }
}

public class MatchingSnapshot: Behavior<Snapshotting> {
    public static var configuration = SnapshotConfiguration()

    public override class func spec(_ aContext: @escaping () -> Snapshotting) {
        var snapshotUrl: URL!
        var window: NSWindow!
        var subject: NSView!
        var size: NSSize!
        let snapshotting: Snapshotting = aContext()
        beforeEach {
            let exampleFileUrl = URL(fileURLWithPath: $0.example.callsite.file)
            snapshotUrl = Self.configuration
                .folderUrl(testFile: exampleFileUrl)
                .appendingPathComponent(snapshotting.name)
                .appendingPathExtension("png")

            SnapshotConfiguration.usedSnapshots.append(snapshotUrl)
            subject = snapshotting.view
            window = StandardScaleWindow(scale: Self.configuration.windowScale)
            window.colorSpace = .sRGB
            window.contentView = subject
            size = snapshotting.size ?? subject.fittingSize
        }

        it(snapshotting.name + " should match snapshot") {
            let frame = NSRect(origin: .zero, size: size)
            subject.frame = frame
            let bitmap: NSBitmapImageRep! = subject.bitmapImageRepForCachingDisplay(in: frame)
            expect(bitmap).notTo(beNil())
            waitUntil { done in
                DispatchQueue.main.async {
                    subject.cacheDisplay(in: frame, to: bitmap)
                    done()
                }
            }
            @discardableResult
            func overwriteExpectedWithActual() -> Data {
                let pngData: Data! = bitmap.representation(using: .png, properties: [:])
                try! pngData.write(to: snapshotUrl)
                return pngData
            }
            XCTContext.runActivity(named: "compare png") { activity in
                guard let oldImage = CIImage(contentsOf: snapshotUrl) else {
                    overwriteExpectedWithActual()
                    fail("\(snapshotUrl.lastPathComponent) was missing, now recorded")
                    return
                }
                autoreleasepool {
                    let newImage = CIImage(bitmapImageRep: bitmap)!
                    let diffOperation = diff(oldImage, newImage)
                    let diffOutput = diffOperation.outputImage!
                    if maxColorDiff(histogram: histogram(ciImage: diffOutput)) > configuration.maxColorDifference {
                        let existing = XCTAttachment(
                            contentsOfFile: snapshotUrl,
                            uniformTypeIdentifier: String(kUTTypePNG)
                        )
                        existing.name = "expected-" + snapshotting.name
                        activity.add(existing)

                        let rep = NSCIImageRep(ciImage: diffOutput)
                        let diffNSImage = NSImage(size: rep.size)
                        diffNSImage.addRepresentation(rep)
                        let diffAttachment = XCTAttachment(image: diffNSImage)
                        diffAttachment.name = "diff-" + snapshotting.name
                        activity.add(diffAttachment)

                        let pngData = overwriteExpectedWithActual()
                        let attachment = XCTAttachment(
                            data: pngData,
                            uniformTypeIdentifier: String(kUTTypePNG)
                        )
                        attachment.name = "actual-" + snapshotting.name
                        activity.add(attachment)
                        fail("\(snapshotUrl.lastPathComponent) was different, now recorded")
                    }
                }
            }
        }
    }
}
