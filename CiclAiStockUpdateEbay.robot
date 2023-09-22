*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  presentation_mode=${True}  fix_bbox=${TRUE}  record=${False}  console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library    Dialogs
Resource   robotframework/modeling/resources/CrawlEbay.resource
Variables  robotframework/variables/credentials.py


*** Variables ***
${URL_EBAY}  https://signin.ebay.com
${user}  ciclozero
${password}  eid6F9P5e2E89D


*** Test Cases ***
Login and save state
    [Documentation]  Login with Ebay
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    New Page   ${URL_EBAY}
    
    Dialogs.Execute Manual Step    Sign in. When 


Login with Ebay
    [Documentation]  Login with Ebay
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    New Page   ${URL_EBAY}

    Continue with user ${user} and password ${password}
    Click in get text
    # Obtener codigo de verificacion
    Click in the first box
    Type text ${code}
    CLick on verify button

    ${state_file}  Save Storage State
    

