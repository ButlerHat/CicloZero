*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  stealth_mode=${True}  record=${False}  fix_bbox=${TRUE}  presentation_mode=${True}   console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser
Library   Collections
Library   ../../keywords/utils.py
Library    OperatingSystem


*** Keywords ***
# ===========================================================
# ======================== Pendiente ========================
# ===========================================================

Login with user ${user} and pass ${password}
    Click  //*[@id='ap_email']
    Keyboard Input    type    ${user}
    Click  //*[@id='ap_password']
    Keyboard Input    type    ${password}
    CLick  //*[@id='signInSubmit']

Type number "${number}" in field Indicar contraseña de un solo uso
    Click  //*[@id='auth-mfa-otpcode']
    Keyboard Input    type    ${number}

Check "No vuelvas a pedir un codigo en este navegador"
    Click  //*[@id='auth-mfa-remember-device']

Click on "Iniciar sesion"
    Click  //*[@id='auth-signin-button']

Scroll in Select Account until "${country}" is visible and click
    Click  //*[@id="picker-container"]//div[contains(text(), "${country}")]

Click on "Select Account"
    Click  //button[contains(text(),'Select Account')]

Click on menu icon at top left
    Click  //div[@role='button']
    Sleep  1

Click on "Orders" menu at the left
    AI.Click on "Orders" menu at the left
    # Only works in flendu
    # Click  //html/body/div/div[1]/div/div[1]/div[3]/div[3]/div/div[1]/div[2]/div/div[4]

Click on available column
    Click  //th[@id="quantity"]//a
    Sleep  2

Set 0 to skus where have quantity and not in Stock
    [Arguments]  @{skus_in_stock}
    [Tags]  only_substeps
    
    # Too many problems in this keyword, better to wait for all
    Click on Active in Listing status filter
    Wait for spinner
    Sleep  1
    Click on the dropdown of results per page at the bottom right
    Set 250 to results per page
    Wait for spinner
    Sleep  2

    @{skus_el}  Get Elements    //td[@data-column="sku"][./../td[@data-column="quantity"]//input[not(@value="0")]]//a  
    ${len_el}  Get Length  ${skus_el}
    ${i}  Set Variable  0
    
    WHILE  ${i} < ${len_el}
        ${sku}  Get Text  ${skus_el[${i}]}
        ${sku}  Set Variable  ${sku.replace("\n", "").strip()}
    
        IF  "${sku}" not in "@{skus_in_stock}"
            ${status}  ${msg}  Run Keyword And Ignore Error  File Should Exist    ${RETURN_FILE}
            IF  "${status}"=="PASS"  Append To File    ${RETURN_FILE}    ${sku},${SPACE}
            Log  Updating ${sku} to 0  console=${True}
            # Sometimes the sku is under the top menu. Scroll up to then scroll down if necessary
            Mouse Move    500    500  # To the middle
            Mouse Wheel    0    -50000  # To the top
            Wait for spinner
            Delete the input of available column for ${sku}
            Write 0 in available column for ${sku} row
            Click on save in the ${sku} row
            Wait for spinner
            Sleep  1
            @{skus_el}  Get Elements    //td[@data-column="sku"][./../td[@data-column="quantity"]//input[not(@value="0")]]//a  
            ${len_el}  Get Length  ${skus_el}
        ELSE
            ${i}  Evaluate  ${i} + 1
        END
    END

Click on "Order Reports" submenu
    Click  //a[@href='/order-reports-and-feeds/reports/ref=xx_orderrpt_dnav_xx']

Click on "Unshipped Orders" in the menu
    Click  //*[text()='Unshipped Orders']

Click on "Request" yellow button
    Click  //input[@name='request']

Click at "Refresh" button at the top right of the table
    Click  //input[@name='refresh']

Get element bouding box at ${ordinal_num} row and "${column}" column at Download Report table
    &{num_dict}  Create Dictionary   first=2  second=3  third=4  fourth=5  fifth=6  sixth=7  seventh=8  eighth=9  ninth=10  tenth=11
    &{column_dict}  Create Dictionary   report type=1  batch id=2  date range covered=3  date and time requested=4  date and time completed=5  report status=6  download=7
    ${bbox}  Element Bbox    //html/body/div[1]/div[2]/div[1]/div/div/div[2]/div[2]/div/div/div[4]/table/tr[${num_dict["${ordinal_num.lower()}"]}]/td[${column_dict["${column.lower()}"]}]
    RETURN  ${bbox}

Click at "download" button at ${ordinal_num} row at Download Report table
    &{num_dict}  Create Dictionary   first=2  second=3  third=4  fourth=5  fifth=6  sixth=7  seventh=8  eighth=9  ninth=10  tenth=11
    Click  //html/body/div[1]/div[2]/div[1]/div/div/div[2]/div[2]/div/div/div[4]/table/tr[${num_dict["${ordinal_num}"]}]/td[7]//a

# ==================================================================
# ======================== Pendiente envios ========================
# ==================================================================
Click "Manage orders" submenu
    # AI.Click "Manage orders" submenu
    Click  //*[text()="Manage Orders"]

Click on "Pending" tab
    Click  //div[@class='myo-spa-tab '][.//a[@data-test-id='tab-/mfn/pending']]

Change Results per page to ${num}
    Change Results per page
    Set Results per page to ${num}

Change Results per page
    Sleep  2
    Click  //*[@id='a-autoid-1-announce']

Click on Active in Listing status filter
    Sleep  2  # Wait page to load
    Click  //*[@id="LISTINGS_VIEW_SECTION"]//*[contains(text(),"Active")]/../input[@type="radio"]

Click on the dropdown of results per page at the bottom right
    [Documentation]  For CiclAI Update stock. The previous is for Stock
    Click  //*[@class="mt-records-per-page"]

Set Results per page to ${num}
    &{num_dict}  Create Dictionary   15=0  25=1  50=2  100=3
    Click  //*[@id='myo-table-results-per-page_${num_dict["${num}"]}']

Set ${num} to results per page
    Click  //a[text()="${num} results per page"]

How many orders are Pending?
    [Documentation]  The pending tab must be active
    ${bbox}  Get Element Bounding Box of the "Pending" tab    
    ${txt}  Get Text From Bbox    selector_bbox=${bbox}
    RETURN  ${txt.split(' ')[0].strip()}

How many phones are there?
    [Documentation]  No same name of orders as phones
    [Tags]  no_record
    # Get number of rows in the table
    ${num_rows}  Get Element Count  //table[@id='orders-table']//tr
    ${num_rows}  Evaluate  ${num_rows} - 1
    RETURN  ${num_rows}


Get Element Bounding Box of the "Pending" tab
    ${bbox}  Element Bbox  //div[contains(@class, 'active')]
    RETURN  ${bbox}

Remove Warnings In Table
    [Tags]  no_record
    Evaluate JavaScript  ${None}    const table = document.getElementById('orders-table');
    ...  // Get a list of all table rows with the class 'myo-table-row warning'
    ...  const rowsToDelete = table.querySelectorAll('.myo-table-row.warning');
    ...    // Loop through each row and remove it from the table
    ...    rowsToDelete.forEach(row => {
    ...    const tdCount = row.getElementsByTagName('td').length;
    ...    if (tdCount < 2) {
    ...    row.parentNode.removeChild(row);
    ...    }});

Duplicate td in double orders
    [Tags]  no_record
    Evaluate JavaScript  ${None}    const table = document.getElementById('orders-table');
    ...    let rows = table.querySelectorAll('tr');

    ...    let tdsWithRowspan = table.querySelectorAll('td[rowspan="2"]');
    ...    
    ...    tdsWithRowspan.forEach(td => {
    ...        // Remove the rowspan attribute
    ...        td.removeAttribute('rowspan');
    ...    });
    ...    
    ...    // Step 2: Convert NodeList to array
    ...    let rowsArray = Array.from(rows);
    ...    
    ...    // Step 3: Filter rows based on number of <td> children
    ...    let filteredRows = rowsArray.filter(row => row.querySelectorAll('td').length < 4);
    ...    
    ...    // Step 4: Exclude the first result
    ...    filteredRows = filteredRows.slice(1);
    ...    
    ...    // Step 5: Iterate over the filtered rows
    ...    filteredRows.forEach(row => {
    ...        // Get the row above (previous sibling)
    ...        let previousRow = row.previousElementSibling;
    ...        
    ...        // If the previous row exists
    ...        if (previousRow) {
    ...            // Get the first three <td> elements from the previous row
    ...            let tdsToInsert = Array.from(previousRow.querySelectorAll('td')).slice(0, 3);
    ...            
    ...            // Insert these <td> elements at the beginning of the current row
    ...            tdsToInsert.reverse().forEach(td => {
    ...                let clonedTd = td.cloneNode(true);
    ...                
    ...                row.insertBefore(td.cloneNode(true), row.firstChild);
    ...                last_insert = row.firstChild;
    ...                // Check if the clonedTd contains an <a> element and modify its text
    ...                let aElem = last_insert.querySelector('a');
    ...                let aElem2 = td.querySelector('a');
    ...                console.log(aElem)
    ...                console.log(last_insert)
    ...                if (aElem && aElem.textContent.trim() !== "") {
    ...                    console.log('updating conetnt ' + aElem.textContent)
    ...                    aElem.textContent += ".2";
    ...                    aElem2.textContent += ".1";
    ...                }
    ...            });
    ...        }
    ...    });

Wait for spinner
    [Tags]  no_record
    Sleep  0.5
    Wait For Condition    Style  //div[@class="mt-loading-overlay"]  display  !=  block

Which is the number of the second column of the ${ord_num} row?
    [Documentation]  The pending tab must be active. Obtain text with the locator, not AI
    ${num_bbox}  Get element bounding box of the second column of the ${ord_num} order
    ${asin_num}  Get Text From Bbox    selector_bbox=${num_bbox}
    RETURN  ${asin_num.split('\n')[0].strip()}

Get element bounding box of the second column of the ${ord_num} order
    [Documentation]  Get the element second column bounding box. If you want to give a clue to the AI you can set "${NEXT_OBSERVATION}" variable.
    IF  "${NEXT_OBSERVATION}"  Observation  ${NEXT_OBSERVATION}
    ${num}  Get Cardinal  ${ord_num}
    TRY
        ${bbox}  Element Bbox  //*[@id='orders-table']//tr[${num}]//td[3]
    EXCEPT
        Fail  Check if is a triple order. This script is not ready.
    END
    RETURN  ${bbox}

Which is the SKU of the order ${2nd_col_num}?
    [Documentation]  The pending tab must be active. Obtain text with the locator, not AI
    ${sku_bbox}  Get element bounding box of the sku of the ${2nd_col_num} order
    ${sku}  Get Text From Bbox    selector_bbox=${sku_bbox}
    # Remove the "SKU: " part
    RETURN  ${sku.split(':')[-1].strip()}

Get element bounding box of the sku of the ${2nd_col_num} order
    [Documentation]  Get the element sku bounding box. 
    ${bbox}  Element Bbox  //*[@id='orders-table']//tr[contains(.,'${2nd_col_num}')]//span[contains(text(), 'SKU')]/..
    RETURN  ${bbox}

Which quantity has the order ${2nd_col_num}?
    [Documentation]  The pending tab must be active. Obtain text with the locator, not AI
    ${qty_bbox}  Get element bounding box of the quantity of the order ${2nd_col_num}
    ${qty}   Get Text From Bbox    selector_bbox=${qty_bbox}
    # Remove the "Quantity: " part
    RETURN  ${qty.split(':')[-1].strip()}

Get element bounding box of the quantity of the order ${2nd_col_num}
    ${bbox}  Element Bbox  //*[@id='orders-table']//tr[contains(.,'${2nd_col_num}')]//span[contains(text(), 'Quantity')]/..
    RETURN  ${bbox}


# ===== No record Keywords =====
No Record Scroll Up
    [Tags]  no_record
    Scroll Up At Bbox    //*[@id="picker-container"]/div/div[2]/div/div[3]  1000

No Record Scroll Down
    [Tags]  no_record
    Scroll Down  pixels_selector=10000


# ==================================================================
# ======================== Price ========================
# ==================================================================

Go to "Inventory" at the left
    Click  //*[text()='Inventory']

Go to Catalogue menu
    Click  //*[text()='Catalogue']

Go to "Manage All Inventory" submenu
    Click  //*[text()='Manage All Inventory']

Go to add products via upload submenu
    Click  //*[text()='Add Products via Upload']

Upload inventory file
    [Documentation]  Uploads the inventory file
    [Arguments]  ${file_path}
    ${promise}    Promise To Upload File  ${file_path}
    Click  //input[@id="file-upload-input"]/..
    ${upload_result}=    Wait For    ${promise}
    Log  ${upload_result}  console=${True}

Select SKU radio button in filter
    Click  //li[@id="SearchType_SECTION"]//span[contains(text(),"SKU")][not(contains(text(),"FN"))]

Select All in Listing status
    Wait Until Keyword Succeeds  5  1  Click  //*[@id="LISTINGS_VIEW_SECTION"]//*[contains(text(),"All")]/../input[@type="radio"]

Search for SKU ${sku}
    Click  //*[@id='myitable-search']
    Keyboard Input    type    ${sku}
    Click  //*[@id='myitable-search-button-announce']

Delete search box
    Wait Until Keyword Succeeds  10  1  Click  //*[@id='myitable-search']
    Keyboard Key    Control+A+Delete

Click at marketplaces button for sku ${sku}
    Click  //table//tr[contains(.,"${sku}")]//input[./..//span[contains(text(),'marketplaces')]]

In which marketplaces is it being sold?
    ${bbox}  Get Element Bounding Box of marketplaces
    ${marketplaces}  Get Text From Bbox    selector_bbox=${bbox}
    @{marketplaces}  Set Variable   ${marketplaces.split('\n')[-1].split(',')}
    ${strip_marketplaces}  Evaluate  [x.strip() for x in ${marketplaces}]
    RETURN  ${strip_marketplaces}

Get Element Bounding Box of marketplaces
    ${bbox}  Element Bbox  //*[@id="losg-modal-iframe"] >>> //*[@id='janusTableContent']/div[1]/div[1]
    RETURN  ${bbox}

Go to page of the ${marketplace} row
    [Documentation]  This keyword cannot be recorded because when click does not work
    Get Bounding box of the link in the ${marketplace} row
    ${href}  NoRec Get Attribute    //*[@id="losg-modal-iframe"] >>> //*[@id='janusTableContent']/div[contains(., '${marketplace}')][2]/div[4]//a    href
    New Page  ${href}

    RETURN  ${href}

NoRec Get Attribute
    [Arguments]  ${selector}  ${attribute}
    [Tags]  no_record
    ${attr}  Get Attribute  ${selector}  ${attribute}
    RETURN  ${attr}


Get Bounding box of the link in the ${marketplace} row
    [Documentation]  This keyword is only for teaching purposes. When click does not work
    Element Bbox   //*[@id="losg-modal-iframe"] >>> //*[@id='janusTableContent']/div[contains(., '${marketplace}')][2]/div[4]

Get status for ${market}
    ${bbox}  Get Element Bounding Box of the status of the ${market} row
    ${status}  Get Text From Bbox    selector_bbox=${bbox}
    RETURN  ${status}

Get Element Bounding Box of the status of the ${market} row
    # Make sure the row is visible
    ${bbox}  Element Bbox  //*[@id="losg-modal-iframe"] >>> //*[@id='janusTableContent']/div[contains(., '${market}')][2]/div[1]
    RETURN  ${bbox}

Get price for ${market}
    ${bbox}  Get Element Bounding Box of the price of the ${market} row
    ${price}  Get Text From Bbox    selector_bbox=${bbox}
    RETURN  ${price.replace('\n', '').split(' ')[-1]}

Get Element Bounding Box of the price of the ${market} row
    ${loc}  Set Variable  //*[@id="losg-modal-iframe"] >>> //*[@id='janusTableContent']/div[contains(., '${market}')][2]/div[6]//kat-input-group//kat-input
    ${bbox}  Element Bbox  ${loc}
    RETURN  ${bbox}


# ========== Update stock ==========
Get text from available column for ${sku}
    [Tags]  no_record
    ${before}  Browser.Get attribute  //table//tr[contains(.,"${sku}")]/td[@data-column="quantity"]//input  value
    RETURN  ${before}

Delete the input of available column for ${sku}
    Wait Until Keyword Succeeds  5  1  Click  //table//tr[contains(.,"${sku}")]/td[@data-column="quantity"]//input
    Keyboard Key    Control+A+Delete

Write ${stock} in available column for ${sku} row
    Click  //table//tr[contains(.,"${sku}")]/td[@data-column="quantity"]//input
    Keyboard Input    type    ${stock}

Check if save button exists for sku ${sku}
    [Tags]  no_record
    ${status}  ${msg}  Run Keyword And Ignore Error  Wait For Elements State  //table//tr[contains(.,"${sku}")]/td[@data-column="action"]//button[contains(.,'Save')]  visible  2
    IF  '${status}' == 'PASS'  
        RETURN  ${TRUE}
    ELSE
        RETURN  ${FALSE}
    END

Click on save in the ${sku} row
    Click  //table//tr[contains(.,"${sku}")]/td[@data-column="action"]//button[contains(.,'Save')]

Check if update success for sku ${sku}
    [Tags]  no_record
    ${status}  ${msg}  Run Keyword And Ignore Error  Wait For Elements State  //table//tr[contains(.,"${sku}")]/td[@data-column="quantity"]//div[contains(@class,'success')]  visible  5
    IF  '${status}' == 'PASS'  
        Log  Saved ${sku} stock
    ELSE
        Log  Update failed for sku ${sku}  level=WARN
    END

# ========== Amazon Public ==========
Accept cookies
    Click  //*[@id='sp-cc-accept']

# Search ${product}
#     Click  //*[@id='twotabsearchtextbox']
#     Keyboard Input    type    ${product}

# Click on search icon
#     Click  //*[@id='nav-search-submit-button']
# ^ This is not used anywhere

See Renewed at the right above sell on Amazon
    Click  //div[@class='a-box-inner'][.//div[@class='olp-text-box']]

Open filter at the right
    Click  //*[@id='aod-filter-string']
    # Check if the filter is open
    ${STATUS}  ${MSG}  Run keyword and ignore error  Wait For Elements State   //*[@id="new"]/div/label/input  visible  1
    IF  '${STATUS}' == 'FAIL'  Run Keyword And Ignore Error  Click  //*[@id='aod-filter-string']

Close filter if not open
    ${STATUS}  ${MSG}  Run keyword and ignore error  Wait For Elements State   //*[@id="new"]/div/label/input  visible  1
    IF  '${STATUS}' == 'PASS'  Click  //*[@id='aod-filter-string']

Check ${condition} condition checkbox
    &{types_dict}  Create Dictionary  Renewed=new  Used=used  Like New=usedLikeNew  Very Good=usedVeryGood  Good=usedGood  Acceptable=usedAcceptable
    ${value}  Get From Dictionary    ${types_dict}  ${condition}
    Click  //*[@id="${value}"]/div/label/input

Get three first lowest price
    # Create dict to store prices
    &{prices}  Create Dictionary
    ${num_elements}  Get Element Count  //*[@id='aod-offer']
    ${num_elements}  Evaluate  min(5, ${num_elements})

    FOR  ${i}  IN RANGE  ${num_elements}
        ${ord_num}  Get Ordinal    number=${i+1}

        # Get best price
        ${bbox_price}  ${text}  Get element bounding box of the price of the ${ord_num} option
        ${text_bbox}  IF  not "${text}"  Get Text From Bbox    ${bbox_price}
        ${price}  Set Variable If  not "${text}"  ${text_bbox}  ${text}
        ${bbox}  Get element bounding box of the seller of the ${ord_num} option
        ${seller}  Get Text From Bbox    ${bbox}

        # Add to dict
        Set To Dictionary   ${prices}  ${seller}  ${price}  
    END

    RETURN  ${prices}

Get element bounding box of the price of the ${ord_num} option
    ${num}  Get Cardinal  ${ord_num} 
    ${bbox}  Element Bbox  (//*[@id='aod-offer'][${num}]//*[contains(text(),'€')][not(contains(text(),'no'))])[1]
    
    # This is to get a better text, but Element BBox still here for IA training
    ${text}  Get Text  (//*[@id='aod-offer'][${num}]//*[contains(text(),'€')][not(contains(text(),'no'))])[1]
    RETURN  ${bbox}  ${text}

Get element bounding box of the seller of the ${ord_num} option
    ${num}  Get Cardinal  ${ord_num}
    ${bbox}  Element Bbox  (//*[@id='aod-offer'][${num}]//*[@id='aod-offer-shipsFrom']//span)[2]
    RETURN  ${bbox}


