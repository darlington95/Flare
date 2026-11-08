import AppKit
import XCTest
import FlareAppleUI

/// Regression test for the macOS timeline font-size setting.
///
/// The shared `RichText` path previously rendered body text with a fixed `NSFont` size baked into
/// `platformText`, so `FlareTheme`'s `.dynamicTypeSize` had no effect on the unstyled runs and the
/// user's `fontSizeDiff` setting was ignored. `RichText` now applies the diff explicitly through
/// `RichTextFontScaling`, mirroring the iOS `preferredContentSizeCategory` mechanism. These tests
/// guard that the scaling logic stays monotonic, matches the system body size at diff 0, and never
/// collapses below the minimum.
final class RichTextFontScaleTests: XCTestCase {
    func testBodyFontSizeMatchesSystemAtZeroDiff() {
        XCTAssertEqual(RichTextFontScaling.bodyFontSize(fontSizeDiff: 0), NSFont.systemFontSize, accuracy: 0.001)
    }

    func testBodyFontSizeGrowsWithPositiveDiff() {
        let base = RichTextFontScaling.bodyFontSize(fontSizeDiff: 0)
        for diff in [1, 2, 3, 4] {
            let size = RichTextFontScaling.bodyFontSize(fontSizeDiff: Float(diff))
            XCTAssertGreaterThan(size, base, "diff \(diff) should enlarge the body font")
            XCTAssertEqual(size - base, CGFloat(diff), accuracy: 0.001)
        }
    }

    func testBodyFontSizeShrinksWithNegativeDiff() {
        let base = RichTextFontScaling.bodyFontSize(fontSizeDiff: 0)
        for diff in [-1, -2, -3] {
            let size = RichTextFontScaling.bodyFontSize(fontSizeDiff: Float(diff))
            XCTAssertLessThan(size, base, "diff \(diff) should shrink the body font")
        }
    }

    func testBodyFontSizeIsClampedToMinimum() {
        let clamped = RichTextFontScaling.bodyFontSize(fontSizeDiff: -100)
        XCTAssertEqual(clamped, RichTextFontScaling.minimumFontSize, accuracy: 0.001)
        XCTAssertLessThanOrEqual(clamped, RichTextFontScaling.bodyFontSize(fontSizeDiff: 0))
    }
}
