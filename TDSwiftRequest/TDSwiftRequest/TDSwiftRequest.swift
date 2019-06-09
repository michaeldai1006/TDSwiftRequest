import Foundation

class TDSwiftRequest {
    static func request(urlString: String, method: String, body: [String: Any]?, headers: [String: String]?, timeOut: Double?, completion: (([String: Any]?, URLResponse?, Error?) -> Void)?) {
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
        if let timeOut = timeOut { sessionConfig.timeoutIntervalForRequest = timeOut }
        let urlSession = URLSession(configuration: sessionConfig)
        
        // Make request
        urlSession.dataTask(with: request) { (data, response, error) in
            // Handle request error
            if (error != nil) { completion?(nil, response, error); return }
            
            // Handle invalid response code
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode >= 400 {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        completion?(json, response, TDSwiftRequestError.statusCodeInvalid(statusCode: httpResponse.statusCode))
                    } else {
                        completion?(nil, response, TDSwiftRequestError.statusCodeInvalid(statusCode: httpResponse.statusCode))
                    }
                }
            } else {
                completion?(nil, nil, TDSwiftRequestError.responseInvalid)
                return
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
}
