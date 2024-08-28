import SwiftUI

struct EditLocationView: View {
    @Binding var location: Location
    @EnvironmentObject var userState: UserState
    var onSave: () -> Void
    var onCancel: () -> Void
    @ObservedObject private var transcriptionManager = VoiceTranscriptionManager.shared

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color("PrimaryTextColor"))
                        .font(.title)
                }
            }

            Text("Edit Location")
                .font(.headline)
                .foregroundColor(Color("PrimaryTextColor"))

            CustomTextField(
                placeholder: Text("Enter name").foregroundColor(Color("SecondaryTextColor")),
                text: $location.name
            )
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

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
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(Color("PrimaryTextColor"))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Notes")
                    .font(.subheadline)
                    .foregroundColor(Color("PrimaryTextColor"))

                HStack {
                    CustomTextField(
                        placeholder: Text("Enter notes").foregroundColor(Color("SecondaryTextColor")),
                        text: Binding(
                            get: { location.description ?? "" },
                            set: { location.description = $0.isEmpty ? "" : $0 }
                        )
                    )
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    
                    VoiceTranscriptionButton(notes: Binding(
                        get: { location.description ?? "" },
                        set: { location.description = $0 }
                    ))
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
        .onDisappear {
            transcriptionManager.stopRecording()
        }
    }
}
