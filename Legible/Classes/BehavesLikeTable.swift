import Quick

fileprivate extension String {
    func tabulated() -> [String] {
        components(separatedBy: "|")
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

protocol CollectionType: Collection {
    subscript (position: Self.Index) -> Self.Iterator.Element { get }
}
extension Array: CollectionType {}
extension Array where Element: CollectionType {
    func getColumn(column: Element.Index) -> [ Element.Iterator.Element ] {
        map { $0[ column ] }
    }
}

extension Array where Element == String {
    func allSameType<T: LosslessStringConvertible>() -> [T]? {
        let converted = compactMap { T($0) }
        if converted.count == count {
            return converted
        }
        return nil
    }
    func asBestType() -> [Any] {
        if let asInt: [Int] = allSameType() {
            return asInt
        }
        if let asDouble: [Double] = allSameType() {
            return asDouble
        }
        if let asBool: [Bool] = allSameType() {
            return asBool
        }
        return self
    }
}

public class BehavesLikeTable: Behavior<String> {
    public override class func spec(_ aContext: @escaping () -> String) {
        let lines = aContext()
            .components(separatedBy: .newlines)
            .filter { !$0.hasPrefix("|--") }
            .filter { !$0.hasSuffix("--|") }
        let title = lines
            .first!
            .trimmingCharacters(in: CharacterSet(charactersIn: "|"))
            .trimmingCharacters(in: .whitespaces)
        let columnNames = lines[1].tabulated()
        let stringRows: [[String]] = lines[2...].map {
            $0.tabulated()
        }
        let columns = columnNames.enumerated().map {
            stringRows.getColumn(column: $0.offset).asBestType()
        }
        stringRows.enumerated().forEach { row in
            var dictionary: [String: Any] = [:]
            for (index, element) in columnNames.enumerated() {
                dictionary[element] = columns[index][row.offset]
            }
            itBehavesLike(title) { dictionary }
        }
    }
}

public class AsciiTable: BehavesLikeTable {}
