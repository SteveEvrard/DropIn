import SwiftUI

struct AddCategoryView: View {
    @EnvironmentObject var userState: UserState
    @Binding var categoryName: String
    @Binding var selectedCategoryType: String
    var onSave: () -> Void
    var onCancel: () -> Void
    
    let categoryTypes = [
        "General": "mappin.circle.fill",
        "Favorite": "star.fill",
        "Home": "house.fill",
        "Nature": "leaf.fill",
        "Travel": "car.fill"
    ]

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

            Text("Add Category")
                .font(.headline)
                .foregroundColor(Color("PrimaryTextColor"))

            TextField("Enter name", text: $categoryName)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(Color("PrimaryTextColor"))

            Menu {
                ForEach(categoryTypes.keys.sorted(), id: \.self) { type in
                    Button(action: {
                        selectedCategoryType = type
                    }) {
                        HStack {
                            Text(type)
                            Spacer()
                            Image(systemName: categoryTypes[type]!)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedCategoryType)
                        .foregroundColor(Color("PrimaryTextColor"))
                    Spacer()
                    Image(systemName: categoryTypes[selectedCategoryType] ?? "questionmark.circle")
                        .foregroundColor(Color("PrimaryTextColor"))
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            }

            Button(action: {
                addCategory()
                onSave()
            }) {
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
    
    private func addCategory() {
        let newCategory = Category(name: categoryName, icon: categoryTypes[selectedCategoryType] ?? "questionmark.circle")
        if var user = userState.user {
            user.categories.append(newCategory)
            userState.saveUser(user: user)
        }
    }
}
