import SwiftUI
import FirebaseAuth

struct HeaderView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isListView: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse.circle.fill")
                .imageScale(.large)
                .foregroundColor(Color("ButtonColor"))
            Text("DropIn")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryTextColor"))
            Spacer()
            HStack(spacing: 10) {
                Button(action: {
                    withAnimation {
                        isListView = true
                    }
                }) {
                    Image(systemName: "list.bullet")
                        .imageScale(.large)
                        .foregroundColor(isListView ? Color("ButtonTextColor") : Color("ButtonColor"))
                        .padding(10)
                        .background(isListView ? Color("ButtonColor") : Color.clear)
                        .cornerRadius(8)
                }
                Button(action: {
                    withAnimation {
                        isListView = false
                    }
                }) {
                    Image(systemName: "rectangle.grid.2x2.fill")
                        .imageScale(.large)
                        .foregroundColor(!isListView ? Color("ButtonTextColor") : Color("ButtonColor"))
                        .padding(10)
                        .background(!isListView ? Color("ButtonColor") : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color("BackgroundColor"))
        .frame(maxWidth: .infinity, alignment: .leading)
        .zIndex(1)
    }
}
