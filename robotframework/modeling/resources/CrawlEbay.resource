*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  stealth_mode=${True}  record=${False}  fix_bbox=${TRUE}  presentation_mode=${True}   console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
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
    Wait For Elements State    //a[text()='Selling']  stable
    Click  //a[text()='Selling']

Click on orders tab
    Click  //li//a[text()='Orders']

Click on Listings tab
    Click  //li//a[text()='Listings']

Select All orders in menu
    Click  //nav[@class='left-nav']//*[text()='All orders']

Go to active in right menu
    Click  //nav[@class='left-nav']//*[text()='Active']

Click on thrid dropdown in search
    [Arguments]  ${option}
    Wait For Elements State    //select[@data-id="primaryFilter"]  stable
    Click  //select[@data-id="primaryFilter"]
    Select Options By  //select[@data-id="primaryFilter"]  text  ${option}

Click on the dropdown next to ${right_option}
    [Arguments]  ${option}
    Click  //select[@data-id="listingSKU"]
    Select Options By  //select[@data-id="listingSKU"]  text  ${option}
    
Write ${text} in the field next to is equal to
    Click  //div[@id="filters"]//input[@type="text"]
    Keyboard Input    type    ${text}

Search
    Click  //button[@type="submit"]
    Wait for spinner

Wait for spinner
    [Tags]  no_record
    Run Keyword And Ignore Error  Wait For Elements State    //span[@aria-label="Updating results"]  state=visible  timeout=3s
    Run Keyword And Ignore Error  Wait For Elements State    //span[@aria-label="Updating results"]  state=hidden  timeout=30s

Click on variations on the result
    Click  //a[contains(.,'variations')]

Is sku ${sku} in page
    [Tags]  no_record
    ${status}  ${msg}  Run Keyword And Ignore Error  Wait For Elements State    //tr[contains(.,'${sku}')]  visible  timeout=1s
    IF  "${status}" == "PASS"
        RETURN  ${True}
    END
        RETURN  ${False}

Click on the cell in ${sku} row and available quantity column
    Click  //tr[contains(.,'${sku}')]//td[contains(@class,'available')]

Click on the edit icon in the cell
    [Arguments]  ${sku}
    Wait For Elements State    //tr[contains(.,'${sku}')]//td[contains(@class,'available')]//div[@class="inline-editable-pencil"]  stable
    ${status}  ${msg}  Run Keyword And Ignore Error  Click  //tr[contains(.,'${sku}')]//td[contains(@class,'available')]//div[@class="inline-editable-pencil"]
    IF  "${status}" == "FAIL"
        Scroll By  ${None}  vertical=-100%
        Click  //tr[contains(.,'${sku}')]//td[contains(@class,'available')]
        Click  //tr[contains(.,'${sku}')]//td[contains(@class,'available')]//div[@class="inline-editable-pencil"]
    END

Get All Sku In Page
    @{skus_el}  Get Elements  //td[contains(@class,'listingSKU')]//span
    @{skus}  Create List
    FOR  ${sku_el}  IN  @{skus_el}
        ${sku}  Get Text  ${sku_el}
        Append To List  ${skus}  ${sku}
    END
    RETURN  ${skus}

Get All Sku In Page that has available quantity
    @{skus_el}  Get Elements  //td[contains(@class,'listingSKU')]//span
    @{skus}  Create List
    FOR  ${sku_el}  IN  @{skus_el}
        ${sku}  Get Text  ${sku_el}
        ${quantity}  Get Text  //tr[contains(.,'${sku}')]//td[contains(@class,'available')]//span
        IF  "${quantity}" != "0"
            Append To List  ${skus}  ${sku}
        END
    END
    RETURN  ${skus}

Write quantity ${quantity}
    Click  //div[@class="popover-content"]//input[@type="text"]
    Keyboard Key    Control+A+Delete
    Keyboard Input    type    ${quantity}

Click on submit in the popover
    Click  //div[@class="popover-content"]//button[@type="submit"]

Wait until popover is gone
    [Tags]  no_record
    Wait For Elements State    selector=//div[@class="popover-content"]  state=detached  timeout=20s

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
