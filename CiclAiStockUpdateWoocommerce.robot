*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  presentation_mode=${True}  fix_bbox=${TRUE}  record=${False}  console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library    robotframework/keywords/count_excel.py
Library    robotframework/keywords/update_woocommerce.py
Library    OTP
Library    Collections
Library    OperatingSystem
Resource   robotframework/modeling/resources/CrawlWoocommerce.resource
Variables  robotframework/variables/credentials.py
Suite Setup  Setup Suite


*** Variables ***
${OUTPUT_DIR}  /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero/results/update_stock
${FILE_DIR}    /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero
${DEFAULT_AI_MODE}  Flexible
${STOCK_EXCEL_PATH}  ${OUTPUT_DIR}${/}downloads${/}stock.quant.full.result.xlsx

# Woocommerce
${RETURN_FILE}  ${OUTPUT_DIR}${/}return_msg.txt
${URL_WOOCOMERCE}  https://ciclozero.com/wp-admin/admin.php?page=stock-manager

${PRODUCTS_CSV}  ${FILE_DIR}${/}robotframework${/}keywords${/}woocommerce_files${/}data_woocommerce_products.csv
${OUTPUT_CSV_FILE}  data_woocommerce_products_updated.csv
${OUTPUT_CSV}    ${OUTPUT_DIR}${/}${OUTPUT_CSV_FILE}


*** Test Cases ***

Update Woocommerce Stock
    [Documentation]  Creacion de excel para hacer el control de stock en woocommerce

    Log  Updating Woocommerce with file. Using file ${STOCK_EXCEL_PATH}.  console=${True}
    Comment  Generate csv to update stock
    ${skus_not_updated}  Update Woocommerce Csv  ${PRODUCTS_CSV}  ${STOCK_EXCEL_PATH}  ${OUTPUT_CSV}
    Create File    path=${RETURN_FILE}    content=Warning: SKUs ${skus_not_updated} not in woocommerce
    
    Comment  Obtener los unshipped de Woocommerce
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    Wait New Page   ${URL_WOOCOMERCE}  wait=${1}

    CrawlWoocommerce.Login with user ${woocommerce_user} and pass ${woocommerce_pass}
    CrawlWoocommerce.Click on Gestor de existencias in the menu
    CrawlWoocommerce.Go to Importar/Exportar under Gestor de existencias
    CrawlWoocommerce.Upload inventory file  ${OUTPUT_CSV}
    CrawlWoocommerce.Click on subir
    CrawlWoocommerce.Check if ${OUTPUT_CSV_FILE} is uploaded

    Close Browser

*** Keywords ***
Setup Suite
    [Tags]  no_record
    Browser.Add Task Library  CrawlWoocommerce
    OperatingSystem.Remove Directory    path=${OUTPUT_DIR}${/}browser    recursive=${TRUE}    
