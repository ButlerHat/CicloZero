import os
import streamlit as st


def ciclai_orders():
    # Title
    main_color = st.secrets.theme.primaryColor
    st.markdown(f'# <span style="color:{main_color}">CiclAI</span> Automations', unsafe_allow_html=True)
    st.markdown('En esta sección se encuentran las automatizaciones que se pueden descargar para su uso en cualquier ordenador.')
    st.markdown('---')
    st.markdown(f'## <span style="color:{main_color}">CiclAI</span> Orders', unsafe_allow_html=True)

    # Set info
    st.markdown("""
    ### Instrucciones: Setup (Solo la priemra vez)

1. Descargar en la página el .zip (Botón Descargar CiclAI Orders)
2. Descomprimir el .zip
3. Doble click en setup.bat

    """)

    
    # Download button
    if not os.path.exists(st.secrets.paths.orders_zip):
        st.error('No se ha encontrado el archivo CiclAI Orders. Contacta con el administrador.')
        return
    
    with open(st.secrets.paths.orders_zip, 'rb') as f:
        st.download_button(label='Descargar CiclAI Orders', data=f, file_name='CiclAiOrders.zip')

    st.markdown("""

### Instrucciones: Ejecución

1. Click derecho en el explorador de archivos dentro de la carpeta
2. Abrir con terminal
3. Ejecutar comando: `rcc run`

### Funcionamiento CiclAI Orders
Cada vez que se ejecute el comando, se abrirá un nuevo navegador en incógnito. Se automatiza el proceso de 
login y se abre hasta la página de ventas.

Ahí se detendrá la ejecución y se pedirá el IMEI y que clickes una de las opciones de la tabla. Una vez se hayan
hecho esas dos acciones, clickar en OK para que se termine de hacer el proceso. En el caso en el que no se quiera
continuar a partir de este punto pulsar Cancelar.
    """)
    st.info('Siempre se puede cancelar la ejecución de CiclAI Orders pulsando Ctrl+C en la terminal.')
    st.info('El tamaño de la navegador no se puede cambiar durante la ejecución de CiclAI Orders.')

