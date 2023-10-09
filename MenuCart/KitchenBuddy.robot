*** Settings ***
Documentation       As an administrator I have ability to create and run orders using kitchenbuddy portal.
...                 For Example: In this scenario open the portal and fetch customer orders and then submit order ready state.

Resource            KitchenBuddy.resource

Test Setup          As a "Admin" I want to open KitchenBuddy portal    ${BASEURL}
Test Teardown       As a "Admin" I want to close the browser

Task Tags           kitchenbuddy    food_orders    waiterbuddy


*** Variables ***
${BASEURL}              https://www.kitchenbuddy.nl/foodticket/cgi/admin.cgi?application=KA&language=en
# ${URL}    https://www.waiterbuddy.nl/foodticket/cgi/admin.cgi?application=WA&language=en
${GEBRUIKERSNAAM}       amirdhamutrecht
${WACHTWOORD}           wijzigen
${HEADLESS}             on    # browser will not launch upon test execution. If need brower GUI load, replace 'off' instead of 'on'


*** Test Cases ***
KB-01: Load KitchenBuddy portal and fetch customer order details
    [Documentation]    this test case ensures that authorized user login and review and place orders ready for customer serve.
    [Tags]    smoke    master
    # As a "Admin" I want to open KitchenBuddy portal    ${BASEURL}
    Submit user details    ${GEBRUIKERSNAAM}    ${WACHTWOORD}
    As a "Admin" I want to fetch customer orders
    Log    V1: Test execution done!!
