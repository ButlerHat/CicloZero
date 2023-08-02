*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  presentation_mode=${True}  fix_bbox=${TRUE}  console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Resource  ./resources/CrawlEbay.resource
Variables  ../variables/credentials.py
Suite Setup  Browser.Add Task Library    CrawlEbay


*** Variables ***
${URL_EBAY}  https://signin.ebay.com


*** Tasks ***
Test Ebay Stock
    [Documentation]  Creacion de excel para hacer el control de stock en Ebay
    Get Processing Ebay 


*** Keywords ***
Get Processing Ebay
    Comment  Obtener los unshipped de Ebay
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    Wait New Page   ${URL_EBAY}  wait=${1}

    CrawlEbay.Login with user ${ebay_user} and pass ${ebay_pass}    
