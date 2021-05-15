import Nimble
import Quick
import Legible

class MyFormatter: MeasurementFormatter {
    init(locale: String, style: String) {
        super.init()
        self.unitOptions = [.naturalScale]
        self.locale = Locale(identifier: locale)
        self.numberFormatter.maximumFractionDigits = 1
        self.unitStyle = Formatter.UnitStyle(rawValue: ["short", "medium", "long"].firstIndex(of: style)! + 1)!
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FormatterExampleSpec: QuickSpec {
    override func spec() {
        describe("MyFormatter") {
            context("as table of example") {
                sharedExamples("formatted measuments") { aContext in
                    var subject: MyFormatter!

                    beforeEach {
                        let locale = aContext()["locale"] as! String
                        let style = aContext()["style"] as! String
                        subject = MyFormatter(locale: locale, style: style)
                    }
                    it("should match metric system") {
                        expect(subject.locale.usesMetricSystem) == (aContext()["metric"] as! Bool)
                    }
                    it("should format in base units") {
                        let massUnits: [UnitMass] = [.grams, .kilograms, .pounds, .milligrams, .metricTons]
                        let value = aContext()["value"] as! Double
                        let symbol = aContext()["unit"] as! String
                        let dimention = massUnits.first {
                            $0.symbol == symbol
                        }!
                        let measument = Measurement(value: value, unit: dimention)
                        let converted = measument.converted(to: .baseUnit())
                        let expected = aContext()["expected"] as! String
                        expect(subject.string(from: converted)) == expected
                    }
                }
                describe("string from measurement") {
                    context("should produce expected string") {
                        itBehavesLike(AsciiTable.self) {
                            """
            |------------------------------------------------------|
            |              formatted measuments                    |
            |------------------------------------------------------|
            | locale|metric| style | value  | unit | expected      |
            |------------------------------------------------------|
            | en_US |false | long  | 10.0   | kg   | 22 pounds     |
            | en_AU |true  | short | 130000 | mg   | 0.1kg         |
            | en_UK |true  | short | 2.7    | t    | 2,700 kg      |
            | ru    |true  | medium| 13001  | g    | 13 кг         |
            | jp    |true  | long  | 5.1    | lb   | 2.3 kilograms |
            | he    |true  | long  | 510    | g    | 0.5 קילוגרם   |
            |------------------------------------------------------|
            """
                        }
                    }
                }
            }
        }
    }
}
