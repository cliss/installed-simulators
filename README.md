# `installed-simulators`

A small command line utility that will query the installed simulators on the given machine,
and then generate a file that can be used to easily specify `previewDevice()`s in SwiftUI.

## Brief

`installed-simulators` is designed to be run as a pre-build step, so the file with all
the simulators is automatically updated on every build.

Once the file is created, you can do something like this:

```swift
// Simulator.swift
enum Simulator {
    // ...
    static var iPhone13Pro: PreviewDevice { PreviewDevice(rawValue: "iPhone 13 Pro") }
    // ...
}

// SomeView.swift
struct SomeView: View {
    var body: some View {
        Text("Hello, world")
    }
}

struct SomeViewPreviews: PreviewProvider {
    static var previews: some View {
        SomeView()
            .previewProvider(Simulator.iPhone13Pro)
    }
}
```

## Installation in Xcode

tbd

## To Do

- [ ] Add the below as Github issues
- [ ] Accept `xcrun` path as a parameter
- [ ] Accept output type name as a parameter
- [ ] Accept output file path as a parameter
- [ ] Return non-zero error codes upon error