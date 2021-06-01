import AppKit
import Accelerate

func significantlyDifferentImages(_ left: Data, _ right: CGImage) -> Bool {
    true
}

func imageBuffer(cgImage: CGImage) -> vImage_Buffer {
    // TODO: fail on try
    try! vImage_Buffer(
        cgImage: cgImage,
        format: getFormat(cgImage)
    )
}

func imageBuffer(data: Data) -> vImage_Buffer {
    imageBuffer(nsImage: NSImage(data: data)!)
}
func imageBuffer(url: URL) -> vImage_Buffer {
    // TODO: fail on unwrap
    let nsImage = NSImage(contentsOf: url)!
    return imageBuffer(cgImage: cgImage(nsImage))
}

func imageBuffer(nsImage: NSImage) -> vImage_Buffer {
    imageBuffer(cgImage: cgImage(nsImage))
}


func cgImage(_ nsImage: NSImage) -> CGImage {
    nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!
}

func getFormat(_ cgImage: CGImage) -> vImage_CGImageFormat {
    vImage_CGImageFormat(cgImage: cgImage)!
}
