//
//  BlueIntentAppleLogin.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/10/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import AuthenticationServices

extension BlueIntent {
  class AppleLogin: NSObject {
    enum LoginError {
      // 系统不支持 Apple 登录
      case systemNotSupported
      // 不支持该授权方式
      case credentialNotSupported
      // 授权失败
      case authError(Error)
    }
    
    enum LoginResult {
      case success(_ oauth: OAuth)
      case failure(_ error: LoginError)
    }
    
    struct OAuth {
      let user: String
      let authorizationCode: String
      var fullName: PersonNameComponents?
      var email: String?
      
      @available(iOS 13.0, *)
      init?(_ credential: ASAuthorizationAppleIDCredential?) {
        guard let credential = credential else { return nil }
        if let code = credential.authorizationCode,
           let authorizationCode = String(data: code, encoding: .utf8) {
          self.authorizationCode = authorizationCode
        } else {
          return nil
        }
        
        self.user = credential.user
        self.fullName = credential.fullName
        self.email = credential.email
      }
    }
    
    static let shared = AppleLogin()
    
    fileprivate var result: ((LoginResult) -> ())?
    
    static func isAppleLoginSupport() -> Bool {
      if #available(iOS 13.0, *) {
        return true
      }
      return false
    }
    
    func login(_ result: ((LoginResult) -> ())?) {
      self.result = result
      
      if #available(iOS 13.0, *) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController =
          ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        return
      }
      
      result?(.failure(.systemNotSupported))
    }
  }
}

extension BlueIntent.AppleLogin: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  @available(iOS 13.0, *)
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
    case let appleIDCredential as ASAuthorizationAppleIDCredential:
      if let oauth = OAuth(appleIDCredential) {
        self.result?(.success(oauth))
        return
      }
      self.result?(.failure(.credentialNotSupported))
    case _ as ASPasswordCredential:
      self.result?(.failure(.credentialNotSupported))
    default:
      self.result?(.failure(.credentialNotSupported))
      break
    }
  }
  
  @available(iOS 13.0, *)
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    self.result?(.failure(BlueIntent.AppleLogin.LoginError.authError(error)))
  }
  
  @available(iOS 13.0, *)
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return UIApplication.shared.windows.first!
  }
}

extension BlueIntent.AppleLogin.LoginError {
  // 中文错误
  func cn() -> String {
    switch self {
    case .credentialNotSupported:
      return "授权方式暂不支持"
    case .systemNotSupported:
      return "当前系统版本暂不支持，请升级到iOS 13以上系统"
    case .authError(let error):
      if #available(iOS 13.0, *) {
        switch error {
        case ASAuthorizationError.notHandled:
          return "授权请求无响应"
        case ASAuthorizationError.invalidResponse:
          return "授权请求无效"
        case ASAuthorizationError.canceled:
          return "取消授权请求"
        default:
          return "授权失败"
        }
      }
    }
    return "授权失败"
  }
}
