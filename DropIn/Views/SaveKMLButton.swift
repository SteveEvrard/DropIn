import SwiftUI

struct SaveKMLButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("KML")
                    .foregroundColor(Color("ButtonTextColor"))
                    .font(.system(size: 14))
                Image(systemName: "square.and.arrow.down")
                    .imageScale(.medium)
                    .foregroundColor(Color("ButtonTextColor"))
            }
            .padding(6)
            .background(Color("ButtonColor"))
            .cornerRadius(8)
            .shadow(radius: 2)
        }
    }
}
