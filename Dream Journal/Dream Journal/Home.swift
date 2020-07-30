//
//  Home.swift
//  Dream Journal
//
//  Created by Helal Chowdhury on 7/28/20.
//  Copyright © 2020 Helal. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase

struct JournalList: View {
    @State var show = false
    @State var txt = ""
    @State var show2 = false
    @State var title = ""
    @State var description = ""
    @State var docID = ""
    @State var remove = false
    @ObservedObject var data = getData()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                HStack {
                    if !show {
                         Text("Dream Journal")
                            .fontWeight(.bold)
                            .font(.title)
                            .foregroundColor(.blue)
                            .opacity(0.7)
                            .shadow(color: .gray, radius: 1, x: 0.5, y: 0.5)
                    }
                    Spacer(minLength: 0)
                    HStack {
                        if self.show {
                            Image(systemName: Constants.searchIcon.rawValue)
                                .padding(.horizontal, 8)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 1, y: 1)
                            TextField("Search Journals", text: self.$txt)
                                .foregroundColor(.white)
                            Button(action: {
                                withAnimation {
                                    self.txt = ""
                                    self.show.toggle()
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                            }
                            .padding(.horizontal, 8)
                        }
                        else {
                            Button(action: {
                                withAnimation {
                                    self.show.toggle()
                                }
                            }) {
                                Image(systemName: Constants.searchIcon.rawValue)
                                    .foregroundColor(.white).padding(10)
                                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                            }
                        }
                    }
                    .padding(self.show ? 10 : 1)
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 5, x: 1, y: 1)
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.title = ""
                                self.description = ""
                                self.docID = ""
                                self.show2.toggle()
                            }
                        }) {
                            Image(systemName: "plus.circle").resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 1, y: 1)
                        }
                        .padding(.horizontal, 5)
                        
                        Button(action: {
                            withAnimation {
                                self.remove.toggle()
                            }
                        }) {
                            Image(systemName: self.remove ? "xmark.circle" : "trash").resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 1, y: 1)
                        }
                        .padding(.horizontal, 5)
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(20)
                    .shadow(color: .gray, radius: 5, x: 1, y: 1)
                }
                .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top)! + 5)
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                if self.data.datas.isEmpty {
                    if self.data.noData {
                        Spacer()
                        Text("There are no journals")
                        Spacer()
                    }
                    else {
                        Spacer()
                        Indicator()
                        Spacer()
                    }
                }
                else {
                    ScrollView(.vertical, showsIndicators: false) {
                        if self.txt != "" {
                            VStack(spacing: 15) {
                                if self.data.datas.filter({$0.title.lowercased().contains(self.txt.lowercased())}).count == 0 {
                                    Text("No Results Found")
                                        .padding(.top, 10)
                                }
                                else {
                                    ForEach(self.data.datas.reversed().filter({$0.title.lowercased().contains(self.txt.lowercased())})) {entry in
                                        HStack {
                                            cellView(journal: entry)
                                            if self.remove {
                                                Button(action: {
                                                    let db = Firestore.firestore()
                                                    db.collection("user").document("e0cdEmwKOGvPDTADtgFu").collection("journals").document(entry.id).delete()
                                                }) {
                                                    Image(systemName: "minus.circle.fill")
                                                        .resizable()
                                                        .frame(width: 20, height: 20)
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.top, 10)
                        }
                        else {
                            VStack (spacing: 15) {
                                ForEach(self.data.datas.reversed()) {entry in
                                    HStack {
                                        cellView(journal: entry)
                                        if self.remove {
                                            Button(action: {
                                                let db = Firestore.firestore()
                                                db.collection("user").document("e0cdEmwKOGvPDTADtgFu").collection("journals").document(entry.id).delete()
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.top, 10)
                        }
                    }
                }
            }
            Button(action: {
                try! Auth.auth().signOut()
                UserDefaults.standard.set(false, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
            }) {
                Text("Log Out")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 50)
            }
            .background(Color.blue)
            .cornerRadius(20)
            .padding(.bottom, 25)
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: self.$show2) {
            EditView(title: self.$title, description: self.$description, docID: self.$docID, show: self.$show2)
        }
    }
}

struct cellView: View {
    var journal: Journal

    var body: some View {
        NavigationLink(destination: ViewJournal(journal: journal)) {
            ZStack {
                Rectangle().fill(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray, radius: 5, x: 2, y: 2)
                    .opacity(0.9)
                VStack {
                    HStack {
                        VStack (alignment: .leading) {
                            Text(journal.title).bold()
                                .padding(.top, 8.0)
                                .fixedSize(horizontal: false, vertical: true)
                                .accentColor(Color.blue.opacity(0.7))
                            Text(journal.date)
                                .font(.caption).padding(.bottom, 10.0)
                                .accentColor(.black)
                            Text(journal.description)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .lineLimit(2)
                                .padding(.bottom, 10.0)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.leading, 15.0)
                        Spacer()
                    }
                }
            }.padding(.top, 1.0)
        }
    }
}

