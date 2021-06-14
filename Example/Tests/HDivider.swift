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
