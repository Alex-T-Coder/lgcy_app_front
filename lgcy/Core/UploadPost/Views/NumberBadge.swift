import SwiftUI

struct NumberBadge: View {
    var number: Int
    var body: some View {
        Text("\(number)")
            .font(.caption)
            .padding(4)
            .foregroundColor(.white)
            .background(Circle().fill(Color.blue))
            .overlay(
                Circle().stroke(Color.blue, lineWidth: 1)
            )
    }
}

#Preview {
    NumberBadge(number: 1)
}
