import Quick
import Nimble
import Legible
import SwiftUI

class MatchingSnapshotSpec: QuickSpec {
    #if os(macOS)
    override class func setUp() {
        super.setUp()
        NSApp.appearance = .init(named: .darkAqua)
    }
    #endif
    
    override class func spec() {
        describe("matching snapshots") {
            itBehavesLike(MatchingSnapshot.self) {
                Preview(HDivider_Previews.self)
            }
            itBehavesLike(MatchingSnapshot.self) {
                SwiftUIView(
                    Group{
                        Text("Hello, ").foregroundColor(.yellow)
                        Text("world!").foregroundColor(.green)
                    }.background(Color.black),
                    name: "HelloWorld"
                )
            }
            itBehavesLike(MatchingSnapshot.self) {
                Preview(AvatarView_Previews.self)
            }
        }
    }
}
