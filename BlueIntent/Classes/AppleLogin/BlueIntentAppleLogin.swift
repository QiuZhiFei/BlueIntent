//
//  BlueIntentAppleLogin.swift
//  BlueIntent
//
//  Created by zhifei qiu on 2020/10/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import AuthenticationServices

public extension BlueIntent.AppleLogin {
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
}

public extension BlueIntent.AppleLogin {
  struct OAuth {
    public let user: String
    public let authorizationCode: String
    public let fullName: PersonNameComponents?
    public let email: String?
    
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
}

extension BlueIntent {
  public class AppleLogin: NSObject {
    private static let shared = AppleLogin()
    
    private var result: ((LoginResult) -> ())?
  }
}

public extension BlueIntent.AppleLogin {
  static func systemSupported() -> Bool {
    if #available(iOS 13.0, *) {
      return true
    }
    return false
  }
  
  static func login(_ result: ((LoginResult) -> ())?) {
    Self.shared.login(result)
  }
}

private extension BlueIntent.AppleLogin {
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

@available(iOS 13.0, *)
extension BlueIntent.AppleLogin: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    let credential = authorization.credential
    if let appleIDCredential = credential as? ASAuthorizationAppleIDCredential {
      if let oauth = OAuth(appleIDCredential) {
        self.result?(.success(oauth))
        return
      }
      let error = ASAuthorizationError(.unknown)
      self.result?(.failure(LoginError.authError(error)))
      return
    }
    if credential is ASPasswordCredential {
      self.result?(.failure(.credentialNotSupported))
      return
    }
    let error = ASAuthorizationError(.unknown)
    self.result?(.failure(LoginError.authError(error)))
  }
  
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    self.result?(.failure(BlueIntent.AppleLogin.LoginError.authError(error)))
  }
  
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return UIApplication.shared.windows.first!
  }
}

public extension BlueIntent.AppleLogin.LoginError {
  // 中文错误
  var cn: String {
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
