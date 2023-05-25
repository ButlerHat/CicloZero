*** Settings ***
Library    ButlerRobot.AIBrowserLibrary  record=${False}  presentation_mode=${True}  console=${False}  fix_bbox=${TRUE}  output_path=${OUTPUT_DIR}${/}data  WITH NAME  Browser 
Library    Dialogs
Resource   .${/}CrawlOdoo.resource
Variables  .${/}credentials.py
Suite Setup  Browser.Add Task Library    CrawlOdoo
Suite Teardown  Run Keyword If Any Tests Failed    Pause Execution    Algo salió mal. Para más información, abra en el navegador el fichero 'log.html' dentro de la carpeta.


*** Variables ***
${DEFAULT_AI_MODE}  Flexible
${ROBOT_CICLOZERO_PASS}  V6#hYk$3YkAWs5XrJnbG$Z!ue#s


*** Test Cases ***
Confirmacion pedidos
    Comment  Obtener inventario de Odoo
    New Browser    chromium    headless=false  downloadsPath=${OUTPUT_DIR}${/}downloads
    New Context    acceptDownloads=${TRUE}
    Wait New Page       https://backoffice.ciclozero.com/  wait=${3}

    Click on "Identificarse"
    CrawlOdoo.Login with user ${odoo_user} and pass ${odoo_pass}
    Go to menu icon at the top left
    Go to Ventas

    # Paso a mano.
    ${imei}  Get Value From User    Seleccione en la tabla el cliente e introduzca el IMEI. ${\n}En cuanto se encuentre dentro del pedido, pulse OK.
    
    Click on "Confirmar"
    Click on Entrega
    Click on "Editar" at the top left
    # Check if the table has only one row
    Check if table operaciones detalladas only has one row
    Click on table operaciones detalladas in the third column
    Click on table operaciones detalladas in the third column
    Click on "Buscar más..." in the dropdown
    Input ${imei} in 'Buscar...' input
    Keyboard Key    press    Enter
    Click on the first row of the table
    Click on "Aceptar Reserva" in the first row
    Click on "Validar" purple button
    Click on "Guardar" at the top left
    Go Back

    Click on "Crear factura"
    Click on "Crear y ver factura" in the popup
    Click on "Publicar" at the top
    Click on "Registrar pago" at the top
    Click on "Validar" on the popup
