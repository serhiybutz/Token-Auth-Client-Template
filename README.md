## iOS app template with token-based authentication

<p align="center">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-5.6-brightgreen.svg" alt="Swift 5.6">
    </a>
</p>

<br/>

An iOS app that uses token-based authentication. The server side is represented by the repository [Token-Auth-Server-Template](https://github.com/serhiybutz/Token-Auth-Server-Template.git), which is a Vapor server.

### Features

- User *sign-in form* screen with username+password authentication with the server providing the *authentication token*.
- *Biometric authentication* included.
- User *sign-up form* screen.
- *Validation of form fields*, both *local* and *remote*.
- *Form navigation* keyboard toolbar.
- Home page screen with demo of some *client-server-based functionality* like retrieving user’s data and filtering it.
- *Modular architecture* + *dependency injection container*.

### How to run

1. Clone the repository on the command line: `git clone https://github.com/SerhiyButz/Token-Auth-Client-Template.git`.
2. Open the client app in Xcode (`open TokenAuthClientTemplate.xcodeproj`) and run it by hitting `CMD+r`.
3. After starting the application, use "Server Settings" (in the upper right corner) to configure the server settings.

### License

This project is licensed under the MIT license.
