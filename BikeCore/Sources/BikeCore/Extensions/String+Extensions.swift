public extension String {
    /// Returns a new string where the first letter is capitalized.
    var capitalizedSentence: String {
        let firstLetter = prefix(1).capitalized
        let remainingLetters = dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
}
