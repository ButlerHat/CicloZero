*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  stealth_mode=${True}  record=${False}  console=${False}  presentation_mode=${True}  fix_bbox=${TRUE}  output_path=${OUTPUT_DIR}${/}data  WITH NAME  Browser 
Variables  ../variables/credentials.py
Resource   ./resources/CrawlOdoo.resource


*** Variables ***
${OUTPUT_DIR}  /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero/data


*** Keywords ***
Get Stocks Odoo
    Comment  Obtener inventario de Odoo
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    ${old_timeout}  Set Browser Timeout    timeout=${20}
    Wait New Page       https://backoffice.ciclozero.com/  wait=${3}
    Set Browser Timeout    timeout=${old_timeout}
    
    Comment  Acceder a informe de inventario
    Click on "Identificarse"
    CrawlOdoo.Login with user ${odoo_user} and pass ${odoo_pass}
    Go to menu icon at the top left
    Go to inventario
    Click on "informes" in the top menu
    Click on "Informe de inventario" in informes submenu
    
    Comment  Marcar todos los registros de la tabla
    Select view pivot icon at the top right of the table
    Click on "Total" in the first row
    Click on left right arrow icon under actualizar la cantidad
    Click on cell in the Alm/Stock venta row and column Total
    Click on select all box in the table

    Comment  Descargar excel
    ${dl_promise}  Promise To Wait For Download    saveAs=${OUTPUT_DIR}${/}downloads${/}stock.quant.xlsx
    Click to download icon above the table
    ${odoo_excel_obj}  Wait For  ${dl_promise}

    RETURN  ${odoo_excel_obj.saveAs}
