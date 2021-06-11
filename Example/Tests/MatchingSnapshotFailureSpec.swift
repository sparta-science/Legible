import Nimble
import Quick
import Legible
import SwiftUI

class MatchingSnapshotFailureSpec: QuickSpec {
    override func spec() {
        describe("MatchingSnapshot") {
            var fileManager: FileManager!
            var snapshotUrl: URL!
            var tempFolder: URL!
            beforeEach {
                fileManager = FileManager.default
                tempFolder = URL(fileURLWithPath: "/tmp/")
                MatchingSnapshot.configuration.snapshotsFolderUrl = tempFolder
            }
            afterEach {
                MatchingSnapshot.configuration.snapshotsFolderUrl = nil
                precondition(fileManager.fileExists(atPath: snapshotUrl.path))
            }
            context("no snapshot") {
                beforeEach {
                    snapshotUrl = tempFolder.appendingPathComponent("EmptyView.png")
                    try? fileManager.removeItem(at: snapshotUrl)
                    precondition(!fileManager.fileExists(atPath: snapshotUrl.path))
                    let options = XCTExpectedFailure.Options()
                    options.issueMatcher = { issue in
                        issue.type == .assertionFailure
                            && issue.compactDescription ==
                            "EmptyView.png was missing, now recorded\n"
                    }
                    XCTExpectFailure("and record", options: options)
                }
                itBehavesLike(MatchingSnapshot.self) {
                    SwiftUIView(EmptyView())
                }
            }
            context("mismatch") {
                var differentImageUrl: URL!
                beforeEach {
                    snapshotUrl = tempFolder.appendingPathComponent("hello.png")
                    let bundle = Bundle(for: Self.self)
                    differentImageUrl = bundle.urlForImageResource("AvatarView-1.png")!
                    try? fileManager.removeItem(at: snapshotUrl)
                    try! fileManager.copyItem(at: differentImageUrl, to: snapshotUrl)
                    let options = XCTExpectedFailure.Options()
                    options.issueMatcher = { issue in
                        issue.type == .assertionFailure
                            && issue.compactDescription ==
                            "hello.png was different, now recorded\n"
                    }
                    XCTExpectFailure("and overwrite", options: options)

                }
                itBehavesLike(MatchingSnapshot.self) {
                    SwiftUIView(Text("hello").background(Color.black), name: "hello")
                }
                afterEach {
                    let expected = try! Data(contentsOf: differentImageUrl)
                    let actual = try! Data(contentsOf: snapshotUrl)
                    precondition(expected != actual)
                }
            }
        }
    }
}
