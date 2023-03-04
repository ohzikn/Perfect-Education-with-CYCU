//
//  LessonListView.swift
//  Perfect Education with CYCU
//
//  Created by 范喬智 on 2023/3/5.
//

import SwiftUI

struct LessonListView: View {
    
    @State var isSyncConfirmSheetPresented: Bool = false
    
    var body: some View {
        VStack {
            Text("課表內容準備中")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("同步課表") {
                    isSyncConfirmSheetPresented.toggle()
                }
            }
        }
        .sheet(isPresented: $isSyncConfirmSheetPresented) {
            LessonListSyncConfirmView()
        }
        .navigationTitle("課表")
        .navigationBarTitleDisplayMode(.large)    }
}

struct LessonListSyncConfirmView: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

struct LessonListView_Previews: PreviewProvider {
    static var previews: some View {
        LessonListView()
    }
}
