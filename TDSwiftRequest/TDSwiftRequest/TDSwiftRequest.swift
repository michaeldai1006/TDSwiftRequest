import Foundation

class TDSwiftRequest {
    static func request(urlString: String, method: String, body: [String: Any]?, headers: [String: String]?, timeOutInS: Double?, completion: (([String: Any]?, URLResponse?, Error?) -> Void)?) {
        // Parse url string
        guard let url = URL(string: urlString) else { completion?(nil, nil, TDSwiftRequestError.urlInvalid); return }
        
        // URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Request header
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        if let headers = headers {
            headers.forEach { (key, value) in request.setValue(value, forHTTPHeaderField: key) }
        }
        
        // Request body
        do {
            if let body = body { request.httpBody = try JSONSerialization.data(withJSONObject: body, options: []) }
        } catch {
            completion?(nil, nil, TDSwiftRequestError.bodyInvalid); return
        }
        
        // URLSession, timeout
        let sessionConfig = URLSessionConfiguration.default
        if let timeOutInS = timeOutInS { sessionConfig.timeoutIntervalForRequest = timeOutInS }
        let urlSession = URLSession(configuration: sessionConfig)
        
        // Make request
        urlSession.dataTask(with: request) { (data, response, error) in
            // Handle request error
            if (error != nil) { completion?(nil, response, error); return }
            
            // Handle invalid response code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 400 {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        completion?(json, response, TDSwiftRequestError.statusCodeInvalid(statusCode: httpResponse.statusCode)); return
                    } else {
                        completion?(nil, response, TDSwiftRequestError.statusCodeInvalid(statusCode: httpResponse.statusCode)); return
                    }
                }
            } else {
                completion?(nil, nil, TDSwiftRequestError.responseInvalid); return
            }
            
            // JSONSerialization
            guard let data = data else { completion?([:], response, nil); return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] ?? [:]
                completion?(json, response, nil)
                return
            } catch {
                completion?(nil, response, TDSwiftRequestError.parsingResponseFailed)
                return
            }
        }.resume()
    }
    
    static func parseErrorMessage(error: Error, response: URLResponse?) -> String {
        // TDSwiftRequestError
        if let error = error as? TDSwiftRequestError {
            switch error {
            case .urlInvalid:
                return "Request URL invalid"
            case .bodyInvalid:
                return "Request body invalid"
            case .statusCodeInvalid:
                return "Response code invalid: \(error.getStatusCode() ?? -1))"
            case .responseInvalid:
                return "Response invalid"
            case .parsingResponseFailed:
                return "Parsing response failed"
            }
        }
        
        // URLError
        if let error = error as? URLError {
            if error.code == URLError.Code.notConnectedToInternet {
                return "No internet connection"
            } else if error.code == URLError.Code.timedOut {
                return "Request timed out"
            } else if error.code == URLError.Code.cannotConnectToHost {
                return "Could not connect to server"
            }
        }
        
        // Unknown error
        return "Unknown request error"
    }
}
