import Quick
import Nimble
import SwiftUI
import UniformTypeIdentifiers

public class SnapshotConfiguration {
    static public var usedSnapshots = [URL]()
    public var windowScale = 1
    public var snapshotsFolderUrl: URL?
    public var maxColorDifference: Float {
        #if os(iOS)
        0.15
        #else
        0.033
        #endif
    }

    private static var operatingSystemName: String {
        #if os(macOS)
        "macOs"
        #elseif os(iOS)
        "iOs"
        #endif
    }
    
    public static var operatingSystemFolder: String {
        "\(operatingSystemName)-\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)"
    }

    public func folderUrl(testFile: URL) -> URL {
        if let configured = snapshotsFolderUrl {
            return configured
        }
        return testFile
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
            .appendingPathComponent(Self.operatingSystemFolder)
    }
}

public class MatchingSnapshot: Behavior<Snapshotting> {
    public static var configuration = SnapshotConfiguration()

    private static func makeWindow() -> SnapshottingWindow {
        #if os(macOS)
        let window = StandardScaleWindow(scale: Self.configuration.windowScale)
        window.colorSpace = .sRGB
        return window
        #elseif os(iOS)
        let window = UIWindow()
        window.isHidden = false
        return window
        #endif
    }
    
    public override class func spec(_ aContext: @escaping () -> Snapshotting) {
        var snapshotUrl: URL!
        var window: SnapshottingWindow!
        var subject: SnapshottingView!
        var size: CGSize!
        let snapshotting: Snapshotting = aContext()
        beforeEach {
            let exampleFileUrl = URL(fileURLWithPath: $0.example.callsite.file)
            snapshotUrl = Self.configuration
                .folderUrl(testFile: exampleFileUrl)
                .appendingPathComponent(snapshotting.name)
                .appendingPathExtension("png")

            SnapshotConfiguration.usedSnapshots.append(snapshotUrl)
            subject = snapshotting.view
            window = makeWindow()
            #if os(macOS)
            window.contentView = subject
            size = snapshotting.size ?? subject.fittingSize
            #elseif os(iOS)
            window.addSubview(subject)
            size = snapshotting.size
            #endif
        }

        it(snapshotting.name + " should match snapshot") {
            let frame = CGRect(origin: .zero, size: size)
            subject.frame = frame
            let bitmap = subject.bitmap()
            @discardableResult
            func overwriteExpectedWithActualOrSaveToArtifacts() -> Data {
                let pngData: Data! = bitmap.pngData()
                var failedSnapshotFileUrl: URL
                if let artifactsPath = ProcessInfo.processInfo.environment["SNAPSHOT_ARTIFACTS"], !artifactsPath.isEmpty {
                    let artifactsUrl = URL(fileURLWithPath: artifactsPath, isDirectory: true)
                    let artifactsSubUrl = artifactsUrl.appendingPathComponent(SnapshotConfiguration.operatingSystemFolder)
                    try! FileManager.default.createDirectory(at: artifactsSubUrl, withIntermediateDirectories: true)
                    failedSnapshotFileUrl = artifactsSubUrl.appendingPathComponent(snapshotUrl.lastPathComponent)
                } else {
                    failedSnapshotFileUrl = snapshotUrl
                }
                try! pngData.write(to: failedSnapshotFileUrl)
                return pngData
            }
            XCTContext.runActivity(named: "compare png") { activity in
                guard let oldImage = CIImage(contentsOf: snapshotUrl) else {
                    overwriteExpectedWithActualOrSaveToArtifacts()
                    fail("\(snapshotUrl.lastPathComponent) was missing, now recorded")
                    return
                }
                autoreleasepool {
                    let newImage = bitmap.ciImage()
                    let diffOperation = diff(oldImage, newImage)
                    let diffOutput = diffOperation.outputImage!
                    if maxColorDiff(histogram: histogram(ciImage: diffOutput)) > configuration.maxColorDifference {
                        let existing = XCTAttachment(
                            contentsOfFile: snapshotUrl,
                            uniformTypeIdentifier: UTType.png.identifier
                        )
                        existing.name = "expected-" + snapshotting.name
                        activity.add(existing)

                        let diffImage = diffOutput.image(size: diffOutput.extent.size)
                        let diffAttachment = XCTAttachment(image: diffImage)
                        diffAttachment.name = "diff-" + snapshotting.name
                        activity.add(diffAttachment)

                        let pngData = overwriteExpectedWithActualOrSaveToArtifacts()
                        let attachment = XCTAttachment(
                            data: pngData,
                            uniformTypeIdentifier: UTType.png.identifier
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

#if os(macOS)
extension NSView {
    func bitmap() -> NSBitmapImageRep {
        let bitmap: NSBitmapImageRep! = bitmapImageRepForCachingDisplay(in: frame)
        expect(bitmap).notTo(beNil())
        waitUntil { done in
            DispatchQueue.main.async {
                self.cacheDisplay(in: self.frame, to: bitmap)
                done()
            }
        }
        return bitmap
    }
}

extension NSBitmapImageRep {
    func pngData() -> Data? {
        representation(using: .png, properties: [:])
    }
    
    func ciImage() -> CIImage {
        CIImage(bitmapImageRep: self)!
    }
}

extension CIImage {
    func image(size: CGSize) -> NSImage {
        let rep = NSCIImageRep(ciImage: self)
        let nsImage = NSImage(size: size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}

#elseif os(iOS)
extension UIView {
    func bitmap() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        
        var image: UIImage?
        waitUntil { done in
            DispatchQueue.main.async {
                image = renderer.image { rendererContext in
                    self.layer.render(in: rendererContext.cgContext)
                }
                done()
            }
        }
        return image!
    }
}

extension UIImage {
    func ciImage() -> CIImage {
        CIImage(cgImage: self.cgImage!)
    }
}

extension CIImage {
    func image(size: CGSize) -> UIImage {
        // size changes is not supported for iOS
        UIImage(ciImage: self)
    }
}

#endif
