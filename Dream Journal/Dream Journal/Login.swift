//
//  Login.swift
//  Dream Journal
//
//  Created by Helal Chowdhury on 7/29/20.
//  Copyright © 2020 Helal. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase

struct Authenticate: View {
    @State var show = false
    @State var resend = false
    @State var verify2 = false
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    
    var body: some View {
        VStack {
            if self.status {
                JournalList()
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
            }
            else {
                ZStack {
                    NavigationLink(destination: SignUp(show: self.$show, resend: self.$resend, verify2: self.$verify2), isActive: self.$show) {
                        Text("")
                    }
                    .hidden()

                    Login(show: self.$show, resend: self.$resend, verify2: self.$verify2)
                }
            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("status"), object: nil, queue: .main) { (_) in
                self.status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
            }
        }
    }
}

struct Login: View {
    
    @State var color = Color.black.opacity(0.7)
    @State var email = ""
    @State var pass = ""
    @State var visible = false
    @Binding var show: Bool
    @State var alert = false
    @State var error = ""
    @Binding var resend: Bool
    @Binding var verify2: Bool
    
    
    var body: some View {
        ZStack {
            ZStack(alignment: .topTrailing) {
                GeometryReader{_ in
                    VStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                        Text("JOURNAL WAVE")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.blue.opacity(0.75))
                            .padding(.top, 0)
                            .shadow(color: .black, radius: 0.5, x: 0.5, y: 0.5)
                        Text("Log in to your account")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(self.color)
                            .padding(.top, 0)
                        TextField("Email", text: self.$email)
                            .autocapitalization(.none)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color(.blue) : self.color, lineWidth:  2))
                            .padding(.top, 10)
                        
                        HStack(spacing: 15) {
                            VStack {
                                if self.visible {
                                    TextField("Password", text: self.$pass)
                                        .autocapitalization(.none)
                                }
                                else {
                                    SecureField("Password", text: self.$pass)
                                        .autocapitalization(.none)
                                }
                            }
                            Button(action: {
                                self.visible.toggle()
                            }) {
                                Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(self.color)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 4).stroke(self.pass != "" ? Color(.blue) : self.color, lineWidth:  2))
                        .padding(.top, 10)
                        
                        HStack {
                            HStack {
                                Button(action: {
                                    self.show.toggle()
                                }) {
                                    Text("Register")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                                }.padding(.horizontal, 5)
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(20)
                            .shadow(color: .gray, radius: 5, x: 1, y: 1)
                            
                            Spacer()
                            
                            Button(action: {
                                self.reset()
                            }) {
                                Text("Forgot password")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.blue)
                            }.padding(.horizontal, 5)
                        }
                        .padding(.top, 20)
                        
                        Button(action: {
                            self.verify()
                        }) {
                            Text("Log in")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.vertical)
                                .frame(width: UIScreen.main.bounds.width - 50)
                                .shadow(color: .black, radius: 1, x: 1, y: 1)
                        }
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(20)
                        .padding(.top, 25)
                        .shadow(color: .gray, radius: 5, x: 1, y: 1)
                        
                        Spacer()
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 25)
                }
                
            }
            
            if self.alert {
                ErrorView(alert: self.$alert, error: self.$error, resend: self.$resend, verify2: self.$verify2)
            }
            if self.verify2 {
                ReSentView(verify2: self.$verify2, resend: self.$resend)
            }
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded {_ in
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        )
    }
    
    func verify() {
        if self.email != "" && self.pass != "" {
            Auth.auth().signIn(withEmail: self.email, password: self.pass) { (res, err) in
                let user = Auth.auth().currentUser
                if err != nil {
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                    return
                }
                if !user!.isEmailVerified {
                    self.error = "Email has not yet been verified"
                    self.alert.toggle()
                    self.resend = true
                    return
                }
                UserDefaults.standard.set(true, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
            }
        }
        else {
            self.error = "Please fill in the contents properly"
            self.alert.toggle()
        }
    }
    
    func reset() {
        if self.email != "" {
            Auth.auth().sendPasswordReset(withEmail: self.email) { (err) in
                if err != nil {
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                    return
                }
                self.error = "RESET"
                self.alert.toggle()
            }
        }
        else {
            self.error = "Email ID is empty"
            self.alert.toggle()
        }
    }
}

struct ErrorView: View {
    @State var color = Color.black.opacity(0.7)
    @Binding var alert: Bool
    @Binding var error: String
    @Binding var resend: Bool
    @Binding var verify2: Bool
    let user = Auth.auth().currentUser
    
    var body: some View {
        GeometryReader {_ in
            VStack {
                HStack {
                    Text(self.error == "RESET" ? "Message" : "Error")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(self.color)
                    Spacer()
                }.padding(.horizontal, 25)
                
                Text(self.error == "RESET" ? "Password reset link has been sent successfully" : self.error)
                    .foregroundColor(self.color)
                    .padding(.top)
                    .padding(.horizontal, 25)
                
                if self.resend {
                    Button(action: {
                        self.user?.sendEmailVerification { (error) in
                            guard let error = error else {
                                self.alert.toggle()
                                self.verify2 = true
                                return
                            }
                        }
                    }) {
                        Text("Resend Verification Email")
                            .foregroundColor(Color.blue.opacity(0.7))
                            .padding(.top)
                            .padding(.horizontal, 25)
                    }
                }
                
                Button(action: {
                    self.error = ""
                    self.alert.toggle()
                }) {
                    Text(self.error == "RESET" ? "OK" : "Cancel")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 120)
                }
                .background(Color.blue)
                .cornerRadius(20)
                .padding(.top, 25)
            }
            .padding(.vertical, 25)
            .frame(width: UIScreen.main.bounds.width - 70)
            .background(Color.white)
            .cornerRadius(25)
        }
        .background(Color.black.opacity(0.35).edgesIgnoringSafeArea(.all))
    }
}

struct ReSentView: View {
    @State var color = Color.black.opacity(0.7)
    @Binding var verify2: Bool
    @Binding var resend: Bool
    
    var body: some View {
        GeometryReader {_ in
            VStack {
                HStack {
                    Text("Email Sent")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(self.color)
                    Spacer()
                }.padding(.horizontal, 25)
                
                Text("A verification link has been sent to your email")
                    .foregroundColor(self.color)
                    .padding(.top)
                    .padding(.horizontal, 25)
                
                Button(action: {
                    self.verify2 = false
                    self.resend = false
                }) {
                    Text("OK")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width - 120)
                }
                .background(Color.blue)
                .cornerRadius(20)
                .padding(.top, 25)
            }
            .padding(.vertical, 25)
            .frame(width: UIScreen.main.bounds.width - 70)
            .background(Color.white)
            .cornerRadius(25)
        }
        .background(Color.black.opacity(0.35).edgesIgnoringSafeArea(.all))
    }
}
