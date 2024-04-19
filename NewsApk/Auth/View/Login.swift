//
//  Login.swift
//  NewsApk
//
//  Created by Jai  on 18/04/24.
//

import SwiftUI
import Firebase
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct Login: View {
    @StateObject var loginModel: LoginViewModel = .init()
    @State private var err : String = ""  
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            VStack(alignment: .leading , spacing: 10){
                (Text("Welcome")
                    .foregroundColor(.black) +
                 Text("\nLogin To Continue")
                    .foregroundColor(.gray)
                )
                .font(.title)
                .fontWeight(.semibold)
                .lineSpacing(10)
                .padding(.top , 10)
                .padding(.trailing,15)
                
                CustomTextField(hint: "Mobile No", text: $loginModel.mobileNo)
                    .disabled(loginModel.showOTPField)
                    .opacity(loginModel.showOTPField ? 0.4:1)
                    .overlay(alignment: .trailing,content: {
                        Button("Change"){
                            withAnimation(.easeInOut){
                                loginModel.showOTPField = false
                                loginModel.otpCode = ""
                                loginModel.CLIENT_CODE = ""
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.indigo)
                        .opacity(loginModel.showOTPField ? 1:0)
                        .padding(.trailing,15)
                    })
                    .padding(.top, 50)
                
                CustomTextField(hint: "OTP", text: $loginModel.otpCode)
                    .disabled(!loginModel.showOTPField)
                    .opacity(!loginModel.showOTPField ? 0.4:1)
                    .padding(.top, 20)
                
                Button(action: loginModel.showOTPField ? loginModel.verifyOTPCode:loginModel.getOTPCode){
                    HStack{
                        Text(loginModel.showOTPField ?"verifyCode:":"Get OTP")
                        
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal,25)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.black.opacity(0.05))
                    )
                }
                .padding(.top , 30)
                Text("(OR)")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top,30)
                    .padding(.bottom,20)
                    .padding(.leading,-60)
                    .padding(.horizontal)
                HStack(spacing: 8){
                 CustomButton()
                    .overlay{
                        SignInWithAppleButton{(request) in
                            loginModel.nonce = randomNonceString()
                            request.requestedScopes = [.email,.fullName]
                            request.nonce = sha256(loginModel.nonce)
                            
                        } onCompletion:{(result) in
                            
                            switch result{
                            case .success(let user):
                                print("Sucess")
                                guard let credential = user.credential as?
                                        ASAuthorizationAppleIDCredential else {
                                    print("Error With FireBase")
                                    return
                                }
                                loginModel.appleAuthenticate(credential:credential)
                            case.failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 55)
                        .blendMode(.overlay)
                    }
                    .clipped()
                    
                    //GoogleButton
                    Button{
                                Task {
                                    do {
                                        try await Authentication().googleOauth()
                                    } catch let e {
                                        print(e)
                                        err = e.localizedDescription
                                    }
                                }
                            }label: {
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                    Text("Sign in with Google")
                                }
                                
                                .padding(7)
                            }
                            .buttonStyle(.borderedProminent)
                        .clipped()
                    
                    
                }
                .padding(.leading ,-50)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                
                
                //Apple

                }
            .padding(.leading,60)
            .padding(.vertical,15)
        }
        .alert(loginModel.errorMessage, isPresented: $loginModel.showError){
            
        }

    }
    @ViewBuilder
    func CustomButton(isGoogle:Bool = false)->some View{
        HStack{
            Group{
                if isGoogle{
                    Image(systemName: "g.circle.fill")
                        .resizable()
                        .renderingMode(.template)
                }else{
                    Image(systemName: "applelogo")
                        .resizable()

                }
            }
            .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .frame(height: 45)
            
            Text("\(isGoogle ? "Google":"Apple") Sign In")
                .font(.callout)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal,15)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        )
    }
}


#Preview {
    Login()
}
