import Foundation

public class S3Client {

    public init() {}

    private func stringToData(_ string: String) -> Data {
        guard let data = string.data(using: .utf8) else {
            fatalError("Failed to convert string to UTF-8 data: \(string)")
        }
        return data
    }

    public func upload(url: String, fields: [String: String], data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uploadURL = URL(string: url) else {
            completion(.failure(S3Error("Invalid S3 upload URL")))
            return
        }

        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"

        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add all returned S3 fields (policy, x-amz-*, key, etc.)
        for (key, value) in fields {
            body.append(stringToData("--\(boundary)\r\n"))
            body.append(stringToData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"))
            body.append(stringToData("\(value)\r\n"))
        }

        // Add file data
        body.append(stringToData("--\(boundary)\r\n"))
        let filename = fields["key"] ?? "document"
        body.append(stringToData("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n"))
        body.append(stringToData("Content-Type: application/octet-stream\r\n\r\n"))
        body.append(data)
        body.append(stringToData("\r\n"))
        body.append(stringToData("--\(boundary)--\r\n"))

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                completion(.failure(S3Error("S3 upload failed")))
            }
        }.resume()
    }

    public func download(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let downloadURL = URL(string: url) else {
            completion(.failure(S3Error("Invalid S3 download URL")))
            return
        }

        URLSession.shared.dataTask(with: downloadURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode), let data = data {
                completion(.success(data))
            } else {
                completion(.failure(S3Error("S3 download failed")))
            }
        }.resume()
    }
}



