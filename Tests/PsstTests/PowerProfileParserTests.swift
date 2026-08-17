import XCTest
@testable import Psst

final class PowerProfileParserTests: XCTestCase {
    func testParsesManagedSettingsForBothPowerSources() {
        let input = """
        Battery Power:
         lowpowermode         0
         proximitywake        1
         ttyskeepawake        1
         powernap             1
         sleep                5
        AC Power:
         lowpowermode         1
         proximitywake        0
         ttyskeepawake        0
         powernap             0
        """

        let result = PowerProfileParser.parse(input)

        XCTAssertEqual(result.battery, [
            "lowpowermode": 0, "proximitywake": 1, "ttyskeepawake": 1, "powernap": 1
        ])
        XCTAssertEqual(result.charger, [
            "lowpowermode": 1, "proximitywake": 0, "ttyskeepawake": 0, "powernap": 0
        ])
    }

    func testIgnoresUnknownAndMalformedValues() {
        let input = """
        Battery Power:
         lowpowermode nope
         displaysleep 2
        AC Power:
         powernap 0
        """

        let result = PowerProfileParser.parse(input)
        XCTAssertTrue(result.battery.isEmpty)
        XCTAssertEqual(result.charger, ["powernap": 0])
    }
}
