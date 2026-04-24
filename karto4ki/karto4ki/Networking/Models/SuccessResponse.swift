import Foundation

struct SuccessResponse<T: Decodable>: Decodable {
    let data: T
}
