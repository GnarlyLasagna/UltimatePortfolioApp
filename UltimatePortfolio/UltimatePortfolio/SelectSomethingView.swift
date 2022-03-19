import SwiftUI

struct SelectSomethingView: View {
    var body: some View {
        Text("Please select something from the menu to begin.")
            .italic()
            .foregroundColor(.secondary)
    }
}

struct SelectSomething_Previews: PreviewProvider {
    static var previews: some View {
        SelectSomethingView()
    }
}
