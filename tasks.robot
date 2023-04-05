*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Windows
Library             RPA.PDF
Library             RPA.MSGraph
Library             RPA.Archive
Library             RPA.RobotLogListener


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the annoying modal
    Fill the form
    [Teardown]    Log Out And Close The Browser


*** Keywords ***
Open the robot order website
    # =-=-=- Baixando Arquivo -=-=-=-=
    Download    https://robotsparebinindustries.com/orders.csv    %{ROBOT_ROOT}${/}orders.csv    overwrite=${True}
    # =-=-=- Abrindo Site -=-=-=-=
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the annoying modal
    # =-=-=- Clicando em "Ok" na janela de alerta -=-=-=-=
    Click Element    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    # # =-=-=- Selecionando "Head" -=-=-=-=
    # Select From List By Index    //*[@id="head"]    1
    # # =-=-=- Selecionando "Body" -=-=-=-=
    # Select Radio Button    body    1
    # # =-=-=- Selecionando "Legs" -=-=-=-=
    # Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    2
    # # =-=-=- Selecionando "Adress" -=-=-=-=
    # Input Text    //*[@id="address"]    Endereco

    # Click Element    //*[@id="preview"]
    # Set Wait Time    1
    # Click Element    //*[@id="order"]

    # Wait Until Element Is Visible    //*[@id="receipt"]
    # # =-=-=- Obtendo "OrderID" -=-=-=-=
    # ${OrderId}    RPA.Browser.Selenium.Get Text    //*[@id="receipt"]/p[1]

    # ${order_receipt_html}    Get Element Attribute    //*[@id="receipt"]    outerHTML
    # Html To Pdf    content=${order_receipt_html}    output_path=${OUTPUT_DIR}${/}${OrderId}.pdf

    # Take a screenshot of the robot    ${OrderId}

    # Open Pdf    ${OUTPUT_DIR}${/}${OrderId}.pdf

    # ${file}    Create List    ${OUTPUT_DIR}${/}${OrderId}.png

    # Add Files To Pdf    ${file}    ${OUTPUT_DIR}${/}${OrderId}.pdf    ${True}

    # Close Pdf    ${OUTPUT_DIR}${/}${OrderId}.pdf

    # Create a ZIP file of receipt PDF files

Fill the form
    ${order}    Read table from CSV    %{ROBOT_ROOT}${/}orders.csv
    FOR    ${element}    IN    @{order}
        Log    ${element}[Head]
        # =-=-=- Selecionando "Head" -=-=-=-=
        Select From List By Index    //*[@id="head"]    ${element}[Head]
        # =-=-=- Selecionando "Body" -=-=-=-=
        Select Radio Button    body    ${element}[Body]
        # =-=-=- Selecionando "Legs" -=-=-=-=
        Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${element}[Legs]
        # =-=-=- Selecionando "Adress" -=-=-=-=
        Input Text    //*[@id="address"]    ${element}[Address]
        # =-=-=- Clicando em "Previwew" -=-=-=-=
        Click Element    //*[@id="preview"]
        Set Wait Time    1
        # =-=-=- Clicando em "Order" -=-=-=-=
        Click Element    //*[@id="order"]

        Wait Until Element Is Visible    //*[@id="receipt"]
        # =-=-=- Obtendo "OrderID" -=-=-=-=
        ${OrderId}    RPA.Browser.Selenium.Get Text    //*[@id="receipt"]/p[1]

        Store the receipt as a PDF file    ${OrderId}
        Take a screenshot of the robot    ${OrderId}
        Embed the robot screenshot to the receipt PDF file    ${OrderId}
        # =-=-=- Clicando em    "Order Another Robot" -=-=-=-=
        Click Element    //*[@id="order-another"]
        Close the annoying modal
    END

    Create a ZIP file of receipt PDF files
    Close Workbook

Take a screenshot of the robot
    [Arguments]    ${OrderId}
    Wait Until Element Is Visible    //*[@id="robot-preview-image"]
    Capture Element Screenshot    //*[@id="robot-preview-image"]    ${OUTPUT_DIR}${/}${OrderId}.png

Create a ZIP file of receipt PDF files
    Archive Folder With Zip    ${OUTPUT_DIR}    ${OUTPUT_DIR}${/}pdf_archive.zip    recursive=True    include=*.pdf

Log Out And Close The Browser
    Close Browser

Store the receipt as a PDF file
    [Arguments]    ${OrderId}
    ${order_receipt_html}    Get Element Attribute    //*[@id="receipt"]    outerHTML
    Html To Pdf    content=${order_receipt_html}    output_path=${OUTPUT_DIR}${/}${OrderId}.pdf

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${OrderId}
    Open Pdf    ${OUTPUT_DIR}${/}${OrderId}.pdf

    ${file}    Create List    ${OUTPUT_DIR}${/}${OrderId}.png

    Add Files To Pdf    ${file}    ${OUTPUT_DIR}${/}${OrderId}.pdf    ${True}

    Close Pdf    ${OUTPUT_DIR}${/}${OrderId}.pdf
