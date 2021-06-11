import Nimble
import Quick
import Legible
import SwiftUI

class MatchingSnapshotFailureSpec: QuickSpec {
    override func spec() {
        describe("MatchingSnapshot") {
            context("no snapshot") {
                var fileManager: FileManager!
                var snapshotUrl: URL!
                beforeEach {
                    let tempFolder = URL(fileURLWithPath: "/tmp/")
                    MatchingSnapshot.configuration.snapshotsFolderUrl = tempFolder
                    fileManager = FileManager.default
                    snapshotUrl = tempFolder.appendingPathComponent("EmptyView.png")
                    try? fileManager.removeItem(at: snapshotUrl)
                    precondition(!fileManager.fileExists(atPath: snapshotUrl.path))
                    let options = XCTExpectedFailure.Options()
                    options.issueMatcher = { issue in
                        issue.type == .assertionFailure
                            && issue.compactDescription ==
                            "EmptyView.png was missing, now recorded\n"
                    }
                    XCTExpectFailure("should fail and record", options: options)
                }
                afterEach {
                    MatchingSnapshot.configuration.snapshotsFolderUrl = nil
                    precondition(fileManager.fileExists(atPath: snapshotUrl.path))
                }
                itBehavesLike(MatchingSnapshot.self) {
                    SwiftUIView(EmptyView())
                }
            }
        }
    }
}
