import UIKit

@MainActor enum PeriodReportPDF {
    static func render(title: String, paragraphs: [String]) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds:CGRect(x:0,y:0,width:595,height:842))
        return renderer.pdfData { context in
            let font=UIFont.systemFont(ofSize:11)
            let attributes: [NSAttributedString.Key:Any] = [.font:font,.foregroundColor:UIColor.black]
            var y: CGFloat=50
            func page() {
                context.beginPage(); y=50
                (title as NSString).draw(in:CGRect(x:44,y:y,width:507,height:30),withAttributes:[.font:UIFont.boldSystemFont(ofSize:19),.foregroundColor:UIColor.black]); y += 40
            }
            func draw(_ line: String) {
                if y + 17 > 790 { page() }
                (line as NSString).draw(at:CGPoint(x:44,y:y),withAttributes:attributes); y += 17
            }
            page()
            for paragraph in paragraphs {
                for block in paragraph.components(separatedBy:"\n") {
                    var line=""
                    for word in block.split(whereSeparator: { $0.isWhitespace }).map(String.init) {
                        let candidate=line.isEmpty ? word : line + " " + word
                        if (candidate as NSString).size(withAttributes:attributes).width <= 507 { line=candidate }
                        else {
                            if !line.isEmpty { draw(line); line="" }
                            for character in word {
                                let next=line + String(character)
                                if (next as NSString).size(withAttributes:attributes).width > 507 { draw(line); line=String(character) } else { line=next }
                            }
                        }
                    }
                    if !line.isEmpty { draw(line) }
                }
                y += 6
            }
        }
    }
}
