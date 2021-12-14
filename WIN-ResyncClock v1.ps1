start-service W32time
w32tm /config /manualpeerlist:time.windows.com /syncfromflags:manual /update
w32tm /resync
stop-service w32time