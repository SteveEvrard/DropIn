import SwiftUI

struct CategoryTile: View {
    var category: Category
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Spacer()
                Image(systemName: category.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .foregroundColor(Color("ButtonColor"))
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(Color("PrimaryTextColor"))
                Spacer()
            }
            .frame(width: 100, height: 100)
            .background(Color("BackgroundColor"))
            .cornerRadius(10)
            .shadow(radius: 3)
        }
    }
}
