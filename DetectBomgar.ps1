$bomgarApp="C:\ProgramData\bomgar-scc*\bomgar-scc.exe"


IF (test-path $bomgarApp){
    "OK";return 0
    } else {
    "doesn't exist";return
    }


