*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  stealth_mode=${True}  captcha_api_key=${0}  record=${False}  console=${False}  presentation_mode=${True}  fix_bbox=${True}  output_path=${OUTPUT_DIR}${/}data  WITH NAME  Browser 
Library   OperatingSystem
Library   Collections
Library    ../keywords/count_excel.py
Resource  ./resources/CrawlEbay.resource
Variables  ../variables/credentials.py
Suite Setup  Browser.Add Task Library    CrawlEbay


*** Variables ***
${URL_EBAY}  https://www.ebay.com/mye/myebay/summary
${FILE_DIR}    /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero
${RETURN_FILE}  ${OUTPUT_DIR}${/}return_msg.txt
${COOKIES_DIR}  ${FILE_DIR}/browser/user_data_dir
${STOCK_EXCEL_PATH}  ${OUTPUT_DIR}${/}downloads${/}stock.quant.full.result.xlsx


*** Tasks ***
Update Ebay Stock
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
    Sleep  2  # Maybe already in my ebay and refresh
    Go to my ebay selling
    Click on Listings tab
    Go to active in right menu

    &{sku_total_grouped}  Get All Sku And Total Grouped By Id Modelo    ${STOCK_EXCEL_PATH}
    Create File    path=${RETURN_FILE}  content=Warning:${\n}

    FOR  ${sku_parent}  ${sku_total}  IN  &{sku_total_grouped}
        Log  Family ${sku_parent}:${\n}  console=${True}
        Append To File  path=${RETURN_FILE}    content=Family ${sku_parent}:${\n}
        
        Click on thrid dropdown in search  Custom label (SKU)  # Select
        Click on the dropdown next to Custom label (SKU)  is equal to
        ${custom_label}  Set Variable  ${sku_parent.replace('IP', 'iP')}-EC
        Write ${custom_label} in the field next to is equal to
        Search
        
        ${status}  ${msg}  Run Keyword And Ignore Error  Click on variations on the result
        Sleep  3

        IF  "${status}" == "FAIL"
            Log  ${custom_label} Custom label (SKU) not found in eBay  level=WARN  console=${True}
            Append To File  path=${RETURN_FILE}    content=${custom_label} Custom label (SKU) not found in eBay${\n}
            CONTINUE
        END

        # Set to 0 skus that not appear in sku_total as keys
        @{skus_in_page}  Get All Sku In Page
        @{skus_in_page_available}  Get All Sku In Page that has available quantity
        @{skus_in_stock}  Collections.Get Dictionary Keys    ${sku_total}
        

        # Get List that are in stock and not in page (notify)
        ${skus_not_in_page}  Evaluate  [sku for sku in ${skus_in_stock} if sku not in ${skus_in_page}]
        ${msg}  Set Variable  Stock not in eBay: ${skus_not_in_page}
        Log  ${msg}  level=WARN  console=${True}
        Append To File  path=${RETURN_FILE}    content=${msg}${\n}

        # Get List that are in page with availability and not in stock. Set to 0
        ${skus_not_in_stock}  Evaluate  [sku for sku in ${skus_in_page_available} if sku not in ${skus_in_stock}]
        ${msg}  Set Variable  Skus in eBay set to 0: ${skus_not_in_stock}
        Log  ${msg}  console=${True}
        Append To File  path=${RETURN_FILE}    content=${msg}${\n}
        FOR  ${sku}  IN  @{skus_not_in_stock}
            Click on the cell in ${sku} row and available quantity column
            Click on the edit icon in the cell  ${sku}
            Write quantity 0
            Click on submit in the popover
            Wait until popover is gone
        END

        # Get List to update with new stock
        ${skus_to_not_update}  Evaluate  [sku for sku in ${skus_in_stock} if sku not in ${skus_in_page}]
        Remove From Dictionary    ${sku_total}    @{skus_to_not_update}
        ${msg}  Set Variable  Skus update: ${sku_total}
        Log  ${msg}  console=${True}
        Append To File  path=${RETURN_FILE}    content=${msg}${\n}
        FOR  ${sku}  ${total}  IN  &{sku_total}
            Click on the cell in ${sku} row and available quantity column
            Click on the edit icon in the cell  ${sku}
            Write quantity ${total}
            Click on submit in the popover
            Wait until popover is gone
            
        END

        Append To File  path=${RETURN_FILE}    content=${\n}
        Go to active in right menu

    END

