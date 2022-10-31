import Foundation

protocol AnimSubmitButtonReportable {
    func signalActionSuccess()
    func signalActionFailure()
}

extension AnimSubmitButtonViewModel: AnimSubmitButtonReportable {

    func signalActionSuccess() {
        buttonState = .completed
    }

    func signalActionFailure() {
        buttonState = .enabledAgain
    }
}
