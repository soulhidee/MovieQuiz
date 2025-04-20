import Foundation

struct NetworkClient {
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data else { return }
            
            handler(.success(data))
        }
        task.resume()
    }
}
