*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  stealth_mode=${True}  record=${False}  fix_bbox=${TRUE}  presentation_mode=${True}   console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library   Collections


*** Keywords ***
Login with user ${user} and pass ${password}
    Click  //*[@id="user_login"]
    Keyboard Input    type    ${user}
    Click  //*[@id="user_pass"]
    Keyboard Input    type    ${password}
    Click  //*[@id="wp-submit"]

Click on WooCommerce in the menu
    Click  //a[./*[text()="WooCommerce"]]

Click on Gestor de existencias in the menu
    Click  //a[./*[text()="Gestor de existencias"]]

Go to Pedidos under WooCommerce
    Click  //li[.//*[text()="WooCommerce"]]//a[contains(.,"Pedidos")]

Go to Importar/Exportar under Gestor de existencias
    Click  //li[.//*[text()="Gestor de existencias"]]//a[contains(.,"Importar/Exportar")]

Check if there are orders to process
    [Documentation]  Returns the number of orders to process
    [Tags]  no_record
    ${status}  ${msg}  Run Keyword And Ignore Error  Wait For Elements State  //ul//a[contains(.,"Procesando")]  visible  5s
    IF  "${status}" == "FAIL"
        Log  No orders to process  level=WARN
        RETURN  ${False}
    END
    RETURN  ${True}

Click on procesando
    Wait Until Network Is Idle
    Click  //ul//a[contains(.,"Procesando")]

Get bounding box of the count of procesando
    [Documentation]  The bounding box is for the AI but the keywords retrieves the text
    Element Bbox    //ul//a[contains(.,"Procesando")]//span[@class="count"]
    ${count} =  Get Text  //ul//a[contains(.,"Procesando")]//span[@class="count"]
    RETURN  ${count}

Get all skus from the table
    [Documentation]  Returns a dictionary with the skus and the number of times they appear
    &{orders_sku}  Create Dictionary
    ${rows}  Get Elements  //table[not(@style="display: none")]//tbody/tr//a[@class="order-view"]

    FOR  ${row}  IN  @{rows}
        Comment  Get the sku
        ${name}  Get Text  ${row}
        Click on eye icon of the ${name} row
        ${sku_dict} =  Get bouding box of the sku code above capacidad
        Close the popup

        FOR  ${sku}  ${sku_count}  IN  &{sku_dict}
            Comment  Add sku to dictionary
            TRY
                ${sku_before}  Get From Dictionary  ${orders_sku}  ${sku}
            EXCEPT 
                ${sku_before}  Set Variable  0
            END
            ${new_sku_count}  Evaluate  ${sku_before} + ${sku_count}
            Set To Dictionary  ${orders_sku}  ${sku}  ${new_sku_count}
        END
    END

    RETURN  ${orders_sku}

Click on eye icon of the ${name} row
    TRY
        Click  //table[not(@style="display: none")]//tbody/tr[contains(.,"${name}")]//a[@class="order-preview"]
    EXCEPT
        Scroll Down  50
        Click  //table[not(@style="display: none")]//tbody/tr[contains(.,"${name}")]//a[@class="order-preview"]
    END

Get bouding box of the sku code above capacidad
    ${sku_elements}  Get Elements    //div[@class="wc-order-item-sku"]
    ${sku_elements_count}  Get Length  ${sku_elements}
    &{orders_sku}  Create Dictionary
    
    IF  ${sku_elements_count} == 0
        Log  No sku found  level=WARN
    ELSE IF  ${sku_elements_count} == 1
        Element Bbox    //div[@class="wc-order-item-sku"]
        ${sku} =  Get Text  //div[@class="wc-order-item-sku"]
        IF  "${sku}" == "${EMPTY}"
            Log  SKU empty  level=WARN
            RETURN  ${orders_sku}
        END
        ${sku_count}  Get Bounding box of cantidad of sku ${sku}
        Set To Dictionary    ${orders_sku}  ${sku}  ${sku_count}
    ELSE
        ${orders_sku}  No Record capacidad  ${sku_elements}
    END
    
    RETURN  ${orders_sku}

No Record capacidad
    [Documentation]  To make parent keyword no record when more than one sku
    [Arguments]  ${sku_elements}
    [Tags]  no_record
    
    &{orders_sku}  Create Dictionary

    FOR  ${sku_element}  IN  @{sku_elements}
        Element Bbox    ${sku_element}
        ${sku} =  Get Text  ${sku_element}
        IF  "${sku}" == "${EMPTY}"
            Log  SKU empty  level=WARN
            CONTINUE
        END
        TRY
            ${sku_before}  Get From Dictionary  ${orders_sku}  ${sku}
        EXCEPT 
            ${sku_before}  Set Variable  0
        END
        ${sku_count}  Get Bounding box of cantidad of sku ${sku}
        ${new_sku_count}  Evaluate  ${sku_before} + ${sku_count}
        Set To Dictionary  ${orders_sku}  ${sku}  ${new_sku_count}
    END

    RETURN  ${orders_sku}


Get Bounding box of cantidad of sku ${sku}
    
    Element Bbox    //tr[contains(.,"${sku}")]//td[contains(@class,"quantity")]
    ${cantidad} =  Get Text  //tr[contains(.,"${sku}")]//td[contains(@class,"quantity")]
    RETURN  ${cantidad}
    

Close the popup
    Click  //button[contains(@class,"modal-close")]

Upload inventory file
    [Documentation]  Uploads the inventory file
    [Arguments]  ${file_path}
    ${promise}=    Promise To Upload File  ${file_path}
    Click  //input[@name="uploadFile"]
    ${upload_result}=    Wait For    ${promise}
    Log  ${upload_result}  console=${True}

Click on subir
    Click  //form[.//input[@name="uploadFile"]]//input[@type='submit']

Check if ${file} is uploaded
    [Tags]  no_record
    ${status}  ${msg}  Run Keyword And Ignore Error  Wait For Elements State    //form[.//input[@name="uploadFile"]]/../..//*[contains(.,"${file}")]  visible  timeout=20s
    IF  "${status}" == "FAIL"
        Log  File ${file} not uploaded  level=WARN
        RETURN  ${False}
    END

    ${status}  ${msg}  Run Keyword And Ignore Error  Wait For Elements State    (//form[.//input[@name="uploadFile"]]/../..//*[contains(.,"subido el producto")])[1]  visible  timeout=1s
    IF  "${status}" == "FAIL"
        Log  File ${file} not uploaded  level=WARN
        RETURN  ${False}
    END