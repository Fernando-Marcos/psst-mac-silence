import Foundation

@main
enum ParserSmoke {
    static func main() {
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
        precondition(result.battery == [
            "lowpowermode": 0, "proximitywake": 1, "ttyskeepawake": 1, "powernap": 1
        ])
        precondition(result.charger == [
            "lowpowermode": 1, "proximitywake": 0, "ttyskeepawake": 0, "powernap": 0
        ])

        let malformed = PowerProfileParser.parse("Battery Power:\n lowpowermode nope\n displaysleep 2")
        precondition(malformed.battery.isEmpty)
        print("OK: 2 pruebas del perfil energético superadas")
    }
}
