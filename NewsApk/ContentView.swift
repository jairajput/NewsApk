//
//  ContentView.swift
//  NewsApk
//
//  Created by Jai  on 18/04/24.
//

import SwiftUI
import Firebase
  
struct ContentView: View {
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)
  
    var body: some View {
        VStack {
            if userLoggedIn {
                ArticleListView(articles: Article.previewData)

            } else {
                Login()
            }
        }.onAppear{
            //Firebase state change listeneer
            Auth.auth().addStateDidChangeListener{ auth, user in
                if (user != nil) {
                    userLoggedIn = true
                } else {
                    userLoggedIn = false
                }
            }
        }
    }
}
