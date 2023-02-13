#if os(macOS)
import AppKit
#endif
import Accelerate
import CoreImage
import CoreImage.CIFilterBuiltins

func diff(_ old: Data, _ new: CGImage, size: CGSize) -> SnapshottingImage {
    diff(SnapshottingImage(data: old)!, SnapshottingImage(cgImage: new, size: size))
}

func diff(_ old: CGImage, _ new: CGImage) -> CIFilter & CIColorAbsoluteDifference {
    diff(CIImage(cgImage: old), CIImage(cgImage: new))
}

func diff(_ old: CIImage, _ new: CIImage) -> CIFilter & CIColorAbsoluteDifference {
    let differenceFilter = CIFilter.colorAbsoluteDifference()
    differenceFilter.inputImage = old
    differenceFilter.inputImage2 = new
    return differenceFilter
}

func histogramData(_ ciImage: CIImage) -> Data {
    let hist = CIFilter.areaHistogram()
    hist.inputImage = ciImage
    hist.setValue(CIVector(cgRect: ciImage.extent), forKey: kCIInputExtentKey)
    return hist.value(forKey: "outputData") as! Data
}

func maxColorDiff(histogram: [UInt32]) -> Float {
    let rgb = stride(from: 0, to: histogram.count, by: 4).map { (index: Int)-> UInt32 in
        histogram[index] + histogram[index + 1] + histogram[index + 2]
    }
    if let last = rgb.lastIndex(where: { $0 > 0 }) {
        return Float(last) / Float(rgb.count)
    } else {
        return 1.0
    }
}
func histogram(ciImage: CIImage) -> [UInt32] {
    let data = histogramData(ciImage)
    let count = data.count / MemoryLayout<UInt32>.stride
    let result: [UInt32] = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
        let pointer = bytes.bindMemory(to: UInt32.self)
        return Array(UnsafeBufferPointer(start: pointer.baseAddress, count: count))
    }
    return result
}

func diff(_ old: SnapshottingImage, _ new: SnapshottingImage) -> SnapshottingImage {
    let differenceFilter = diff(old.cgImage!, new.cgImage!)
    let unionRect = CGRect(origin: .zero, size: old.size)
        .union(.init(origin: .zero, size: new.size))

    return differenceFilter.outputImage!.image(size: unionRect.size)
}

func significantlyDifferentImages(_ left: Data, _ right: CGImage) -> Bool {
    var leftBuffer = imageBuffer(data: left)
    var rightBuffer = imageBuffer(cgImage: right)
    defer {
        leftBuffer.free()
        rightBuffer.free()
    }
    guard leftBuffer.height == rightBuffer.height, leftBuffer.width == rightBuffer.width else {
        return true
    }
    let leftPixels = floatPixels(&leftBuffer)
    let rightPixels = floatPixels(&rightBuffer)
    let difference = vDSP.subtract(leftPixels, rightPixels)
    return vDSP.maximumMagnitude(difference) > 4 ||
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
    imageBuffer(image: SnapshottingImage(data: data)!)
}
func imageBuffer(url: URL) -> vImage_Buffer {
    let image = url.image()
    return imageBuffer(cgImage: image.cgImage!)
}

func imageBuffer(image: SnapshottingImage) -> vImage_Buffer {
    imageBuffer(cgImage: image.cgImage!)
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

#if os(macOS)
extension NSImage {
    var cgImage: CGImage? {
        cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
}

extension URL {
    func image() -> NSImage {
        NSImage(contentsOf: self)!
    }
}

#elseif os(iOS)
extension UIImage {
    convenience init(cgImage: CGImage, size: CGSize) {
        // size changes is not supported for iOS
        self.init(cgImage: cgImage)
    }
}

extension URL {
    func image() -> UIImage {
        UIImage(contentsOfFile: path)!
    }
}

#endif
