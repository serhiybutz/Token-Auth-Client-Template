import SwiftUI

extension View {

    var embedInNavViewWithoutToolbar: some View {
        modifier(NavViewWithoutToolbarModifier())
    }
}

struct NavViewWithoutToolbarModifier: ViewModifier {

    func body(content: Content) -> some View {

        NavigationView {
            content
                .navigationBarTitle("")
                .navigationBarHidden(true)
        }
    }
}
