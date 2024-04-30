// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "whisper",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .watchOS(.v4),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "whisper", targets: ["whisper"]),
    ],
    targets: [
        .target(name: "ggml",
                path: ".",
                exclude: [
                    "bindings",
                    "cmake",
                    "examples",
                    "models",
                    "samples",
                    "tests",
                    "CMakeLists.txt",
                    "ggml-cuda.cu",
                    "ggml-cuda.h",
                    "Makefile"
                ],
                sources: [
                    "ggml.c",
                    "ggml-alloc.c",
                    "ggml-backend.c",
                    "ggml-quants.c",
                    "ggml-metal.m"
                ],
                publicHeadersPath: "spm-headers-ggml",
                cSettings: [
                    .unsafeFlags(["-Wno-shorten-64-to-32", "-O3", "-DNDEBUG"]),
                    .define("GGML_USE_ACCELERATE"),
                    .unsafeFlags(["-fno-objc-arc"]),
                    .define("GGML_USE_METAL"),
                    .define("WHISPER_USE_COREML"),
                    .define("WHISPER_COREML_ALLOW_FALLBACK")
                    // NOTE: NEW_LAPACK will required iOS version 16.4+
                    // We should consider add this in the future when we drop support for iOS 14
                    // (ref: ref: https://developer.apple.com/documentation/accelerate/1513264-cblas_sgemm?language=objc)
                    // .define("ACCELERATE_NEW_LAPACK"),
                    // .define("ACCELERATE_LAPACK_ILP64")
                ],
                linkerSettings: [
                    .linkedFramework("Accelerate"),
                    .linkedFramework("CoreML")
                ]
               ),
        .target(
            name: "whisper",
            dependencies: [
                "ggml"
            ],
            path: ".",
            exclude: [
               "bindings",
               "cmake",
               "examples",
               "models",
               "samples",
               "tests",
               "CMakeLists.txt",
               "ggml-cuda.cu",
               "ggml-cuda.h",
               "Makefile"
            ],
            sources: [
                "whisper.cpp",
                "coreml/whisper-decoder-impl.m",
                "coreml/whisper-encoder-impl.m",
                "coreml/whisper-encoder.mm"
            ],
            resources: [.process("ggml-metal.metal")],
            publicHeadersPath: "spm-headers",
            cSettings: [
                .unsafeFlags(["-Wno-shorten-64-to-32", "-O3", "-DNDEBUG"]),
                .define("GGML_USE_ACCELERATE"),
                .define("GGML_USE_METAL"),
                .define("WHISPER_USE_COREML"),
                .define("WHISPER_COREML_ALLOW_FALLBACK")
                // NOTE: NEW_LAPACK will required iOS version 16.4+
                // We should consider add this in the future when we drop support for iOS 14
                // (ref: ref: https://developer.apple.com/documentation/accelerate/1513264-cblas_sgemm?language=objc)
                // .define("ACCELERATE_NEW_LAPACK"),
                // .define("ACCELERATE_LAPACK_ILP64")
            ],
            linkerSettings: [
                .linkedFramework("Accelerate"),
                .linkedFramework("CoreML")
            ]
        )
    ],
    cxxLanguageStandard: .cxx11
)
