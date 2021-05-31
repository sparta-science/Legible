import SwiftUI

struct AvatarView: View {
    let image: Image

    var body: some View {
        image
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black.opacity(0.5), lineWidth: 2))
            .padding(1)
            .overlay(Circle().strokeBorder(Color.white.opacity(0.8)))
            .shadow(radius: 10)
            .padding(5)
    }
}

#if DEBUG
public struct AvatarView_Previews: PreviewProvider {
    class FindBundle {}
    public static var previews: some View {
        // https://www.freeimages.com/photo/puppy-1-1519401
        AvatarView(image:
                    Image("puppy",
                          bundle: Bundle(for: FindBundle.self))
                    .resizable()
        )
        .background(Color.black)
        .frame(width: 200, height: 200)
    }
}
#endif
