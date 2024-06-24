import SwiftUI

struct EditLocationView: View {
    @Binding var location: Location
    @EnvironmentObject var userState: UserState
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

            Text("Edit Location")
                .font(.headline)
                .foregroundColor(Color("PrimaryTextColor"))

            TextField("Enter name", text: $location.name)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(Color("PrimaryTextColor"))

            if let categories = userState.user?.categories {
                Menu {
                    Button(action: {
                        location.category = nil
                    }) {
                        HStack {
                            Text("None")
                            Spacer()
                            Image(systemName: "slash.circle")
                        }
                    }
                    ForEach(categories, id: \.id) { category in
                        Button(action: {
                            location.category = category
                        }) {
                            HStack {
                                Text(category.name)
                                Spacer()
                                Image(systemName: category.icon)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(location.category?.name ?? "Select Category")
                            .foregroundColor(Color("PrimaryTextColor"))
                        Spacer()
                        Image(systemName: location.category?.icon ?? "questionmark.circle")
                            .foregroundColor(Color("PrimaryTextColor"))
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
            }

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
