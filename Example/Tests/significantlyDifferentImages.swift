import AppKit
import Accelerate
import CoreImage

func diff(_ old: Data, _ new: CGImage, size: NSSize) -> NSImage {
    diff(NSImage(data: old)!, NSImage(cgImage: new, size: size))
}


func diff(_ old: NSImage, _ new: NSImage) -> NSImage {
    let oldCiImage = CIImage(cgImage: old.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
    let newCiImage = CIImage(cgImage: new.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
    let differenceFilter = CIFilter(name: "CIDifferenceBlendMode")!
    differenceFilter.setValue(oldCiImage, forKey: kCIInputImageKey)
    differenceFilter.setValue(newCiImage, forKey: kCIInputBackgroundImageKey)
    let maxSize = CGSize(
        width: max(old.size.width, new.size.width),
        height: max(old.size.height, new.size.height)
    )
    let rep = NSCIImageRep(ciImage: differenceFilter.outputImage!)
    let difference = NSImage(size: maxSize)
    difference.addRepresentation(rep)
    return difference
}

func significantlyDifferentImages(_ left: Data, _ right: CGImage) -> Bool {
    var leftBuffer = imageBuffer(data: left)
    var rightBuffer = imageBuffer(cgImage: right)
    defer {
        leftBuffer.free()
        rightBuffer.free()
    }
    let leftPixels = floatPixels(&leftBuffer)
    let rightPixels = floatPixels(&rightBuffer)
    let difference = vDSP.subtract(leftPixels, rightPixels)
    return vDSP.maximumMagnitude(difference) > 10 ||
        vDSP.rootMeanSquare(difference) > 0.5
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

func floatPixels(_ imageBuffer: inout vImage_Buffer) -> [Float] {
    var floatPixels: [Float]
    let count = Int(imageBuffer.width) * Int(imageBuffer.height)
    let totalCount = count * 4
    let width = Int(imageBuffer.width)
    floatPixels = [Float](unsafeUninitializedCapacity: totalCount) { buffer, initializedCount in
        var minFloat = Float(UInt8.min)
        var maxFloat = Float(UInt8.max)
        var floatBuffers: [vImage_Buffer] = (0...3).map {
            vImage_Buffer(data: buffer.baseAddress!.advanced(by: $0 * count),
                          height: imageBuffer.height,
                          width: imageBuffer.width,
                          rowBytes: width * MemoryLayout<Float>.size)
        }

        vImageConvert_ARGB8888toPlanarF(&imageBuffer,
                                        &floatBuffers[0],
                                        &floatBuffers[1],
                                        &floatBuffers[2],
                                        &floatBuffers[3],
                                        &minFloat, &maxFloat,
                                        vImage_Flags(kvImageDoNotTile))

        initializedCount = totalCount
    }
    return floatPixels
}
