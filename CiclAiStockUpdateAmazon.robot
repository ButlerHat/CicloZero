*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  presentation_mode=${True}  fix_bbox=${TRUE}  record=${False}  console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library    robotframework/keywords/count_excel.py
Library    robotframework/keywords/update_woocommerce.py
Library    OTP
Library    Collections
Library    OperatingSystem
Resource   robotframework/modeling/resources/CrawlAmazon.resource
Variables  robotframework/variables/credentials.py
Suite Setup  Browser.Add Task Library    CrawlAmazon


*** Variables ***
${OUTPUT_DIR}  /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero
${DEFAULT_AI_MODE}  Flexible
${STOCK_EXCEL_PATH}  ${OUTPUT_DIR}${/}downloads${/}stock.quant.full.result.xlsx
${RETURN_FILE}  ${OUTPUT_DIR}${/}return_msg.txt

# Amazon
${URL_AMAZON}  https://sellercentral.amazon.es/ap/signin?openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fsellercentral.amazon.es%2Fhome&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.assoc_handle=sc_es_amazon_v2&openid.mode=checkid_setup&language=es_ES&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&pageId=sc_es_amazon_v2&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&ssoResponse=eyJ6aXAiOiJERUYiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiQTI1NktXIn0.u8j_3kfAPRO9oea7TATYwCAdOKehZfRhKktBjgJlntMm6nulCn1qEg.B2O2NQ1GNLUmz9NH.cjghNVWhLvzDMxogLdKHIvb87caY5OMLYZheHT6HHz3k088JtfZnEGHu8fk8e_IFDIpVNxqqHzR8JcyQjX1b5SwxquNbOpmt5cnMPZ5pgqpf0pbcHi8-TrhHtZ2XJjSDaSwqYkPTP6oEJKgc6fDOGcJsXOPPXTJc6ZT71ZHEX1R8j94ipHBM6qer4vruZRBYMAdZVaFP.K5bI5NZ7lJG0ObtQQymgtA


*** Test Cases ***
UpdateAmazon
    Comment  Obtener inventario de Odoo
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    New Page   ${URL_AMAZON}

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
    Go to "Inventory" at the left
    Go to "Manage All Inventory" submenu

    &{sku_total}  Get All Sku And Total    excel_path=${STOCK_EXCEL_PATH}

    # Remove inventory that are not in the excel
    Click on available column
    Create File    path=${RETURN_FILE}  content=Warning:${SPACE}
    Set 0 to skus where have quantity and not in Stock  @{sku_total.keys()}
    ${content}    Get File    path=${RETURN_FILE}
    ${status}  ${msg}   Run Keyword And Ignore Error  Should Be Equal As Strings    ${content}    Warning:${SPACE}
    IF  "${status}"!="PASS"
        Append To File  path=${RETURN_FILE}    content=are set to 0 on Amazon because are not in stock. Check if have different name in stock and Amazon.${\n}${\n}
    END

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
                Append To File  path=${RETURN_FILE}    content=Sku ${sku} was 0 in Amazon, change to ${total}.${SPACE}
            END
        EXCEPT
            Log  No sku ${sku} in Amazon (Skipping).  console=${True}  level=WARN
            Append To File  path=${RETURN_FILE}    content=No ${sku} in Amazon (Skipping).${SPACE}
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
                Append To File  path=${RETURN_FILE}    content=No success message for ${sku} CHECK!.${SPACE}
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
