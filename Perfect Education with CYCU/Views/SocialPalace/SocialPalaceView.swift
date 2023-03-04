//
//  SocialPalaceView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/3/3.
//

import SwiftUI

struct SocialPalaceView: View {
    @EnvironmentObject var currentPalaceSession: CurrentPalaceSession
    
    @FocusState var isTextFieldFocused: Bool
    
    @State var messageEntry: String = ""
    
    var body: some View {
        VStack {
            List(currentPalaceSession.messageBoardItems) { item in
                if let message = item.message {
                    VStack(alignment: .leading) {
                        Text(message)
                        Text("\(item.userName ?? "Annoymous") \(item.userId ?? "")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.plain)
            if let credentials = currentPalaceSession.palaceCredentials {
                Text("使用 \(credentials.userName) \(credentials.userId) 傳送")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text("目前留言板僅載入最近十則訊息")
                .font(.caption)
                .foregroundColor(.orange)
            HStack {
                TextField("訊息", text: $messageEntry)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        Task {
                            await currentPalaceSession.uploadMessageBoard(message: messageEntry)
                            messageEntry = String()
                        }
                        isTextFieldFocused = false
                    }
                Button("傳送") {
                    Task {
                        await currentPalaceSession.uploadMessageBoard(message: messageEntry)
                        messageEntry = String()
                    }
                    isTextFieldFocused = false
                }
                .disabled(messageEntry.isEmpty)
            }
            .padding([.horizontal, .bottom])
            .disabled(currentPalaceSession.palaceCredentials == nil)
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .onAppear {
            Task {
                await currentPalaceSession.recieveMessageBoard()
            }
        }
        .refreshable {
            await currentPalaceSession.recieveMessageBoard()
        }
        .navigationTitle("留言板")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct SocialPalaceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SocialPalaceView()
                .environmentObject(CurrentPalaceSession())
        }
    }
}
