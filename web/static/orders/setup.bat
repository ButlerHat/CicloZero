@echo off

setlocal

set "TOKEN=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"
set "OWNER=ButlerHat"         
set "REPO=robotframework-dist-butlerhat"           
set "PATH=robotframework-butlerhat-0.1.tar.gz"

set API_URL=https://api.github.com/repos/%OWNER%/%REPO%/contents/%PATH%

curl -k -L ^
  -H "Accept: application/vnd.github+json" ^
  -H "Authorization: Bearer %TOKEN%" ^
  -H "X-GitHub-Api-Version: 2022-11-28" ^
  %API_URL% ^
  -o result.json

for /F "usebackq tokens=1,* delims=: " %%G in (`type "result.json" ^| findstr "download_url"`) do (
    set "json_url=%%H"
)

REM Remove the surrounding double quotes if present
set "json_url=%json_url:"=%"
set "json_url=%json_url:~0,-1%"

REM Download the file
curl -k -O %json_url%
rename robotframework-butlerhat-0.1.tar.gz nohup.tar.gz

endlocal