import SwiftUI

struct EditLocationNameView: View {
    @Binding var locationName: String
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }
            }
            .padding([.trailing])

            Text("Name")
                .font(.headline)
                .foregroundColor(Color("PrimaryTextColor"))

            TextField("Enter name", text: $locationName)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(Color("PrimaryTextColor"))

            Button(action: onSave) {
                Text("Save")
                    .foregroundColor(Color("ButtonTextColor"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("ButtonColor"))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color("BackgroundColor"))
        .cornerRadius(12)
        .padding()
    }
}
