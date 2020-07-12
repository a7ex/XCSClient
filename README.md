# XCSClient
GUI Client for Xcode Server written in SwiftUI

This is a client for a very special case. It communicates to an Xcode Server in an internal network. Since portforwarding to the Xcode Server was also not an option, and the only option we have to reach the mac, where the Xcode Server is running, is by connecting via ssh to a jumphost in the internal network, which allows then to normally communicate with the Xcode Server via http opn port 20343.

It is a pet project and it also works when connecting directly to an Xcode Server. In such a case however you can use Xcode right away. 
