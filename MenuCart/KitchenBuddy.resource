*** Settings ***
Documentation       This resource file consist of every keyword that's being used regarding the active customer orders.

Library             Browser
Library             OperatingSystem
Library             Collections


*** Variables ***
${NO_ORDERS_EN}     There are no orders yet.
${NO_ORDERS_NL}     Er zijn nog geen orders.
${ORDERS_LIST}      ${EXECDIR}${/}Orders.txt
${MSG}              ${EMPTY}


*** Keywords ***
As a "${ADMIN}" I want to open KitchenBuddy portal
    [Documentation]    this keyword ensures user is able to open kitchenbuddy portal
    [Tags]    openpage
    [Arguments]    ${url}
    New Browser    chromium    headless=false    args=["--start-maximized"]
    # New Context    viewport={'width': 1920, 'height': 1080}
    New Context    viewport=${None}
    New Page    ${url}
    Sleep    1s

Submit user details
    [Documentation]    this keyword ensures that authorized user is able to login to the portal.
    [Tags]    login
    [Arguments]    ${username}    ${password}
    # Click    li[data-lang="en"]
    # sleep    2s
    Fill Text    [name="login"]    ${username}
    Fill Text    [name="password"]    ${password}
    Click    id=login-button
    sleep    1s
    Get Title    ==    OrderBuddy - Vegnation
    Wait For Elements State    span:has-text("Logged in as Vegnation")    visible
    Take Screenshot

Check customers orders exists
    [Documentation]    this keyword ensures that check customers orders exists or not. there is not test failure if there were no orders!
    [Tags]    check_orders_exists
    ${element_status}    Run Keyword And Return Status
    ...    Get Element
    ...    div#kitchen-orders:has-text("There are no orders yet.")
    IF    ${element_status} == ${true}
        ${orders_load}    Get Text    div#kitchen-orders:has-text("There are no orders yet.")
        Should Be Equal    ${orders_load}    ${NO_ORDERS_EN}
        Log    ${NO_ORDERS_EN}
        Set Test Variable    ${MSG}    ${NO_ORDERS_EN}
    ELSE
        Wait For Elements State    div.content>div#kitchen-orders>div[data-id]:nth-child(1)    visible
        Set Test Variable    ${MSG}    *** There are active orders present! Please wait while fetching orders!! ***
    END
    RETURN    ${MSG}

As a "${ADMIN}" I want to fetch customer orders
    [Documentation]    check customers orders exists then only start fetch
    [Tags]    read_orders
    Create File    ${ORDERS_LIST}
    File Should Be Empty    ${ORDERS_LIST}
    ${info}    Check customers orders exists
    IF    "${info}" == "${NO_ORDERS_EN}"
        @{retrieve_ordersdata}    Create List    ${info} & We are waiting for orders with patience!${\n}
    ELSE
        @{tables}    Get Elements    div.content>div#kitchen-orders>div[data-id]
        ${table_count}    Get Length    ${tables}
        @{retrieve_ordersdata}    Create List    No.of active customer orders:'${table_count}'${\n}
        ${dataId_index}    Evaluate    1
        FOR    ${tafel}    IN    @{tables}
            ${tafel_orderId}    Run Keyword And Return Status
            ...    Get Element
            ...    div.content>div#kitchen-orders>div[data-id]:nth-child(${dataId_index})>div.kitchen-time
            IF    ${tafel_orderId} == ${true}
                ${table_name}    Get Text
                ...    div.content>div#kitchen-orders>div[data-id]:nth-child(${dataId_index})>div.kitchen-time
                Append To List    ${retrieve_ordersdata}    Table:${SPACE*5}${table_name}${\n}
                # ${table_number}    Get Text
                # ...    div.content>div#kitchen-orders>div[data-id]:nth-child(${dataId_index})>div.kitchenrow-id>strong
                # Append To List    ${retrieve_ordersdata}    Table Number>>> ${table_number}
                ${table_orderId}    Get Text
                ...    div.content>div#kitchen-orders>div[data-id]:nth-child(${dataId_index})>div.kitchenrow-id
                Append To List    ${retrieve_ordersdata}    ${SPACE*3}${table_orderId}${\n}
                @{fetch_orderlist}    Get Elements
                ...    div.content>div#kitchen-orders>div[data-id]:nth-child(${dataId_index})>div.kitchen-table-wrapper>>tbody>tr
                ${menu_count}    Get Length    ${fetch_orderlist}
                ${tr_index}    Evaluate    1
                FOR    ${element}    IN    @{fetch_orderlist}
                    ${order_quantity}    Get Text
                    ...    div.content>div#kitchen-orders>div[data-id]:nth-child(${dataId_index})>div.kitchen-table-wrapper>>tbody>tr:nth-child(${tr_index})>td:nth-child(1)
                    # Append To List    ${retrieve_ordersdata}    Order Quantity>> ${order_quantity}${\n}
                    ${order_category}    Get Text
                    ...    div.content>div#kitchen-orders>div[data-id]:nth-child(${dataId_index})>div.kitchen-table-wrapper>>tbody>tr:nth-child(${tr_index})>td:nth-child(2)>b
                    Append To List
                    ...    ${retrieve_ordersdata}
                    ...    ${SPACE*6} ${order_quantity}${SPACE*2}${order_category}${\n}
                    ${tr_index}    Evaluate    ${tr_index} + 1
                END
                Click    div.content>div#kitchen-orders>div[data-id]:nth-child(1)>button:has-text("Ready")
                Append To List    ${retrieve_ordersdata}    **************************************${\n}
            ELSE IF    ${tafel_orderId} == ${false}
                Click    button#reload-kitchenbuddy
                sleep    1s
                ${reload_oreder}    Get Text    div#kitchen-orders:has-text("There are no orders yet.")
                Should Be Equal    ${reload_oreder}    ${NO_ORDERS_EN}
                Append To List
                ...    ${retrieve_ordersdata}
                ...    Hey!! All orders are ready and we are happy to serve and hence '${reload_oreder}'${\n}
            END
            # ${dataId_index}    Evaluate    ${dataId_index} + 1
            sleep    2s    # <wait for 2sec time after click on ready button and tables sync>
        END
    END
    # write the list data into a file:
    File Should Exist    ${ORDERS_LIST}
    ${esize}    Get File Size    ${ORDERS_LIST}
    IF    ${esize} == 0
        Log    Oops! File is not flushed properly before load orders!
    ELSE
        FOR    ${filecontent}    IN    @{retrieve_ordersdata}
            ${length}    Get Length    ${filecontent}
            Run Keyword if    ${length} == 0
            Append To List    ${retrieve_ordersdata}    ${filecontent}${\n}
        END
        Append To List    ${retrieve_ordersdata}    All orders are served success! Eetsmakelijk!!${\n}
    END
    FOR    ${element}    IN    @{retrieve_ordersdata}
        Append To File    ${ORDERS_LIST}    ${element}    encoding=UTF-8
    END

As a "${ADMIN}" I want to close the browser
    [Documentation]    this keyword ensures that browser is closed after all tests
    [Tags]    logout
    Take Screenshot
    Close Browser
