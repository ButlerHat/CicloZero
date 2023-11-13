*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  stealth_mode=${True}  record=${False}  console=${False}  presentation_mode=${True}  fix_bbox=${False}  output_path=${OUTPUT_DIR}${/}data  WITH NAME  Browser 
Library    OTP
Library    Collections
# Library   ButlerRobot.AILanguageLibrary
Library   ../keywords/utils.py
Library   ../keywords/count_excel.py
Resource  ./resources/CrawlAmazon.resource
Variables  ../variables/credentials.py


*** Variables ***
# ${OUTPUT_DIR}  /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero/data
${URL_AMAZON}  https://sellercentral.amazon.es


*** Keywords ***

Get Unshipped Amazon
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    ${old_timeout}  Set Browser Timeout    30
    Wait New Page   ${URL_AMAZON}  wait=${1}

    Click on log in at the top right
    CrawlAmazon.Login with user ${amazon_user} and pass ${amazon_pass}
    Set Browser Timeout    timeout=${old_timeout}
    AI.Click on Indicar contraseña de un solo uso desde la app de verificación
    AI.Click on "Enviar contraseña de un solo uso"

    ${otp_key}=    Get OTP    ${otp_amazon}
    Should Match Regexp       ${otp_key}        \\d{6}
    Type number "${otp_key}" in field Indicar contraseña de un solo uso
    # Check "No vuelvas a pedir un codigo en este navegador"
    Click on "Iniciar sesion"
    Scroll in Select Account until "Spain" is visible and click
    Click on "Select Account"

    Click on menu icon at top left
    Click on "Orders" menu at the left
    Click on "Order Reports" submenu

    Click on "Unshipped Orders" in the menu
    Click on "Request" yellow button

    ${dl_promise}  Promise To Wait For Download    saveAs=${OUTPUT_DIR}${/}downloads${/}unshipped.xlsx
    ${init_time}  Evaluate  time.time()
    WHILE  ${TRUE}
        Click at "Refresh" button at the top right of the table
        Sleep  3
        ${bbox}  Get element bouding box at first row and "download" column at Download Report table
        ${txt}  Get Text From Bbox    selector_bbox=${bbox}
        ${contains}  Evaluate  "download" in "${txt.lower()}"
        # Check if download is in text
        IF  ${contains}
            ${dl_promise}  Promise To Wait For Download    saveAs=${OUTPUT_DIR}${/}downloads${/}unshipped.tsv
            Click at "download" button at first row at Download Report table
            BREAK
        END
        
        ${contains_no_orders}  Evaluate  "no orde" in "${txt.lower()}"
        IF  ${contains_no_orders}  RETURN  False

        Sleep  30
        # Check timeout
        ${curr_time}  Evaluate  time.time()
        ${diff_time}  Evaluate  ${curr_time} - ${init_time}
        IF  ${diff_time} > 960  # 16 minutes
            FAIL  Timeout
        END
    END

    Comment  Descargar tsv. Esperar a que se descargue
    ${amazon_tsv_obj}  Wait For  ${dl_promise}

    RETURN  ${amazon_tsv_obj}


Get Pending Amazon
    Comment  Obtener inventario de Odoo
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    ${old_timeout}  Set Browser Timeout    30
    Wait New Page   ${URL_AMAZON}  wait=${1}

    Click on log in at the top right
    CrawlAmazon.Login with user ${amazon_user} and pass ${amazon_pass}
    Set Browser Timeout    timeout=${old_timeout}
    AI.Click on Indicar contraseña de un solo uso desde la app de verificación
    AI.Click on "Enviar contraseña de un solo uso"
    
    ${otp_key}=    Get OTP    ${otp_amazon}
    Should Match Regexp       ${otp_key}        \\d{6}
    Type number "${otp_key}" in field Indicar contraseña de un solo uso
    # Check "No vuelvas a pedir un codigo en este navegador"
    Click on "Iniciar sesion"
    Scroll in Select Account until "Spain" is visible and click
    Click on "Select Account"

    Click on menu icon at top left
    Click on "Orders" menu at the left
    Click "Manage orders" submenu

    Click on "Pending" tab
    Change Results per page to 100
    
    Set Browser Wait Time  0
    # For recording
    ${tmp}  How many orders are Pending?
    # Counting rows, not orders
    ${num_pending}  How many phones are there?

    Comment  Count number of times that appears each SKU
    &{orders_sku}  Create Dictionary
    ${NEXT_OBSERVATION}  Set Variable
    Set Global Variable    ${NEXT_OBSERVATION}
    ${num_pending}  Evaluate  ${num_pending} +1

    # This Javascript is for removing warning in the table and remove double orders
    Remove Warnings In Table
    Duplicate td in double orders
    Sleep  1

    FOR  ${i}  IN RANGE  1  ${num_pending}
        ${ord_num}  Get Ordinal    number=${i}
        ${2nd_col_num}  Which is the number of the second column of the ${ord_num} row?
        ${sku}  Which is the SKU of the order ${2nd_col_num}?
        ${qty_sku}  Which quantity has the order ${2nd_col_num}?

        ${NEXT_OBSERVATION}  Set Variable  The order is under the ${2nd_col_num} order
        Set Global Variable    ${NEXT_OBSERVATION}
        TRY
            ${sku_count}  Get From Dictionary  ${orders_sku}  ${sku}
        EXCEPT
            ${sku_count}  Set Variable  0
        END
        ${new_sku_count}  Evaluate  ${sku_count} + ${qty_sku}
        Set To Dictionary    ${orders_sku}    ${sku}    ${new_sku_count}
    END

    RETURN  ${orders_sku}


# === Modeling === #

Modelate Table
    Open Browser  ${URL_AMAZON}  pause_on_failure=${FALSE}
    Click on log in at the top right
    Login with user ${amazon_user} and pass ${amazon_pass}
    ${otp_key}=    Get OTP    ${otp_amazon}
    Should Match Regexp       ${otp_key}        \\d{6}
    Type number "${otp_key}" in field Indicar contraseña de un solo uso
    Check "No vuelvas a pedir un codigo en este navegador"
    Click on "Iniciar sesion"
    Scroll in Select Account until "Spain" is visible and click
    Click on "Select Account"

    Click on menu icon at top left
    Click on "Orders" menu at the left
    Click on "Order Reports" submenu

    Click on "Unshipped Orders" in the menu
    Click on "Request" yellow button
    Click at "Refresh" button at the top right of the table

    FOR  ${ord_num}  IN  first  second  third  fourth  fifth  sixth  seventh  eighth  ninth  tenth
        FOR  ${column}  IN  Report Type  Batch ID  Date Range Covered  Date and Time Requested  Date and Time Completed  Report Status  Download
            ${bbox}  Get element bouding box at ${ord_num} row and "${column}" column at Download Report table
            ${txt}  Get Text From Bbox    selector_bbox=${bbox}
            Log To Console    ${txt}
        END
    END
