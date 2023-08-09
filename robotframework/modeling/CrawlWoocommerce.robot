*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  presentation_mode=${True}  fix_bbox=${TRUE}  console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Resource  ./resources/CrawlWoocommerce.resource
Variables  ../variables/credentials.py
Suite Setup  Browser.Add Task Library    CrawlWoocommerce


*** Variables ***
${URL_WOOCOMERCE}  https://ciclozero.com/wp-admin/admin.php?page=stock-manager


*** Tasks ***
Test Woocommerce Stock
    [Documentation]  Creacion de excel para hacer el control de stock en woocommerce
    ${dict}  Get Processing Woocommerce 
    Log  Dictionary ${dict}  console=${True}


*** Keywords ***
Get Processing Woocommerce
    Comment  Obtener los unshipped de Woocommerce
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    Wait New Page   ${URL_WOOCOMERCE}  wait=${1}

    CrawlWoocommerce.Login with user ${woocommerce_user} and pass ${woocommerce_pass}
    CrawlWoocommerce.Click on WooCommerce in the menu
    CrawlWoocommerce.Go to Pedidos under WooCommerce
    
    ${any_to_process}  CrawlWoocommerce.Check if there are orders to process
    &{dict_sku_count}  Create Dictionary
    IF  ${any_to_process}  
        CrawlWoocommerce.Click on procesando
        CrawlWoocommerce.Get bounding box of the count of procesando
        ${dict_sku_count}  CrawlWoocommerce.Get all skus from the table
    END

    RETURN  ${dict_sku_count}
    