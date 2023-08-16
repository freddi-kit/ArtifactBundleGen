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
$ swift package generate-artifact-bundle --package-version 0.5.11 --executable-name some-awesome-tool --build-config debug --build-folder .build

$ ls
> some-awesome-tool.artifactbundle.zip
```

## Usase
### 1. Add ArtifactBundleGen as plugin in Package.swift

```swift
let package = Package(
    name: "SomeTools",
    products: [
        // ... some products
    ],
    dependencies: [
        // ... some dependencies
        .package(url: "https://github.com/freddi-kit/ArtifactBundleGen.git", .exact("0.0.2"))
    ],

```

### 2. Build your product in Shell

```sh
# Call build command
$ swift build -c debug --arch arm64 --arch x86_64
```


### 3. Call ArtifactBundleGen

```sh
$ swift package generate-artifact-bundle --package-version {version} --executable-name {executable-name} --build-config {config} --build-folder {folder}
```

{tool_name}.artifactbundle will be generated!

#### Opitions
- --executable-name: Name of Aritfact Bundle. Please specify executable product's `name` string

```swift
let package = Package(
    ...
    products: [
        // here
        .executable(name: {executable-name}, targets: [...]),
    ],
```

- --build-config: build config. `debug` or `release`

##### optionals
- --package-version: version of package (default is 1.0.0)
- --build-folder: version of package (default is .build)


### 4. Complete!

Zip file is generated!

```sh
$ ls 
> {tool_name}.artifactbundle.zip
```


## TODOs
- [ ] Suport XCFramework
