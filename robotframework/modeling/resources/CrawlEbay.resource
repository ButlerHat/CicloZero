*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  fix_bbox=${TRUE}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library   Collections


*** Keywords ***
Continue with user ${user}
    Click  //*[@id="userid"]
    Keyboard Input    type    ${user}
    Click  //*[@id="signin-continue-btn"]


    Click  //*[@id="user_pass"]
    Keyboard Input    type    ${password}
    Click  //*[@id="wp-submit"]
