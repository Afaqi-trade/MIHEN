#!/usr/bin/env python3
"""Run the XCTest scenario bodies with real assertions when CLT lacks XCTest.
This is a fallback core logic runner, never an iOS/XCTest substitute.
"""
import pathlib, re, subprocess, sys
root = pathlib.Path(__file__).resolve().parents[1]
out = root / '.build-results'
out.mkdir(exist_ok=True)
harness = r'''
import Foundation
class XCTestCase {}
var checks = 0
var failures = 0
func XCTAssertTrue(_ condition: @autoclosure () throws -> Bool, file: StaticString = #file, line: UInt = #line) rethrows {
    checks += 1
    if try !condition() { failures += 1; print("FAIL \(file):\(line)") }
}
func XCTAssertFalse(_ condition: @autoclosure () throws -> Bool, file: StaticString = #file, line: UInt = #line) rethrows { try XCTAssertTrue(!condition(), file: file, line: line) }
func XCTAssertEqual<T: Equatable>(_ a: @autoclosure () throws -> T, _ b: @autoclosure () throws -> T, file: StaticString = #file, line: UInt = #line) {
    checks += 1
    do {
        let left = try a(), right = try b()
        if left != right { failures += 1; print("FAIL \(file):\(line): \(left) != \(right)") }
    } catch { failures += 1; print("FAIL \(file):\(line): \(error)") }
}
func XCTAssertNil<T>(_ value: @autoclosure () throws -> T?, file: StaticString = #file, line: UInt = #line) rethrows { try XCTAssertTrue(value() == nil, file: file, line: line) }
func XCTAssertThrowsError<T>(_ body: @autoclosure () throws -> T, file: StaticString = #file, line: UInt = #line) {
    checks += 1
    do { _ = try body(); failures += 1; print("FAIL expected error \(file):\(line)") } catch {}
}
'''
sources = '\n'.join(p.read_text() for p in sorted((root/'Core').glob('*.swift')))
calls = []
for path in sorted((root/'Tests/MIHENCoreTests').glob('*.swift')):
    source = path.read_text().replace('import XCTest', '').replace('@testable import MIHENCore', '')
    classname = re.search(r'final class (\w+)', source)[1]
    methods = re.findall(r'func (test\w+)\(\)( throws)?', source)
    calls += [(classname, method, bool(throws)) for method, throws in methods]
    sources += '\n' + source
for cls, method, throwing in calls:
    if not throwing:
        sources += f'\n{cls}().{method}(); print("PASS {cls}.{method}")\n'
        continue
    sources += f'\ndo {{ try {cls}().{method}(); print("PASS {cls}.{method}") }} catch {{ failures += 1; print("FAIL {method}: \\(error)") }}\n'
sources += f'\nprint("{len(calls)} scenarios, \\(checks) assertions, \\(failures) failures")\nexit(failures == 0 ? 0 : 1)\n'
main = out/'main.swift'
main.write_text(harness + sources)
subprocess.run(['swiftc', '-swift-version', '5', str(main), '-o', str(out/'core-tests')], check=True)
sys.exit(subprocess.run([str(out/'core-tests')]).returncode)
