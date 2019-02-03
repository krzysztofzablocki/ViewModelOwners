# ViewModelOwners

[![Platforms](https://img.shields.io/cocoapods/p/ViewModelOwners.svg)](https://cocoapods.org/pods/ViewModelOwners)
[![License](https://img.shields.io/cocoapods/l/ViewModelOwners.svg)](https://raw.githubusercontent.com/krzysztofzablocki/ViewModelOwners/master/LICENSE)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/ViewModelOwners.svg)](https://cocoapods.org/pods/ViewModelOwners)

[![Travis](https://img.shields.io/travis/krzysztofzablocki/ViewModelOwners/master.svg)](https://travis-ci.org/krzysztofzablocki/ViewModelOwners/branches)
[![codecov](https://codecov.io/gh/krzysztofzablocki/ViewModelOwners/branch/master/graph/badge.svg)](https://codecov.io/gh/krzysztofzablocki/ViewModelOwners)

Two protocols that simplify MVVM integration and help you manage subscription for side-effects.

- No need to create `viewModel` property
- Don't need to deal with `nil` state if programmer forgot to set `viewModel` using setter injection (for `Reusable` views)
- Automatic management of subscriptions (via `Disposable` containers)
- Consistent architecture / side-effects design that opens up door for useful dev tooling

```swift
class MyViewController: UIViewController, NonReusableViewModelOwner {
    func didSetViewModel(_ vm: MyViewModelProtocol, disposeBag: DisposeBag) {
        ...
    }
}
```

[Read my blog post for details about this technique](http://merowing.info/2016/08/better-mvvm-setup-with-pop-and-runtime/)



- [Requirements](#requirements)
- [Installation](#installation)
- [Integration with FRP libraries](#integration)
- [Usage](#usage)
- [License](#license)

## Requirements

- iOS 8.0+ / Mac OS X 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 10.0+

## Installation

### Dependency Managers
<details>
  <summary><strong>CocoaPods</strong></summary>

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate ViewModelOwners into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'ViewModelOwners', '~> 1.0.0'
```

Then, run the following command:

```bash
$ pod install
```

</details>

<details>
  <summary><strong>Carthage</strong></summary>

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate ViewModelOwners into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "krzysztofzablocki/ViewModelOwners" ~> 1.0.0
```

</details>

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate ViewModelOwners into your project manually.

<details>
  <summary><strong>Git Submodules</strong></summary><p>

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add ViewModelOwners as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/krzysztofzablocki/ViewModelOwners.git
$ git submodule update --init --recursive
```

- Open the new `ViewModelOwners` folder, and drag the `ViewModelOwners.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `ViewModelOwners.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `ViewModelOwners.xcodeproj` folders each with two different versions of the `ViewModelOwners.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from.

- Select the `ViewModelOwners.framework`.

- And that's it!

> The `ViewModelOwners.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

</p></details>

<details>
  <summary><strong>Embedded Binaries</strong></summary><p>

- Download the latest release from https://github.com/krzysztofzablocki/ViewModelOwners/releases
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Add the downloaded `ViewModelOwners.framework`.
- And that's it!

</p></details>

## Integration
<details>
  <summary><strong>RxSwift</strong></summary><p>

Simply add this anywhere in your project to make Swift happy:

```swift
extension DisposeBag: ViewModelOwnerDisposeBagProtocol {
    private final class DisposableWrapper: Disposable {
        let disposable: ViewModelOwnerDisposable
        
        init(_ disposable: ViewModelOwnerDisposable) {
          self.disposable = disposable
        }

        func dispose() {
            disposable.dispose()
        }
    }

    public func add(_ disposable: ViewModelOwnerDisposable) {
        insert(DisposableWrapper(disposable: disposable))
    }
}
```

and you can now use ViewModelOwners with the `RxSwift` disposables: 

```swift
func didSetViewModel(_ viewModel: ViewModel, disposeBag: DisposeBag) {
```

</p></details>

<details>
  <summary><strong>ReactiveSwift</strong></summary><p>

Simply add this anywhere in your project to make Swift happy:

```swift
extension CompositeDisposable: ViewModelOwnerManualDisposeBagProtocol {
    private final class Wrapper: Disposable {
        var isDisposed: Bool
        let disposable: ViewModelOwnerDisposable

        init(_ disposable: ViewModelOwnerDisposable) {
            self.disposable = disposable
            isDisposed = false
        }

        func dispose() {
            disposable.dispose()
            isDisposed = true
        }
    }

    public func add(_ disposable: ViewModelOwnerDisposable) {
        add(Wrapper(disposable))
    }
}
```

and you can now use ViewModelOwners with the `ReactiveSwift`: 

```swift
func didSetViewModel(_ viewModel: ViewModel, disposeBag: CompositeDisposable) {
```

</p></details>

<details>
  <summary><strong>Other libraries</strong></summary><p>

You simply need to conform `LibraryDisposeBag` object to either `ViewModelOwnerManualDisposeBagProtocol` or `ViewModelOwnerManualDisposeBagProtocol`.

**Note: use `manual` variant if your `DisposeBag` container doesn't automatically dispose on dealloc.**:

You can use it in your code:

```swift
func didSetViewModel(_ viewModel: ViewModel, disposeBag: LibraryDisposeBag) {
```

</p></details>


## Usage

## Contributing

Issues and pull requests are welcome!

## Author

Krzysztof Zablocki [@merowing_](https://twitter.com/merowing_)

## License

ViewModelOwners is released under the MIT license. See [LICENSE](https://github.com/krzysztofzablocki/ViewModelOwners/blob/master/LICENSE) for details.
