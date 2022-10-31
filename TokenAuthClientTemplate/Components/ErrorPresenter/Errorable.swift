import Combine
import SwiftUI

protocol Errorable {
    var errorPublisher: PassthroughSubject<Error, Never> { get }
}
