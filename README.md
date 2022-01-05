# `installed-simulators`

A small command line utility that will query the installed simulators on the given machine,
and then generate a file that can be used to easily specify `previewDevice()`s in SwiftUI.

## Brief

`installed-simulators` is designed to be run as a pre-build step, so the file with all
the simulators is automatically updated on every build.

Once the file is created, you can do something like this:

```swift
// Simulator.swift, generated by this project.
enum Simulator {
    // ...
    static let iPhone13Pro = PreviewDevice(rawValue: "iPhone 13 Pro")
    // ...
}

// SomeView.swift, a part of your project.
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

## Options

Everything below is optional; defaults are provided.

* `-h` or `--help`: Show help
* `--export-path <export path>`  
  Specifies where the file should be created. If a filename is provided, it is ignored.
  Defaults to the current directory.
* `--type-name <type name>`  
  The name of the `enum` that is created; this is also the filename. Defaults to `Simulator`.
* `--xcrunpath <xcrun path>`  
  The path to `xcrun`. Defaults to `/usr/bin/xcrun`.
* `--version`  
  Shows the version number.

## Installation in Xcode

This is the quick-and-dirty version of installation instrucitons; you may wish to make different choices, such as a different emitted filename or placing it in a different directory. That is left as an exercise for the reader.

0. Build a binary &mdash; or get one from [Releases](https://github.com/cliss/installed-simulators/releases) &mdash; and put it in your project folder, peer with your `xcodeproj`.
1. Open your project in Xcode
2. Click on your project in the Project Navigator
3. Select your target in the sidebar
4. Click the `+` button

<img width="1000" alt="Screen_Shot_2022-01-05_at_9_29_31_AM" src="https://user-images.githubusercontent.com/282460/148234761-b2ba6e3f-0be3-491f-bb19-7ed30c3496d8.png">

5. Select `New Run Script Phase`
6. Enter the following script, replacing `project-dir` for your project's directory:  
   `$SRCROOT/installed-simulators --export-path ./project-dir`
7. Move that new `Run Script` phase toward the top of your list of operations; generally speaking, just below `Dependencies` is appropriate.
8. Once you've built at least once, add the newly created file (defaults to `Simulator.swift`) to your project as you would any other file
9. Now you can easily do SwiftUI previews for other devices!
