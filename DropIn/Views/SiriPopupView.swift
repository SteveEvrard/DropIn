import SwiftUI

struct SiriPopupView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    appState.displaySiriPopup = false
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .padding()
                }
            }
            Text("Voice Activated")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Image(systemName: "mic.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("Say:")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Text("\"Hey Siri, DropIn\"")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Image(systemName: "scope")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("To Get Location")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Image(systemName: "mappin.and.ellipse")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(30)
        .padding(40)
        .shadow(radius: 10)
    }
}
