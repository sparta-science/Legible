import Quick
import Nimble
import Legible
import SwiftUI

class MatchingSnapshotSpec: QuickSpec {
    override func spec() {
        describe("matching snapshots") {
            itBehavesLike(MatchingSnapshot.self) {
                Preview<HDivider_Previews>()
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
                Preview<AvatarView_Previews>()
            }
        }
    }
}
