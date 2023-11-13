*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  presentation_mode=${True}  fix_bbox=${TRUE}  record=${False}  console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library    robotframework/keywords/count_excel.py
Library    robotframework/keywords/update_woocommerce.py
Library    robotframework/keywords/amazon_stock_tsv.py
Library    OTP
Library    Collections
Library    OperatingSystem
Resource   robotframework/modeling/resources/CrawlAmazon.resource
Variables  robotframework/variables/credentials.py
Suite Setup  Setup Suite


*** Variables ***
${OUTPUT_DIR}  /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero/results/Amazon
${FILE_DIR}    /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero
${STOCK_EXCEL_PATH}  ${OUTPUT_DIR}${/}downloads${/}stock.quant.full.result.xlsx
${RETURN_FILE}  ${OUTPUT_DIR}${/}return_msg.txt
${DEFAULT_AI_MODE}  Flexible

# Generate csv
${PRODUCTS_CSV}  ${FILE_DIR}${/}robotframework${/}keywords${/}woocommerce_files${/}data_woocommerce_products.csv
${OUTPUT_TSV_FILE}  data_amazon_products_updated.tsv
${OUTPUT_TSV}    ${OUTPUT_DIR}${/}${OUTPUT_TSV_FILE}

# Amazon
${URL_AMAZON}  https://sellercentral.amazon.es


*** Test Cases ***

UpdateAmazon
    Log  Updating Amazon with file. Using file ${STOCK_EXCEL_PATH}.  console=${True}

    Comment  Obtener inventario de Odoo
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    ${old_timeout}  Set Browser Timeout    30
    New Page   ${URL_AMAZON}

    Click on log in at the top right
    CrawlAmazon.Login with user ${amazon_user} and pass ${amazon_pass}
    Set Browser Timeout    ${old_timeout}
    Sleep  1
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
    Go to "Inventory" at the left
    Go to "Manage All Inventory" submenu

    &{sku_total}  Get All Sku And Total    excel_path=${STOCK_EXCEL_PATH}

    # Remove inventory that are not in the excel
    Click on available column
    Wait for spinner
    Create File    path=${RETURN_FILE}  content=Warning:${SPACE}
    Set 0 to skus where have quantity and not in Stock  @{sku_total.keys()}
    ${content}    Get File    path=${RETURN_FILE}
    ${status}  ${msg}   Run Keyword And Ignore Error  Should Be Equal As Strings    ${content}    Warning:${SPACE}
    IF  "${status}"!="PASS"
        Append To File  path=${RETURN_FILE}    content=are set to 0 on Amazon because are not in stock. Check if have different name in stock and Amazon.${\n}${\n}
    END

    # Select only active products
    Wait for spinner
    Select All in Listing status
    Wait for spinner
    FOR  ${sku}  ${total}  IN  &{sku_total}
        Log  Updating ${sku} to ${total}  console=${True}

        Search for SKU ${sku}
        Wait for spinner
        Select SKU radio button in filter
        TRY
            ${previous_total}  Get text from available column for ${sku}
            Delete the input of available column for ${sku}
            IF  "${previous_total}"=="0" and "${total}"!="0"
                Log  SKU ${sku} was 0 in Amazon, change to ${total}.  console=${True}
                Append To File  path=${RETURN_FILE}    content=Sku ${sku} was 0 in Amazon, change to ${total}.${SPACE}${\n}
            END
        EXCEPT
            Log  No sku ${sku} in Amazon (Skipping).  console=${True}  level=WARN
            Append To File  path=${RETURN_FILE}    content=No ${sku} in Amazon (Skipping).${SPACE}${\n}
            Delete search box
            CONTINUE
        END
        Write ${total} in available column for ${sku} row
        ${can_save}  Check if save button exists for sku ${sku}
        IF  ${can_save}  
            Click on save in the ${sku} row
            TRY
                Check if update success for sku ${sku}
            EXCEPT
                Log  No success message for ${sku} CHECK!.  console=${True}  level=WARN
                Append To File  path=${RETURN_FILE}    content=No success message for ${sku} CHECK!.${SPACE}${\n}
            END
            Log  Changed ${sku}.  console=${True}  level=INFO
        ELSE
            Log  No save button for ${sku}. Skipping
        END
        Delete search box
        
    END

    ${content}    Get File    path=${RETURN_FILE}
    ${status}  ${msg}   Run Keyword And Ignore Error  Should Be Equal As Strings    ${content}    Warning:${SPACE}
    IF  "${status}"=="PASS"
        Remove File  ${RETURN_FILE}
    END


UpdateAmazonWithFile
    [Documentation]  Update Amazon with file. Not in production yet
    [Tags]  robot:exclude

    Log  Updating Amazon with file. Using file ${STOCK_EXCEL_PATH}.  console=${True}
    Comment  Obtener inventario de Odoo
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    New Page   ${URL_AMAZON}

    Click on log in at the top right
    CrawlAmazon.Login with user ${amazon_user} and pass ${amazon_pass}
    Sleep  1
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
    Go to Catalogue menu
    Go to add products via upload submenu

    # Generate tsv
    &{sku_total}  Get All Sku And Total    excel_path=${STOCK_EXCEL_PATH}
    ${warning_msg}  Write Tsv File All Skus    ${OUTPUT_TSV}    ${PRODUCTS_CSV}    ${sku_total}
    # Warn if there are skus in excel that are not in woocommerce products
    IF  "${warning_msg}"!=""
        Create File    path=${RETURN_FILE}
        Log  ${warning_msg}  console=${True}  level=WARN
        Append To File  path=${RETURN_FILE}    content=${warning_msg}${\n}
    END

    # Upload tsv TODO: TEST
    # Upload inventory file  ${OUTPUT_TSV}


*** Keywords ***
Setup Suite
    [Tags]  no_record
    Browser.Add Task Library  CrawlAmazon
    OperatingSystem.Remove Directory    path=${OUTPUT_DIR}${/}browser    recursive=${TRUE}    
