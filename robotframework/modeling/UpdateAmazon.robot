*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  presentation_mode=${True}  fix_bbox=${TRUE}  record=${True}  console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library   OTP
Library   Collections
Library   ../keywords/count_excel.py
Resource   ./resources/CrawlAmazon.resource
Variables  ../variables/credentials.py
Suite Setup  Browser.Add Task Library    CrawlAmazon


*** Variables ***
${OUTPUT_DIR}  /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero/robotframework/modeling
${URL_AMAZON}  https://sellercentral.amazon.es/ap/signin?openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fsellercentral.amazon.es%2Fhome&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.assoc_handle=sc_es_amazon_v2&openid.mode=checkid_setup&language=es_ES&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&pageId=sc_es_amazon_v2&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&ssoResponse=eyJ6aXAiOiJERUYiLCJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiQTI1NktXIn0.u8j_3kfAPRO9oea7TATYwCAdOKehZfRhKktBjgJlntMm6nulCn1qEg.B2O2NQ1GNLUmz9NH.cjghNVWhLvzDMxogLdKHIvb87caY5OMLYZheHT6HHz3k088JtfZnEGHu8fk8e_IFDIpVNxqqHzR8JcyQjX1b5SwxquNbOpmt5cnMPZ5pgqpf0pbcHi8-TrhHtZ2XJjSDaSwqYkPTP6oEJKgc6fDOGcJsXOPPXTJc6ZT71ZHEX1R8j94ipHBM6qer4vruZRBYMAdZVaFP.K5bI5NZ7lJG0ObtQQymgtA
${DEFAULT_AI_MODE}  Flexible

${STOCK_EXCEL_PATH}  ${OUTPUT_DIR}${/}downloads${/}CiclAiStock_00-45_11-05-2023.xlsx


*** Test Cases ***

UpdateAmazon
    Comment  Obtener inventario de Odoo
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    Set Browser Timeout  60
    New Page   ${URL_AMAZON}

    Login with user ${amazon_user} and pass ${amazon_pass}
    AI.Click on Indicar contraseña de un solo uso desde la app de verificación
    AI.Click on "Enviar contraseña de un solo uso"
    
    ${otp_key}=    Get OTP    ${otp_amazon}
    Should Match Regexp       ${otp_key}        \\d{6}
    Type number "${otp_key}" in field Indicar contraseña de un solo uso
    Check "No vuelvas a pedir un codigo en este navegador"
    Click on "Iniciar sesion"
    Scroll in Select Account until "Spain" is visible and click
    Click on "Select Account"

    Click on menu icon at top left
    Go to "Inventory" at the left
    Go to "Manage All Inventory" submenu

    &{sku_total}  Get All Sku And Total    excel_path=${STOCK_EXCEL_PATH}
    FOR  ${sku}  ${total}  IN  &{sku_total}
        # Debugging
        ${sku}  Set Variable  iP13PR-SRBL-128-C -R
        ${total}  Set Variable  8
        # Debugging

        Search for SKU ${sku}
        Delete the input of available column for ${sku}
        Write ${total} in available column for ${sku} row
        ${can_save}  Check if save button exists for sku ${sku}
        IF  ${can_save}  
            Click on save in the ${sku} row
            Check if update success for sku ${sku}
        ELSE
            Log  No save button for ${sku}. Skipping
        END
        Delete search box
    END