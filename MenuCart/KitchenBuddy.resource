*** Settings ***
Documentation       This resource file consist of every keyword that's being used regarding the active customer orders.

Library             Browser
Library             OperatingSystem
Library             Collections
Library             String
Library             requests
Library             jsonschema
Library             RequestsLibrary


*** Variables ***
${BROWSER}                          chromium
${APIURL}                           http://92.70.63.97:1880
${endpoint}                         /openOrders
${NO_ORDERS_EN}                     There are no orders yet.
${NO_ORDERS_NL}                     Er zijn nog geen orders.
${ORDERS_LIST}                      ${EXECDIR}${/}Orders.txt
${MSG}                              ${EMPTY}
# ${KB_TITLE}    OrderBuddy - Vegnation
@{TABLE_ORDERS}                     @{EMPTY}
@{ITEMNAMES_SUBSET_TABLEORDERS}     @{EMPTY}
${ORDERS}                           ${EXECDIR}${/}TafelOrders.json
@{ITEMNAMES_SUBSET_TABLEORDERS}     @{EMPTY}
${ORDERS}                           ${EXECDIR}${/}TafelOrders.json
${sign_alphas}                      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"


*** Keywords ***
As a "${ADMIN}" I want to open KitchenBuddy portal
    [Documentation]    this keyword ensures user is able to open kitchenbuddy portal
    [Tags]    openpage
    [Arguments]    ${url}
    New Browser    ${BROWSER}    headless=true    args=["--start-maximized"]
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
    Fill data    ${username}    ${password}
    Get Title    ==    OrderBuddy - Vegnation
    # Wait For Elements State    span:has-text("Logged in as Vegnation")    visible
    Take Screenshot

Fill data
    [Arguments]    ${username}    ${password}
    Fill Text    [name="login"]    ${username}
    Fill Text    [name="password"]    ${password}
    Click    id=login-button
    Sleep    1s
    Sleep    1s

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
    END
    # ELSE
    #    Scroll To Element    div.content>div#kitchen-orders>div[data-id]:nth-child(1)
    #    Wait For Elements State    div.content>div#kitchen-orders>div[data-id]:nth-child(1)    visible
    #    Set Test Variable    ${MSG}    *** There are active orders present! Please wait while fetching orders!! ***
    # END
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
                Sleep    1s
                Sleep    1s
                ${reload_oreder}    Get Text    div#kitchen-orders:has-text("There are no orders yet.")
                Should Be Equal    ${reload_oreder}    ${NO_ORDERS_EN}
                Append To List
                ...    ${retrieve_ordersdata}
                ...    Hey!! All orders are ready and we are happy to serve and hence '${reload_oreder}'${\n}
            END
            # ${dataId_index}    Evaluate    ${dataId_index} + 1
            Sleep    2s    # <wait for 2sec time after click on ready button and tables sync>
            Sleep    2s    # <wait for 2sec time after click on ready button and tables sync>
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

Navigate to Table menu item
    [Tags]    tables
    Wait For Elements State    button.tables    visible
    Click    button.tables
    Wait For Elements State    div[table-id]:nth-child(2)    visible

Read Product remakrs section
    [Tags]    remarks
    [Arguments]    ${iData}    ${item_name}
    # read description (or) remarks field if it's present only
    ${remarks}    Get Element States
    ...    //tr[@data-i="${iData}"]//td[@class="desc"]/span[@class="remark set"]
    ...    then
    ...    bool(value & visible)
    IF    ${remarks} == True
        ${item_name}    ${remark_!}    Split String From Right    ${item_name}    !
        Click    //tr[@data-i="${iData}"]//td[@class="desc"]/span[@class="remark set"]
        Sleep    1s
        # Check product 'Description' field. For Dosa items it will be textarea.
        ${product_remarks}    Run Keyword And Return Status    Get Element States
        ...    //textarea[@name="remarks"][text()]
        ...    then
        ...    bool(value & visible)
        # rechecking remarks variable.
        ${product_remarks}    Get Element States
        ...    //textarea[@name="remarks"][text()]
        ...    then
        ...    bool(value & visible)
        ${remark_set}    Evaluate    "null"
        IF    ${product_remarks} == True
            # "Remarks for Product" remark field is unique coming for Dosa items.
            ${remark_set}    Get Text    //textarea[@name="remarks"][text()]
            Click    button#cancel
            # other than Dosa, remarks filed
        ELSE
            ${remark_set}    Get text
            ...    //div[@class="popup-content"]/form/p/label[text()="Description"]/../input[@name="input"]
            Click    //div[@id='input-popup']//button[text()="Ok"]
        END
    ELSE
        ${remark_set}    Evaluate    "null"
    END
    RETURN    ${remark_set}    ${item_name}

Fetch Item topings
    [Tags]    toping
    [Arguments]    ${iData}
    # fetch item-toping's if exists::
    @{item_topings}    Create List
    ${isToping_exists}    Get Element States
    ...    //tr[@data-i="${iData}"]/td[@class="desc"]/em
    ...    then
    ...    bool(value & visible)
    IF    ${isToping_exists} == True
        ${getTopings}    Get Text    //tr[@data-i="${iData}"]/td[@class="desc"]/em
        # ex: [cheese 2x (2,00), podi (1,00), masala (1,00)]
        ${removeExtrachrs_topings}    Remove String
        ...    ${getTopings}
        ...    (
        ...    0
        ...    )
        ...    1
        ...    2
        ...    3
        ...    4
        ...    5
        ...    6
        ...    7
        ...    8
        ...    9
        ...    0
        ...    x
        ${removeExtrachrs_topings}    Replace String    ${removeExtrachrs_topings}    ,,    ,
        @{topinslist_app}    Split String    ${removeExtrachrs_topings}    ,
        FOR    ${index}    ${element}    IN ENUMERATE    @{topinslist_app}
            ${element}    Set variable    ${element.strip()}
            IF    "${element}" == "${EMPTY}"    CONTINUE
            ${isComma}    Run Keyword And Return Status    Should Contain    ${element}    ,
            IF    ${isComma} == True    CONTINUE
            Append To List    ${item_topings}    ${element}
        END
    ELSE
        ${item_topings}    Evaluate    'null'
    END
    RETURN    ${item_topings}

Gather data on orders placed at tables
    [Tags]    open_orders
    @{tr_table_ids}    Get Elements    //div[@class="popup-content"]/div[@table-id][@order-id]
    @{orders_placed_tables}    Create List
    FOR    ${element}    IN    @{tr_table_ids}
        ${tb_order_id}    Get Attribute    ${element}    order-id
        Append To List
        ...    ${orders_placed_tables}
        ...    //div[@class="popup-content"]/div[@table-id][@order-id="${tb_order_id}"]
    END
    RETURN    @{orders_placed_tables}

Fetch each table order details
    [Tags]    read_tbale_item
    Create File    ${ORDERS}
    File Should Be Empty    ${ORDERS}
    Create File    ${ORDERS}
    File Should Be Empty    ${ORDERS}
    ${info}    Check customers orders exists
    Log    Before fetch, check orders are placed!, ${info}

    @{table_order_ids}    Gather data on orders placed at tables
    # Scroll To Element    (//div[@class="popup-content"]/div[@table-id][@order-id])[1]
    # @{table_ids}    Get Elements    //div[@class="popup-content"]/div[@table-id][@order-id]
    # @{table_ids}    Get Elements    @{table_order_ids}
    # ${table_id}    Get Length    ${table_ids}
    ${tIndex}    Evaluate    1
    # ****** Step1: Start fetch tafels *****
    FOR    ${t_orderId}    IN    @{table_order_ids}
        ${table_visible}    Get Element States
        ...    (//div[@table-id][@order-id])[${tIndex}]
        ...    then
        ...    bool(value & visible)
        Sleep    1s
        ${table_visible}    Get Element States
        ...    (//div[@table-id][@order-id])[${tIndex}]
        ...    then
        ...    bool(value & visible)
        Sleep    1s
        Wait For Elements State    (//div[@table-id][@order-id])[${tIndex}]    visible
        ${order_table}    Get Text    (//div[@table-id][@order-id])[${tIndex}]
        ${order_table}    Replace String    ${order_table}    \n    _
        ${tb}    ${price}    Split String From Right    ${order_table}    _
        ${tb}    Convert To Integer    ${tb}    ${None}
        Click    ${t_orderId}
        Sleep    1s
        ${order_visible}    Get Element States
        ...    div#pos-ticket>h2[data-org]
        ...    then
        ...    bool(value & visible)
        Sleep    1s
        ${order_visible}    Get Element States
        ...    div#pos-ticket>h2[data-org]
        ...    then
        ...    bool(value & visible)
        Wait For Elements State    div#pos-ticket>h2[data-org]    visible
        ${orderId}    Get Text    div#pos-ticket>h2[data-org] >span
        ${tableNum}    Get Text    //div[@id="pos-ticket"]/h2[text()][@data-org="Order"]
        ${orderId}    Replace String    ${orderId}    \#    ${EMPTY}
        @{menuItems}    Get Elements    //tbody/tr[@data-i]
        ${iData}    Evaluate    0
        FOR    ${menuItem}    IN    @{menuItems}
            ${getQuantity_no}    Get Element States
            ...    //tbody/tr[@data-i="${iData}"]/td[1]/input
            ...    then
            ...    bool(value & visible)
            ${getQuantity_no}    Get Element States
            ...    //tbody/tr[@data-i="${iData}"]/td[1]/input
            ...    then
            ...    bool(value & visible)
            ${item_quantity}    Get Attribute    //tbody/tr[@data-i="${iData}"]/td[1]/input    value
            ${item_quantity}    Convert To Integer    ${item_quantity}    ${None}
            ${item_name}    Get Text    //tr[@data-i="${iData}"]/td[@class="desc"]
            ${item_name}    Replace String    ${item_name}    \n    ${EMPTY}
            ${item_price}    Get Text    //tr[@data-i="${iData}"]/td[@class="price"]

            # 19/11: Read toping's if exists::
            ${item_topings}    Fetch Item topings    ${iData}

            # read description (or) remarks field if it's present only
            ${remark_set}    ${item_name}    Read Product remakrs section    ${iData}    ${item_name}

            # 19/11: [NOTE]- If an item has topings, without remarks, Itemname coming as Item+toping together.
            # ["itemName": "onion podi masalaonion    podi"]    -- need future fix
            ${itemHas_toping_noremarks}    Run Keyword And Return Status
            ...    Should Contain
            ...    ${item_name}    )
            IF    "${remark_set}" == "null" and ${itemHas_toping_noremarks}==True
                ${reclasify_item_name}    Remove String
                ...    ${item_name}
                ...    (
                ...    ,
                ...    0
                ...    )
                ...    1
                ...    2
                ...    3
                ...    4
                ...    5
                ...    6
                ...    7
                ...    8
                ...    9
                ...    0
                ...    x
                ${item_name}    Set variable    ${reclasify_item_name.strip()}
            END
            # Generate table order in dictionary variable:
            &{order_set}    Create Dictionary
            ...    orderNo=${orderId}
            ...    tableNo=${tb}
            ...    quantity=${item_quantity}
            ...    itemName=${item_name}
            ...    itemCategory=starters
            ...    rank=3
            ...    uuid=null
            ...    itemStatus=open
            ...    remarks=${remark_set}
            ...    topings=${item_topings}
            Append To List    ${TABLE_ORDERS}    ${order_set}
            Append To List    ${ITEMNAMES_SUBSET_TABLEORDERS}    ${item_name}    ${orderId}
            ${iData}    Evaluate    ${iData} + 1
        END

        # write Body into JSON file
        ${sdict}    Evaluate    json.dumps(${TABLE_ORDERS})    json
        Append To File    ${ORDERS}    ,${sdict}

        # **** Send API - POST CALL ****
        Create Session    ordersession    ${APIURL}
        ${headers}    Create Dictionary    Content-Type=application/json
        ${response}    POST On Session
        ...    ordersession
        ...    ${endpoint}
        ...    json=${TABLE_ORDERS}
        ...    headers=${headers}

        # ************ Response Validations ****************
        ${res_status_code}    Convert To String    ${response.status_code}
        Should Be Equal    ${res_status_code}    200
        ${response_json}    Convert To String    ${response.content}
        FOR    ${assertItem}    IN    @{ITEMNAMES_SUBSET_TABLEORDERS}
            ${assertItem}    Convert To String    ${assertItem}
            Should Contain    ${response_json}    ${assertItem}
        END
        # Move to next table:
        Click    button.tables
        ${tIndex}    Evaluate    ${tIndex} + 1
        Sleep    1s

        # empty json list before read next table
        @{TABLE_ORDERS}    Create List
        @{ITEMNAMES_SUBSET_TABLEORDERS}    Create List
    END

    # click on close icon from "Tafels" pop-up:
    Click    //div[contains(@class, "popup popup-tables")]//button[@class="popup-close-x"]
