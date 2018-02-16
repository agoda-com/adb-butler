# adb-butler
adb-butler is one of the components of [android-farm](https://github.com/agoda-com/android-farm) that runs adb server as a side-car container in kubernetes deployment of OpenSTF providers.

# Features
- self-healing
  - reconnect devices missing in adb server by rebinding the usb driver
  - reconnect devices missing or unstable in OpenSTF by restarting the adb connection
- clean-up rethinkdb for temporary emulators that are no longer available
- adding notes to provided devices
- automatic installation of test-butler for emulators

# Building

```console
$ export DOCKER_USER=user
$ export DOCKER_PASS=password
$ make PROXY=docker-registry-url/ build tag login push
```

# License

adb-butler is open source and available under the [Apache License, Version 2.0](LICENSE).

Android SDK components are available under the [Android Software Development Kit License](https://developer.android.com/studio/terms.html)
