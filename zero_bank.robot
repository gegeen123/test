*** Settings ***
Library    SeleniumLibrary
Library    String

*** Variables ***
${Username}    username
${Password}    password
${URL}        http://zero.webappsecurity.com/
${BROWSER}    chrome

*** Keywords ***
Login
    [Documentation]    For login process and go back to homepage
    Open Browser    ${URL}    browser=${BROWSER}    options=add_argument("--ignore-certificate-errors")
    Click Button    locator=id:signin_button
    Input Text    locator=user_login    text=${Username}
    Input Text    locator=user_password    text=${Password}
    Click Button    locator=name:submit
    Go Back

Logout
    [Documentation]    For logout and close browser
    Click Element    locator=xpath://*[@id="settingsBox"]/ul/li[3]/a
    Sleep    2s
    Click Element    locator=id:logout_link
    Close Browser

*** Test Cases ***
TS01 : LoginLogout
    Login
    Logout

TS02 : CheckBalance
    Login
    Click Element    locator=xpath://*[@id="onlineBankingMenu"]/div
    Click Element    locator=//*[@id="account_summary_link"]
    ${Titel_Account01}    Get Text    locator=xpath:/html/body/div[1]/div[2]/div/div[2]/div/div/h2[1]
    Should Be Equal    first=${Titel_Account01}     second=Cash Accounts    msg=Fail : ${Titel_Account01} 
    ${Titel_Account02}    Get Text    locator=xpath:/html/body/div[1]/div[2]/div/div[2]/div/div/h2[2]
    Should Be Equal    first=${Titel_Account02}     second=Investment Accounts    msg=Fail : ${Titel_Account02} 
    ${Titel_Account03}    Get Text    locator=xpath:/html/body/div[1]/div[2]/div/div[2]/div/div/h2[3]
    Should Be Equal    first=${Titel_Account03}     second=Credit Accounts    msg=Fail : ${Titel_Account03} 
    ${Titel_Account04}    Get Text    locator=xpath:/html/body/div[1]/div[2]/div/div[2]/div/div/h2[4]
    Should Be Equal    first=${Titel_Account04}     second=Loan Accounts    msg=Fail : ${Titel_Account04}  
    Logout

TS03 : Purchase foreign currency cash
    Login
    Click Element    locator=xpath://*[@id="onlineBankingMenu"]/div
    Click Element    locator=xpath://*[@id="pay_bills_link"]
    Click Element    locator=xpath://*[@id="tabs"]/ul/li[3]/a
    Wait Until Element Is Visible    locator=xpath://*[@id="pc_currency"]
    Select From List By Value    xpath://*[@id="pc_currency"]   THB
    Wait Until Element Is Visible    locator=xpath://*[@id="sp_sell_rate"]
    ${Exchange_Rates}    Get Text    locator=xpath://*[@id="sp_sell_rate"]
    ${Exchange_Rate} =	Split String	${Exchange_Rates}    max_split=5
    Log To Console    message=Exchange_Rate = ${Exchange_Rate}[4]    format=>30
    Input Text    locator=id:pc_amount    text=10
    Click Element    locator=xpath://*[@id="pc_inDollars_true"]
    Click Button    locator=id:pc_calculate_costs
    Wait Until Element Is Visible    locator=id:pc_conversion_amount
    ${Exchange_Results}    Get Text    locator=id:pc_conversion_amount
    ${Exchange_Result} =	Split String	${Exchange_Results}    max_split=5
    Log To Console    message=Exchange_Result = ${Exchange_Result}[0]    format=>2
    ${result} =    Evaluate   1>(10-(${Exchange_Rate}[4]*${Exchange_Result}[0]))
    Log To Console    message=Result = ${result}    format=>3
    IF  ${result}
        Click Button    locator=id:purchase_cash
        Wait Until Element Is Visible    locator=id:alert_container
        ${Exchange_Result}    Get Text    locator=xpath://*[@id="alert_content"]
        Should Be Equal    first=Foreign currency cash was successfully purchased.    second=${Exchange_Result}
        Logout
    ELSE
        Logout
        Fail	Exchange result is not correct   
    END
    