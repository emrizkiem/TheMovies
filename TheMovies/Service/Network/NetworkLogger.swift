//
//  NetworkLogger.swift
//  TheMovies
//
//  Created by M. Rizki Maulana on 18/03/25.
//

import Moya

final class NetworkLogger: PluginType {
  func willSend(_ request: RequestType, target: TargetType) {
    #if DEBUG
    print("🔵 REQUEST: \(request.request?.httpMethod ?? "") \(request.request?.url?.absoluteString ?? "")")
    if let headers = request.request?.allHTTPHeaderFields {
      print("HEADERS: \(headers)")
    }
    if let body = request.request?.httpBody, let bodyString = String(data: body, encoding: .utf8) {
      print("BODY: \(bodyString)")
    }
    #endif
  }
  
  func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
    #if DEBUG
    switch result {
    case .success(let response):
      print("🟢 RESPONSE: \(response.statusCode) \(response.request?.url?.absoluteString ?? "")")
      if let json = try? JSONSerialization.jsonObject(with: response.data, options: .mutableContainers),
         let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
         let jsonString = String(data: jsonData, encoding: .utf8) {
        print("RESPONSE DATA: \(jsonString)")
      }
    case .failure(let error):
      print("🔴 ERROR: \(error.localizedDescription)")
    }
    #endif
  }
}
