import SwiftUI

struct ContentGridView: View {
    @EnvironmentObject var userState: UserState
    @State private var showAddCategoryPopup = false
    @State private var newCategoryName = ""
    @State private var newCategoryType = "General"
    @State private var selectedCategory: Category?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    if let categories = userState.user?.categories {
                        ForEach(categories) { item in
                            CategoryTile(category: item) {
                                selectedCategory = item
                            }
                        }
                    }
                    CategoryTile(category: Category(name: "Add Category", icon: "plus")) {
                        showAddCategoryPopup = true
                    }
                }
                .padding()
            }
            .background(Color("BackgroundColor"))
            
            if showAddCategoryPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showAddCategoryPopup = false
                    }
                AddCategoryView(
                    categoryName: $newCategoryName,
                    selectedCategoryType: $newCategoryType,
                    onSave: {
                        showAddCategoryPopup = false
                        newCategoryName = ""
                        newCategoryType = "General"
                    },
                    onCancel: {
                        showAddCategoryPopup = false
                        newCategoryName = ""
                        newCategoryType = "General"
                    }
                )
                .environmentObject(userState)
            }
            
            if let selectedCategory = selectedCategory {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                CategoryLocationsView(category: selectedCategory) {
                    self.selectedCategory = nil
                }
                .environmentObject(userState)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
            }
        }
    }
}
