# XCSClient
GUI Client for Xcode Server written in SwiftUI

This is a client for a very special case:
It communicates to an Xcode Server in an internal network.

Since portforwarding to the Xcode Server was also not an option, the only option we have to reach the mac, where the Xcode Server is running, is by connecting via ssh to a jumphost in the internal network, which allows then to normally communicate with the Xcode Server via http on port 20343.

It is a pet project and it also works when connecting directly to an Xcode Server. In such a case however you can use Xcode right away in the first place, although you might find certain things easier with this tool.

### Usage
Mac OS 11 "Big Sur" and above: Compile the latest version of the application (or download the latest notarized [binary](https://github.com/a7ex/XCSClient/releases/latest/download/XCSClient.app.zip)) and launch.
For older Mac OS Versions < 11: Use the branch *release/pre-macos-11-release* (or download the compiled [binary for older Mac OS](https://github.com/a7ex/XCSClient/releases/download/1.2/XCSClient.app.zip)) and launch.

To connect to a Xcode Server regularly you need the IP address or hostname of the Mac, which runs the Xcode Server.

If you can only connect to the server by ssh, provide the username and IP Adress or hostname of the SSH jumphost. (Note for now there is no password support for ssh. You must transfer your public key to the remote server, which is anyway a safer approach.)

Some of the calls to the Xcode Server require authentication (POST and PUT commands, which trigger changes). For those commands the password for the machine running the xcode server can be stored either in the Keychain or in a netrc file on the jumphost, so that curl can read it from there.

Example netrc file:
```
machine 127.0.0.1 login <user-name-of-the-user-running-the-xcode-server> password <password-for-that-user>
```
You can enter a value of the path to this netrc file relative to your home foider. If you leave the `netrc` field empty, you will be prompted to enter the credentials (user name and login password of the Mac running the Xcode  server), which will then be securely stored in your Keychain.
