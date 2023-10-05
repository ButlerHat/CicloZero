*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  stealth_mode=${True}  captcha_api_key=${0}  record=${False}  console=${False}  presentation_mode=${True}  fix_bbox=${TRUE}  output_path=${OUTPUT_DIR}${/}data  WITH NAME  Browser 
Library    ./robotframework/keywords/count_excel.py
Library    OperatingSystem
Resource   ./robotframework/modeling/resources/CrawlEbay.resource
Suite Setup  Setup Suite


*** Variables ***
${URL_EBAY_SIGNIN}  https://signin.ebay.com
${URL_EBAY}  https://www.ebay.com/mye/myebay/summary
${COOKIES_DIR}  ${OUTPUT_DIR}/browser/user_data_dir
${STATE_JSON}  ${OUTPUT_DIR}/browser/state/cookies.json
# ${OUTPUT_DIR}   /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero


*** Tasks ***
SetCookiesInEbay
    Comment  Obtener los unshipped de Ebay
    ${old_timeout}  Set Browser Timeout    1m
    Browser.New Stealth Persistent Context   userDataDir=${COOKIES_DIR}   browser=chromium  url=${URL_EBAY}
    Browser.Add All Cookies From State  ${STATE_JSON}
    Browser.Close Browser

    Browser.New Stealth Persistent Context   userDataDir=${COOKIES_DIR}   browser=chromium  url=${URL_EBAY}
    Set Browser Timeout    ${old_timeout}

    ${not_logged}  Check if not logged in
    IF  ${not_logged}  Fail  Not logged in Ebay


*** Keywords ***

Setup Suite
    [Tags]  no_record
    Browser.Add Task Library  CrawlAmazon  CrawlOdoo  CrawlWoocommerce  CrawlEbay  StockEbay  StockOdoo  StockAmazon  StockWoocommerce
    OperatingSystem.Remove Directory    path=${OUTPUT_DIR}${/}browser/screenshots    recursive=${TRUE}
    OperatingSystem.Remove Directory    path=${OUTPUT_DIR}${/}browser/traces    recursive=${TRUE}
