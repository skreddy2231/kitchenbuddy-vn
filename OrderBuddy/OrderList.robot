*** Settings ***
Documentation       As an administrator I have ability to create orders using Waiterbuddy portal.
...                 For Example: In this scenario open the portal and fetch customer orders and then check given order in ready state.

Resource            ./../MenuCart/KitchenBuddy.resource

Test Setup          As a "Admin" I want to open KitchenBuddy portal    ${WEBURL}
Test Teardown       As a "Admin" I want to close the browser


*** Variables ***
${WEBURL}               https://www.waiterbuddy.nl/foodticket/cgi/admin.cgi?application=WA&language=en
${GEBRUIKERSNAAM}       amirdhamutrecht
${WACHTWOORD}           wijzigen
${HEADLESS}             on
# http://77.169.167.216:1880/openOrders
# ${APIURL}    http://92.70.63.97:1880/openOrders


*** Test Cases ***
OrderBuddy_001: As an "Administrator", I want to fetch customers orders in each table
    [Documentation]    Fetch customer orders
    [Tags]    smoke    regression
    Submit user details    ${GEBRUIKERSNAAM}    ${WACHTWOORD}
    Navigate to Table menu item
    Fetch each table order details
    Log    V2.0: Waiterbuddy Execution-done!
