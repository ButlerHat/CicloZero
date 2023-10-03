*** Settings ***
Library   ButlerRobot.AIBrowserLibrary  stealth_mode=${True}  record=${False}  fix_bbox=${TRUE}  presentation_mode=${True}   console=${False}  output_path=${OUTPUT_DIR}/crawl_amazon_data  WITH NAME  Browser


*** Variables ***
${CAPTCHA_API_KEY}  1b5b309b37e0231099f023aa9e96de0b
${name}  John
${last_name}  Doe
${type}  Education
${company}  Bizbangboom V2
${short_description}  I'm a great engineer educator
${email}  johndoe@gmail.com
${password}  johndoe123


*** Test Cases ***
ConnectToStealth
    Browser.New Stealth Persistent Context   browser=chromium  url=https://www.bizbangboom.com/checkout/1

    # Browser.New Browser  chromium  headless=${False}
    # Browser.New Context
    # Browser.New Page  https://www.bizbangboom.com/checkout/1

    Click on consent personal data
    Input first name ${name}
    Write last name ${last_name}
    Select ${type} from best describes you selector
    Write ${company} in company field
    Scroll to bottom no record
    In short description write ${short_description}
    Enter ${email} in email field
    Write ${email} in confirm email field
    Write ${password} in password field
    Scroll to top no record
    Write ${password} in confirm password field
    Select checkbox for terms and conditions
    Marck checkbox for understand that personal information will be stored
    Scroll to top no record
    Select checkbox for understand if I purchase, billing information will be stored woth 3rd party payment processor
    Wait until captcha is done
    Click on create my profile
    Sleep  1000
    

*** Keywords ***

Click on consent personal data
    [Tags]  no_record
    [Documentation]  First time with persistent context
    ${old_timeout}  Set Browser Timeout    5s
    Run Keyword And Ignore Error  Click    //button[@aria-label='Consent']
    Set Browser Timeout    ${old_timeout}

Input first name ${name}
    Click  //input[@name='first_name']
    Keyboard Input    type    ${name}

Write last name ${last_name}
    Click  //input[@name='last_name']
    Keyboard Input    type    ${last_name}

Select ${type} from best describes you selector
    [Tags]  no_record
    ${options}  Select Options By  //select[@name='profession_id']  text  ${type}
    
Write ${company} in company field
    Click  //input[@name='company']
    Keyboard Input    type    ${company}

In short description write ${short_description}
    Click  //textarea[@name='search_description']
    Keyboard Input    type    ${short_description}

Enter ${email} in email field
    Click  //input[@name='email']
    Keyboard Input    type    ${email}

Write ${email} in confirm email field
    Click  //input[@name='email_confirm']
    Keyboard Input    type    ${email}

Write ${password} in password field
    Click  //input[@name='password']
    Keyboard Input    type    ${password}

Write ${password} in confirm password field
    Click  //input[@name='password_confirm']
    Keyboard Input    type    ${password}

Select checkbox for terms and conditions
    Click  //input[@name='consent_history[1]']

Marck checkbox for understand that personal information will be stored
    Click  //input[@name='consent_history[2]']

Select checkbox for understand if I purchase, billing information will be stored woth 3rd party payment processor
    Click  //input[@name='consent_history[3]']

Wait until captcha is done
    [Tags]  no_record
    Wait For Elements State    //*[contains(@class, 'antigate_solver')][contains(@class, 'solved')]  visible  timeout=3m

Click on create my profile
    Scroll to top no record
    Click  //input[@type='submit']

Scroll to top no record
    [Tags]  no_record
    Scroll By  ${None}  vertical=-100%

Scroll to bottom no record
    [Tags]  no_record
    Scroll By  ${None}  vertical=100%
