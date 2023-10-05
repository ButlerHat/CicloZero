*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  fix_bbox=${TRUE}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library   Collections


*** Keywords ***
Check if not logged in
    [Tags]  no_record
    [Documentation]  Check if logged in
    TRY
        Wait For Elements State    //a[@title='My eBay']  visible  timeout=5s
    EXCEPT
        RETURN  ${True}
    END
    RETURN  ${False}
    
Continue with user ${user}
    Click  //*[@id="userid"]
    Keyboard Input    type    ${user}
    Click  //*[@id="signin-continue-btn"]

Is captcha
    [Tags]  no_record
    [Documentation]  Check if is captcha
    TRY
        Wait For Elements State    //*[contains(@class, 'antigate_solver')]  visible  timeout=5s
    EXCEPT
        RETURN  ${False}
    END
    RETURN  ${True}
    
Wait until captcha is done
    [Tags]  no_record
    Wait For Elements State    //*[contains(@class, 'antigate_solver')][contains(@class, 'solved')]  visible  timeout=3m

Continue with password ${password}
    Wait For Elements State    //*[@id="pass"]  visible
    Click  //*[@id="pass"]  # Changed one time
    Keyboard Input    type    ${password}
    Click  //*[@id="sgnBt"]

Accept cookies
    Click  //*[@id="gdpr-banner-accept"]

Click on get text
    Click  //*[@id="smsWithCode-btn"]

Input sms code ${sms_code}
    Click  //*[@id="pin-box-0"]
    Keyboard Input    type    ${sms_code}
    Click  //*[@id="verify-btn"]

Close popup
    Click  //button[contains(@class,'icon-btn')][contains(@class,'close')]

Go to my ebay
    Click  //a[@title='My eBay']

Go to my ebay selling
    Click  //a[text()='Selling']

Click on orders tab
    Click  //li//a[text()='Orders']

Select All orders in menu
    Click  //nav[@class='left-nav']//*[text()='All orders']

Click on unshipped menu
    Click  //nav[@class='left-nav']//*[text()='Awaiting shipment']

Select pending menu
    Click  //nav[@class='left-nav']//*[text()='Awaiting payment']

Count Skus in list
    [Documentation]  Get all skus and the quantity in a dictionary

    &{skus_count}  Create Dictionary

    ${rows}  Get Elements  //div[contains(@class,'order-details ')]//a
    FOR  ${row}  IN  @{rows}
        ${order_detail_id}  Get Text  ${row}
        ${count}  Get Bounding box of the count with order id ${order_detail_id}
        ${sku}  Get Bounding box of the SKU with order id ${order_detail_id}
        TRY
            ${sku_count}  Get From Dictionary  ${skus_count}  ${sku}
        EXCEPT
            ${sku_count}  Set Variable  0
        END
        ${new_sku_count}  Evaluate  ${sku_count} + ${count}
        Set To Dictionary    ${skus_count}    ${sku}    ${new_sku_count}
    END

    RETURN  ${skus_count}

Get Bounding box of the count with order id ${order_detail_id}
    [Documentation]  Bounding box for the dataset, return the text.
    Element Bbox  //*[contains(text(),'${order_detail_id}')]/ancestor::tr[1]//*[@class='quantity']//strong
    ${quantity}  Get Text  //*[contains(text(),'${order_detail_id}')]/ancestor::tr[1]//*[@class='quantity']//strong
    RETURN  ${quantity}

Get Bounding box of the SKU with order id ${order_detail_id}
    [Documentation]  Bounding box for the dataset, return the text.
    ${row_class}  Get Attribute    //*[contains(text(),'${order_detail_id}')]/ancestor::tr[1]    class
    ${sku_selector}  Set Variable  //*[contains(@class,'${row_class.split('orderid_')[-1].split('__')[0]}')]//*[contains(@class,'sku')]//*[@class='sh-bold']
    Element Bbox    ${sku_selector}
    ${sku}  Get Text   ${sku_selector}
    RETURN  ${sku}
