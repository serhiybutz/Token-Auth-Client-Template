import Foundation

protocol NavigatableFormFieldEnum: CaseIterable, Hashable {}

extension NavigatableFormFieldEnum where AllCases.Index == Int {

    var index: Int { Self.allCases.firstIndex(of: self)! }

    static var count: Int { Self.allCases.count }

    var next: Self? {
        let fields = Self.allCases
        let idx = self.index
        return idx < Self.count - 1
        ? fields[idx + 1]
        : nil
    }

    var prev: Self? {
        let fields = Self.allCases
        let idx = self.index
        return idx > 0
        ? fields[idx - 1]
        : nil
    }

    var isFirst: Bool { self.index == 0 }
    var isLast: Bool { self.index == Self.count - 1 }
}
