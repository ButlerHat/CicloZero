*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  fix_bbox=${TRUE}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library   Collections


*** Keywords ***
Continue with user ${user} and password ${password}
    Click  //*[@id="userid"]
    Keyboard Input    type    ${user}
    Click  //*[@id="signin-continue-btn"]
    Sleep  1
    Click  //*[@id="pass"]
    Keyboard Input    type    ${password}
    Click  //*[@id="sgnBt"]

Click in get text
    Click  //*[@id="smsWithCode-btn"]

Click in the first box
    Click  //*[@id="pin-boxes"]//input[1]

Type text ${code}
    Keyboard Input    type  ${code}

CLick on verify button
    Click  //*[@id="verify-btn"]