*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  stealth_mode=${True}  captcha_api_key=${0}  record=${False}  console=${False}  presentation_mode=${True}  fix_bbox=${False}  output_path=${OUTPUT_DIR}${/}data  WITH NAME  Browser 
Library    ./robotframework/keywords/count_excel.py
Library    OTP
Library    Collections
Library    OperatingSystem
Resource   ./robotframework/modeling/StockEbay.resource
Resource   ./robotframework/modeling/StockOdoo.resource
Resource   ./robotframework/modeling/StockAmazon.resource
Resource   ./robotframework/modeling/StockWoocommerce.resource
Variables  ./robotframework/variables/credentials.py
Suite Setup  Setup Suite


*** Variables ***
# ${OUTPUT_DIR}  /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero
${DEFAULT_AI_MODE}  Flexible
${BROWSER_WAIT}  2

${FILE_DIR}    /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero
${RESULT_EXCEL_PATH_ODOO}  ${FILE_DIR}${/}downloads${/}stock.quant.result.xlsx
${RESULT_EXCEL_PATH_AMZ_UNSHIPPED}  ${FILE_DIR}${/}downloads${/}stock.quant.amz.unshipped.result.xlsx
${RESULT_EXCEL_PATH_AMZ_PENDING}  ${FILE_DIR}${/}downloads${/}stock.quant.amz.result.xlsx
${RESULT_EXCEL_PATH_EBAY_UNSHIPPED}  ${FILE_DIR}${/}downloads${/}stock.quant.ebay.unshipped.result.xlsx
${RESULT_EXCEL_PATH_EBAY_PENDING}  ${FILE_DIR}${/}downloads${/}stock.quant.ebay.pending.result.xlsx
${RESULT_EXCEL_PATH_WOOCOMMERCE}  ${FILE_DIR}${/}downloads${/}stock.quant.woocommerce.result.xlsx
${RESULT_EXCEL_PATH}  ${FILE_DIR}${/}downloads${/}stock.quant.full.result.xlsx
${RESULT_CSV_PATH}  ${FILE_DIR}${/}downloads${/}stock.quant.full.llm.result.csv


*** Test Cases ***
CiclAI Stock Odoo
    [Documentation]  Creacion de excel para hacer el control de stock. Se usan las páginas de Odoo y Amazon.
    [Tags]  1
    # ================== Odoo ==================
    ${return_excel}  Get Stocks Odoo
    Create Excel    ${return_excel}    ${RESULT_EXCEL_PATH_ODOO}
    Log  Excel creado satisfactoriamente en ${RESULT_EXCEL_PATH_ODOO}  console=${TRUE}
    Comment  Close browser
    Close Browser
    
CiclAI Stock Unshipped Amazon
    [Tags]  2
    # ================== Amazon Unshipped ==================
    ${amazon_tsv_obj}  Get Unshipped Amazon
    IF  "${amazon_tsv_obj}" == "False"
        Log To Console    message=No hay pedidos pendientes de envío en Amazon
        Copy File    ${RESULT_EXCEL_PATH_ODOO}    ${RESULT_EXCEL_PATH_AMZ_UNSHIPPED}
    ELSE
        Append Tsv To Main Excel    ${amazon_tsv_obj.saveAs}    ${RESULT_EXCEL_PATH_ODOO}    ${RESULT_EXCEL_PATH_AMZ_UNSHIPPED}
    END
    Log  Excel de pending creado satisfactoriamente en ${RESULT_EXCEL_PATH_AMZ_UNSHIPPED}  console=${TRUE}
    Comment  Close browser
    Close Browser

CiclAI Stock Pending Amazon
    [Tags]  3
    # ================== Amazon Pending ==================
    ${amazon_dict_obj}  Get Pending Amazon
    Append Dict To Main Excel     ${amazon_dict_obj}    ${RESULT_EXCEL_PATH_ODOO}    ${RESULT_EXCEL_PATH_AMZ_PENDING}   amz pending
    Log  Excel de amazon creado satisfactoriamente en ${RESULT_EXCEL_PATH_AMZ_PENDING}  console=${TRUE}
    Comment  Close browser
    Close Browser

CiclAI Stock Woocommerce
    [Tags]  2
    # ================== Woocommerce ==================
    ${woocommerce_dict_obj}  Get Processing Woocommerce
    Append Dict To Main Excel    ${woocommerce_dict_obj}    ${RESULT_EXCEL_PATH_ODOO}    ${RESULT_EXCEL_PATH_WOOCOMMERCE}  woocom processing
    Log  Excel de woocommerce creado satisfactoriamente en ${RESULT_EXCEL_PATH_WOOCOMMERCE}  console=${TRUE}
    Comment  Close browser
    Close Browser

CiclAI Stock Unshipped Ebay
    [Tags]  2
    # ================== Ebay Unshipped ==================
    ${skus_count_dict_unshipped}  Ebay Get Stock unshipped
    Append Dict To Main Excel    ${skus_count_dict_unshipped}    ${RESULT_EXCEL_PATH_ODOO}    ${RESULT_EXCEL_PATH_EBAY_UNSHIPPED}  ebay unshipped
    Log  Excel de ebay unshipped creado satisfactoriamente en ${RESULT_EXCEL_PATH_EBAY_UNSHIPPED}  console=${TRUE}
    Comment  Close browser
    Close Browser

CiclAI Stock Pending Ebay
    [Tags]  3
    # ================== Ebay Pending ==================
    ${skus_count_dict_pending}  Ebay Get Stock pending
    Append Dict To Main Excel    ${skus_count_dict_pending}    ${RESULT_EXCEL_PATH_ODOO}    ${RESULT_EXCEL_PATH_EBAY_PENDING}  ebay pending
    Log  Excel de ebay pending creado satisfactoriamente en ${RESULT_EXCEL_PATH_EBAY_PENDING}  console=${TRUE}
    Comment  Close browser
    Close Browser

Create LLM file And Result Excel
    [Tags]  4
    &{columns}  Create Dictionary   amz unshipped=${RESULT_EXCEL_PATH_AMZ_UNSHIPPED}  amz pending=${RESULT_EXCEL_PATH_AMZ_PENDING}  ebay unshipped=${RESULT_EXCEL_PATH_EBAY_UNSHIPPED}  ebay pending=${RESULT_EXCEL_PATH_EBAY_PENDING}  woocom processing=${RESULT_EXCEL_PATH_WOOCOMMERCE}
    Combine All Excels    ${RESULT_EXCEL_PATH_ODOO}    ${columns}    ${RESULT_EXCEL_PATH}
    Log  Excel de creado satisfactoriamente en ${RESULT_EXCEL_PATH}  console=${TRUE}
    Create Csv For Llm    ${RESULT_EXCEL_PATH}    ${RESULT_CSV_PATH}
    Log  Csv de llm creado satisfactoriamente en ${RESULT_CSV_PATH}  console=${TRUE}

*** Keywords ***
Setup Suite
    [Tags]  no_record
    Browser.Add Task Library  CrawlAmazon  CrawlOdoo  CrawlWoocommerce  CrawlEbay  StockEbay  StockOdoo  StockAmazon  StockWoocommerce
    OperatingSystem.Remove Directory    path=${OUTPUT_DIR}${/}browser/screenshots    recursive=${TRUE}
    OperatingSystem.Remove Directory    path=${OUTPUT_DIR}${/}browser/traces    recursive=${TRUE}
