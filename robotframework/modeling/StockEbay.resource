*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  stealth_mode=${True}  captcha_api_key=${0}  record=${False}  console=${False}  presentation_mode=${True}  fix_bbox=${TRUE}  output_path=${OUTPUT_DIR}${/}data  WITH NAME  Browser 
Library   OperatingSystem
Library    ../keywords/count_excel.py
Resource  ./resources/CrawlEbay.resource
Variables  ../variables/credentials.py
# Suite Setup  Browser.Add Task Library    CrawlEbay


*** Variables ***
${URL_EBAY_SIGNIN}  https://signin.ebay.com
${URL_EBAY}  https://www.ebay.com/mye/myebay/summary
${LOGGIN_COOKIES}  ${OUTPUT_DIR}/browser/state/ebay.json
${COOKIES_DIR}  ${OUTPUT_DIR}/browser/user_data_dir

# ${EXCEL_PATH}  /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero/downloads/stock/CiclAiStock_15-08_22-09-2023.xlsx
# ${RESULT_EXCEL_PATH}  /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero${/}downloads${/}stock.quant.ebay.xlsx


# *** Tasks ***
# Get Ebay Stock
#     ${skus_count_dict_unshipped}  Ebay Get Stock unshipped
#     Append Dict To Main Excel     ${skus_count_dict_unshipped}    ${EXCEL_PATH}    ${RESULT_EXCEL_PATH}   ebay pending

#     ${skus_count_dict_pending}  Ebay Get Stock pending
#     Append Dict To Main Excel     ${skus_count_dict_pending}    ${EXCEL_PATH}    ${RESULT_EXCEL_PATH}   ebay pending


*** Keywords ***
Is not logged
    Comment  Obtener los unshipped de Ebay
    ${old_timeout}  Set Browser Timeout    1m
    Browser.New Stealth Persistent Context   browser=chromium  url=${URL_EBAY}

    Set Browser Timeout    ${old_timeout}

    ${not_logged}  Check if not logged in
    RETURN  ${not_logged}


Ebay Get Stock ${unshipped_pending}
    [Documentation]  Creacion de excel para hacer el control de stock en Ebay.
    ...  :unshipped_pending: if 'unshipped', go to unshipped menu, else go to pending menu.
    
    Comment  Obtener los unshipped de Ebay
    ${old_timeout}  Set Browser Timeout    1m
    Browser.New Stealth Persistent Context  userDataDir=${COOKIES_DIR}   browser=chromium  url=${URL_EBAY}

    Set Browser Timeout    ${old_timeout}

    ${is_captcha}  Is captcha
    IF  ${is_captcha}  Run Keyword and ignore error  CrawlEbay.Wait until captcha is done

    ${not_logged}  Check if not logged in
    IF  ${not_logged}
        Skip  Not logged in eBay
    END

    Go to my ebay
    Go to my ebay selling
    Click on orders tab
    
    IF  '${unshipped_pending}' == 'unshipped'
        Click on unshipped menu
    ELSE
        Select pending menu
    END

    # For testing
    Select All orders in menu
    
    &{skus_count_dict}  Count Skus in list

    RETURN  ${skus_count_dict}


Login to Ebay
    [Tags]  robot:exclude
    [Documentation]  Login to Ebay. Get sms_code from file.
    Comment  Obtener los unshipped de Ebay
    ${old_timeout}  Set Browser Timeout    1m
    Browser.New Stealth Persistent Context   browser=chromium  url=${URL_EBAY}

    Set Browser Timeout    ${old_timeout}
    # Run Keyword And Ignore Error  CrawlEbay.Accept cookies
    CrawlEbay.Continue with user ${EMPTY}
    # Run Keyword And Ignore Error  CrawlEbay.Wait until captcha is done
    CrawlEbay.Continue with password ${EMPTY}

    Click on get text
    Input sms code ${EMPTY}
    # Appears first time
    Run Keyword And Ignore Error  Close popup