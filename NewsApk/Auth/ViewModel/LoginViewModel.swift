//
//  LoginViewModel.swift
//  NewsApk
//
//  Created by Jai  on 18/04/24.
//

import SwiftUI
import Firebase
import CryptoKit
import AuthenticationServices
import GoogleSignIn

class LoginViewModel:ObservableObject{
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    @Published var CLIENT_CODE: String = ""
    
    @Published var  showOTPField:Bool = false
    
    @Published var showError:Bool = false
    @Published var errorMessage:String = ""
    
    
    @AppStorage("log_status") var logStatus:Bool = false
    @Published var nonce:String = ""
    @MainActor
    func getOTPCode() {
        UIApplication.shared.closeKeyboard()
        Task{
            do{
               //Disable For Real Devices
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                let code = try await  PhoneAuthProvider.provider().verifyPhoneNumber("+\(mobileNo)", uiDelegate: nil)
                await MainActor.run(body:{
                    CLIENT_CODE = code
                    
                    withAnimation(.easeInOut){showOTPField = true}
                })
                
            } catch{
                await handleError(error: error)
            }
        }
    }
    
    @MainActor
    func verifyOTPCode(){
        UIApplication.shared.closeKeyboard()
        Task{
            do{
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE, verificationCode: otpCode)
                
                try await Auth.auth().signIn(with: credential)
                
                print("Success")
                await MainActor.run(body: {
                    withAnimation(.easeInOut){logStatus = true}
                })
            } catch{
                await handleError(error: error)
            }
        }
        
        
    }
    @MainActor
    func handleError(error:Error)async{
        await MainActor.run(body:{
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    //Apple Api
    func appleAuthenticate(credential:ASAuthorizationAppleIDCredential){
        guard let token = credential.identityToken else {
            print("Error with Firebase ")
            return
        }
        guard let tokenString = String(data:token,encoding: .utf8) else{
            print("Error With Token")
            return
        }
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",idToken:tokenString,rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential){(result,err) in
            if let error = err{
                print(error.localizedDescription)
                return
            }
            print("Logged IN Success")
            withAnimation(.easeInOut){self.logStatus = true}
            
        }
    }
    func logGoogleUser(user:GIDGoogleUser){
        Task{
            do{
//                guard let idToken = user.authentication.idToken else{ return}
                guard let idToken = user.userID, // Access the ID token
                      let accessToken = user.profile?.email else { return }
//                let accessToken = user.authentication.accessToken
                
                let credential = OAuthProvider.credential(withProviderID: idToken, accessToken: accessToken)
                
                try await Auth.auth().signIn(with:credential)
                print("Success")
                await MainActor.run(body:{
                    withAnimation(.easeInOut){logStatus = true}
                })
            } catch{
                await handleError(error:  error)
            }
        }
    }
    
}

extension UIApplication{
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder),to:nil,from:nil,for: nil)
    }
    func rootController() -> UIViewController {
        guard let window = connectedScenes.first as? UIWindowScene else{return.init()}
        guard let viewController = window.windows.last?.rootViewController else {return.init()}
        
        return viewController
    }
}
//Apple
func sha256(_ input: String) -> String{
    let inputData = Data(input.utf8)
    let hashData = SHA256.hash(data:inputData)
    let hashString = hashData.compactMap{
        return String(format: "%02x",$0)
    }.joined()
    return hashString
}
func randomNonceString(length:Int = 32) -> String{
    precondition(length>0)
    let charset:Array<Character> =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remaningLength = length
    
    while remaningLength > 0 {
        let randoms:[UInt8] = (0..<16).map {_ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to Generae Nonce .Second Random Copy Filed with Osstatus\(errorCode)")
            }
            return random
        }
        randoms.forEach { random  in
            if remaningLength == 0{
                return
            }
            if random < charset.count{
                result.append(charset[Int(random)])
                remaningLength -= 1
            }
        }
    }
    return result
    
}

