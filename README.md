# ArtifactBundleGen (Beta)

Generates Artifact Bundle from Swift Package (Executable only)

## Example

```sh
# Go to Package directory. it is expeced that ArtifactBundleGen is added as command plugin in Package.swift
$ cd some-awesome-tool

# Call build command
$ swift build -c debug --arch arm64 --arch x86_64

# .build is generated

# Call command
$ swift package generate-artifact-bundle --package-version 0.5.11 --package-name some-awesome-tool --build-config debug --build-folder .build

$ ls
> some-awesome-tool.artifactbundle

# zip it and release!
$ zip -r some-awesome-tool.artifactbundle.zip some-awesome-tool.artifactbundle
```

## Usase
### 1. Add ArtifactBundleGen as plugin in Package.swift

```swift
let package = Package(
    name: "XcodeGen",
    products: [
        // ... some products
    ],
    dependencies: [
        // ... some dependencies
        .package(url: "https://github.com/freddi-kit/ArtifactBundleGen.git", .exact("0.0.1"))
    ],

```

### 2. Build your product in Shell

```sh
# Call build command
$ swift build -c debug --arch arm64 --arch x86_64
```


### 3. Call ArtifactBundleGen

```sh
$ swift package generate-artifact-bundle --package-version {version} --package-name {tool_name} --build-config {config} --build-folder {folder}
```

{tool_name}.artifactbundle will be generated!

#### Opitions
- --package-name: Name of Aritfact Bundle. Please specify executable tool's name
- --build-config: build config. `debug` or `release`

##### optionals
- --package-version: version of package (default is 1.0.0)
- --build-folder: version of package (default is .build)


### 4. Zip Artifact Bundle and release the zip!

```sh
$ zip -r {tool_name}.artifactbundle.zip {tool_name}.artifactbundle
```


## TODOs
- [ ] include LICENSE file
- [ ] Suport other type
