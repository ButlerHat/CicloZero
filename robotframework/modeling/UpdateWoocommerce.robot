*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  presentation_mode=${True}  fix_bbox=${TRUE}  console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library   OperatingSystem
Library    ../keywords/update_woocommerce.py
Resource  ./resources/CrawlWoocommerce.resource
Variables  ../variables/credentials.py
Suite Setup  Browser.Add Task Library    CrawlWoocommerce


*** Variables ***
${OUTPUT_DIR}  /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero/robotframework/modeling
${RETURN_FILE}  ${OUTPUT_DIR}${/}return_msg.txt
${URL_WOOCOMERCE}  https://ciclozero.com/wp-admin/admin.php?page=stock-manager
${DEFAULT_AI_MODE}  Flexible
${STOCK_EXCEL_PATH}  ${OUTPUT_DIR}${/}..${/}keywords${/}woocommerce_files${/}stock.xlsx
${PRODUCTS_CSV}  ${OUTPUT_DIR}${/}..${/}keywords${/}woocommerce_files${/}data_woocommerce_products.csv
${OUTPUT_CSV}  ${OUTPUT_DIR}${/}..${/}keywords${/}woocommerce_files${/}data_woocommerce_products_updated.csv


*** Tasks ***
Update Woocommerce Stock
    [Documentation]  Creacion de excel para hacer el control de stock en woocommerce
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
