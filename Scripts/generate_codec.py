from generate_models import S, arrays
from pathlib import Path
s='// Generated typed backup CSV dispatch and uniqueness validation.\nimport Foundation\nextension BackupCodec {\n    static func validateUnique(_ data: BackupDocument) throws {\n'
for n in S:
    s+=f'        guard Set(data.{arrays[n]}.map(\\.id)).count == data.{arrays[n]}.count, data.{arrays[n]}.count <= 100_000, data.{arrays[n]}.allSatisfy({{ !$0.id.isEmpty && $0.id.count <= 150 }}) else {{ throw PlanError.invalid("validation.duplicates") }}\n'
s+='    }\n    public static func exportCSV(_ data: BackupDocument) throws -> String {\n        try validate(data)\n        var rows = [["entity", "id", "payload"]]\n'
for n in S:
    s+=f'        for record in data.{arrays[n]} {{ rows.append(["{n}", record.id, String(decoding: try encoder().encode(record), as: UTF8.self)]) }}\n'
s+='''        return CSV.encode(rows)
    }
    public static func importCSV(_ text: String) throws -> BackupDocument {
        let rows = try CSV.parse(text)
        guard rows.first == ["entity", "id", "payload"] else { throw PlanError.invalid("validation.csvHeader") }
        var document = BackupDocument()
        for (index, row) in rows.dropFirst().enumerated() {
            guard row.count == 3 else { throw PlanError.invalid("CSV: \\(index + 2)") }
            let bytes = Data(row[2].utf8)
            switch row[0] {
'''
for n in S:
    s+=f'            case "{n}":\n                let value = try decoder().decode({n}Record.self, from: bytes)\n                guard value.id == row[1] else {{ throw PlanError.invalid("validation.data") }}\n                document.{arrays[n]}.append(value)\n'
s+='''            default: throw PlanError.invalid("validation.csvEntity")
            }
        }
        try validate(document)
        return document
    }
}
'''
Path('Core/BackupCSV.swift').write_text(s)
