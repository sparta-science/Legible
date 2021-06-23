// swiftlint:disable:this file_name
import Combine
import Nimble

typealias Completion<Failure> = ((Subscribers.Completion<Failure>) -> Void) where Failure: Error

func shouldCall<Failure>(_ done: @escaping () -> Void) -> Completion<Failure> {
    { completion in
        if case .finished = completion {
            done()
        } else {
            fail("should finish, but got \(completion)")
        }
    }
}
