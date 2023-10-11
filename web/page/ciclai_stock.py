import asyncio
import os
import datetime
import streamlit as st
import utils.cron as cron
import utils.robot_handler as robot_handler
import utils.robot_results as robot_results
import utils.excel as excel
import utils.vnc as vnc
from utils.robot_results import RobotStatus


PAGES = {
    "Woocommerce": "CiclAiStockUpdateWoocommerce.robot",
    "Amazon": "CiclAiStockUpdateAmazon.robot",
    "Ebay": "CiclAiStockUpdateEbay.robot",
}

STOCK_IDS = [
    "stock_odoo",
    "stock_woocommerce_amazon_ebay_unshipped",
    "stock_amazon_ebay_pending",
    "stock_results"
]

def disable():
    st.session_state.disabled = True

def enable():
    if "disabled" in st.session_state and st.session_state.disabled == True:
        st.session_state.disabled = False
        with st.sidebar:
            st.info("To enable buttons, reload the page. The page info will be lost")
        # st.experimental_rerun()

def instructions_to_install_extension():
    st.markdown("# Login to Ebay")
    st.markdown("If you are showing this message, it means that CiclAI is not logged to Ebay. To login, follow these steps:")
    
    st.markdown("## 1. Install the CiclAI extension")
    st.markdown("1.1 Download the extension from the button below")
    st.download_button(label="Download extension", data=open(st.secrets.paths.extension, 'rb'), file_name="ciclai_extension.zip", key="download_extension")
    st.markdown("1.2 Unzip the extension in a folder")
    st.markdown("1.2 Open Chrome and go to <a href='chrome://extensions/' target='_blank'>chrome://extensions/</a>", unsafe_allow_html=True)
    st.markdown("1.3 Enable developer mode at the top right")
    st.markdown("1.4 Click on 'Load unpacked' or 'Cargar descomprimida' and select the folder where you unzipped the extension")
    st.markdown("1.5 The extension should be installed")

    st.markdown("## 2. Login to Ebay")
    st.markdown("2.1 Open Chrome and go to <a href='https://signin.ebay.com/' target='_blank'>https://signin.ebay.com/</a>", unsafe_allow_html=True)
    st.markdown("2.2 Login to Ebay")
    st.markdown("2.3 Click on the extension icon and click on 'Extract data'")
    st.markdown("2.4 Copy the cookies and paste them in the field 'Insert cookies'")


def auth_with_servers():
    st.markdown("---")
    st.markdown("## Auth with servers")
    col1, col2, col3, col4 = st.columns([1, 1, 1, 1])
    with col1:
        st.markdown("### Odoo")
        st.success("With credentials")

    with col2:
        st.markdown("### Amazon seller")
        st.success("With credentials")
    
    with col3:
        st.markdown("### Woocommerce")
        st.success("With credentials")
    
    with col4:
        st.markdown("### Ebay")
        if not hasattr(st.session_state, 'logged_ebay'):
            st.session_state.logged_ebay = False
        
        if st.session_state.logged_ebay:
            auth = True
            st.success("Logged to eBay")
        else:
            args = [
                f"COOKIES_DIR:{st.secrets.paths.cookies_dir}",
                ]
            ret_code = asyncio.run(robot_handler.run_robot(
                'login_ebay', 
                args, 
                "CiclAiLoginEbay.robot", 
                msg_fail='', 
                msg_success="Logged to Ebay",
                msg_info="Checking cookies on eBay",
                notify=False
            ))
            auth = ret_code == 0
            
            if auth:
                st.session_state.logged_ebay = True
            
    # Cookies
    if not auth:
        ebay_url = 'https://signin.ebay.com/'
        st.error("Not logged to Ebay. Use the tutorial below to login")
        st.markdown(f'<a href="{ebay_url}" target="_blank">Login Ebay</a>', unsafe_allow_html=True)
        # Add a field to insert cookies
        with st.form("Insert cookies for eBay"):
            cookies = st.text_area("Insert cookies for eBay")
            if st.form_submit_button("Save cookies", type="primary"):
                if cookies:
                    with open(st.secrets.paths.state_json, 'w') as f:
                        f.write(cookies)
                    # Lauch robot to check if cookies are valid
                    args = [
                        f"COOKIES_DIR:{st.secrets.paths.cookies_dir}",
                        f"STATE_JSON:{st.secrets.paths.state_json}"
                    ]
                    ret_code = asyncio.run(robot_handler.run_robot(
                        'state_ebay', 
                        args, 
                        "CiclAiSaveStateEbay.robot", 
                        msg_fail="Cookies not valid", 
                        msg_success="Cookies saved. Reload window",
                        msg_info="Checking cookies on eBay",
                        notify=True))
                else:
                    st.error("No cookies found. Use the tutorial below to login")
        
    with st.expander("Login with extension for eBay", expanded=False):
        instructions_to_install_extension()


## Create a function to display a title of "Ciclai Stock", a Run button and a cron field to schedule the task
def ciclai_stock():
    # Disable all buttons while the task is running
    if "disabled" not in st.session_state:
        st.session_state.disabled = False

    # Title
    main_color = st.secrets.theme.primaryColor
    st.markdown(f'# <span style="color:{main_color}">CiclAI</span> Stock', unsafe_allow_html=True)

    # Set cron
    st.markdown("## Program time")
    with st.expander("Schedule the job", expanded=False):
        col1, col2 = st.columns(2)

        col1.markdown(" ### Time")
        cron_str = col1.text_input("Cron", "0 0 * * *"),
        nl_cron = cron.cron_to_natural_language(cron_str[0])
        if nl_cron:
            col1.markdown(f"Next run: {nl_cron}")
        else:
            col1.error("Invalid cron format")
        
        # List jobs
        col2.markdown(" ### Jobs list")
        c = col2.empty()
        c.code("\n".join(cron.get_cron_jobs()))

        # Create cron script
        stock_path = st.secrets.paths.stock_excel
        excel_name = 'CiclAiStock_$(date +"%H-%M_%d-%m-%Y").xlsx'
        csv_name = 'CiclAiStock_$(date +"%H-%M_%d-%m-%Y").csv'
        excel_path = f'excel_path={os.path.join(stock_path, excel_name)}'
        csv_path = f'csv_path={os.path.join(stock_path, csv_name)}'
        robot_path = st.secrets.paths.robot
        results_path = os.path.join(robot_path, "results")
        scripts_robot = []
        
        # CiclAI Stock
        args = [
            f'RESULT_EXCEL_PATH:$excel_path',
            f'RESULT_CSV_PATH:$csv_path'
        ]
        for i in range(1, 5):
            robot_command = robot_handler.get_pabot_command(f"stock_{i}", args, "CiclAiStock.robot", [str(i)])
            log_file_stock_path = os.path.join(results_path, f"stock_{i}", f'logfile_out_stock.txt')
            html_file_stock_path = os.path.join(results_path, f"stock_{i}", f'log.html')
            script_robot = robot_command + f' > {log_file_stock_path} 2>&1'
            notification_sh = f""" || curl \
                    -T "{html_file_stock_path}" \
                    -H "X-Email: paipayainfo@gmail.com" \
                    -H "Tags: warning" \
                    -H "Filename: CiclAiStock_fail_auto_$(date +"%H-%M_%d-%m-%Y").html" \
                    "https://notifications.paipaya.com/ciclai_fail"
                """
            scripts_robot.append(script_robot + notification_sh)

        # CiclAI Stock Update
        args_update = [
            'STOCK_EXCEL_PATH:$excel_path',
            f"COOKIES_DIR:{st.secrets.paths.cookies_dir}"
        ]

        for page, robot_file in PAGES.items():
            robot_command = robot_handler.get_robot_command(page, args_update, robot_file)
            # Redirect output to log file
            log_file_path = os.path.join(results_path, page, f'logfile_out_{page}.txt')
            html_file_stock_path = os.path.join(results_path, page, f'log.html')
            script_robot = robot_command + f' > {log_file_path} 2>&1'
            notification_sh = f""" || curl \
                -T "{html_file_stock_path}" \
                -H "X-Email: paipayainfo@gmail.com" \
                -H "Tags: warning" \
                -H "Filename: CiclAiStockUpdate_{page}_fail_auto_$(date +"%H-%M_%d-%m-%Y").html" \
                "https://notifications.paipaya.com/ciclai_fail"
            """
            scripts_robot.append(script_robot + notification_sh)

        # Create jobs folder
        if not os.path.exists(os.path.join(st.secrets.paths.robot, "jobs")):
            os.makedirs(os.path.join(st.secrets.paths.robot, "jobs"))
        cron_script_path = os.path.join(st.secrets.paths.robot, "jobs", "stock.sh")
        with open(cron_script_path, 'w') as f:
            f.write("#!/bin/bash\n")
            f.write(f"export DEVELOPMENT_SERVER={os.environ.get('DEVELOPMENT_SERVER', '')}\n")
            f.write(f"export ROBOT_CICLOZERO_PASS='{os.environ.get('ROBOT_CICLOZERO_PASS', '')}'\n")
            f.write(f"export DISPLAY={os.environ.get('DISPLAY', '')}\n")
            f.write(f"export PYTHONPATH={os.environ.get('PYTHONPATH', '')}\n")
            f.write(f"export PATH={os.environ.get('PATH', '')}\n")
            # Remove old files from stock folder
            f.write(f"/opt/conda/envs/robotframework/bin/python {os.path.join(st.secrets.paths.robot, 'jobs' , 'delete_files.py')} " +
                    f"-d {st.secrets.paths.stock_excel} -l 7" +
                    f" > {os.path.join(st.secrets.paths.robot, 'jobs', 'delete_files.log')} 2>&1\n")
            f.write(excel_path + "\n")
            for script_robot in scripts_robot:
                f.write(script_robot + "\n")
            
        os.chmod(cron_script_path, 0o777)

        if st.button("Schedule", type="secondary", key="schedule", disabled=st.session_state.disabled):
            success = cron.insert_cron_job(cron_str[0], cron_script_path)
            if success:
                c.code("\n".join(cron.get_cron_jobs()))
                col1.success("Job scheduled successfully")
            else:
                col1.warning("Job already scheduled")

        if st.button("Delete", type="primary", key="delete", disabled=st.session_state.disabled):
            if cron.delete_cron_job(cron_str[0], cron_script_path):
                c.code("\n".join(cron.get_cron_jobs()))
                col1.success("Job deleted successfully")
            else:
                col1.warning("Job not found")
    
    # Set woocommerce file
    st.markdown("## Woocommerce file")
    with st.expander("Set woocommerce file", expanded=False):
        col1, col2 = st.columns([1, 2])
        file_path =  os.path.join(st.secrets.paths.woocommerce_files, "data_woocommerce_products.csv")
        with col1:
            st.markdown("### Download woocommerce file")
            if file_path is not None and os.path.exists(file_path):
                with open(file_path, 'rb') as f:
                    st.download_button(label="Download current woocommerce file", data=f, file_name="data_woocommerce_products.csv", disabled=st.session_state.disabled)
            else:
                st.error("No woocommerce file found")
            
            st.markdown("### Set new woocommerce file")
            with st.form("Upload woocommerce file"):
                uploaded_file = st.file_uploader("Upload woocommerce file", type=["csv"])
                if st.form_submit_button("Upload", type="primary", on_click=disable, disabled=st.session_state.disabled) and uploaded_file is not None:
                    excel.file_to_excel(uploaded_file, file_path)
                    st.success(f"File {uploaded_file.name} uploaded successfully")
                
        with col2:
            if file_path and os.path.exists(file_path):
                df = excel.load_csv_file(file_path)
                st.dataframe(df)
            else:
                st.error("No woocommerce file found")

    # Auth with servers
    auth_with_servers()

    # Run get stock
    run_get_stock()
    enable()

    # Show excel
    st.markdown("---")
    st.markdown("# Download last excel")
    option = get_last_excel()

    if option is None:
        st.info("No excel found")
        return

    col1, col2, _ = st.columns([2, 2, 3])

    last_file = os.path.join(stock_path, option)
    # Download excel
    with open(last_file, 'rb') as f:
        col1.download_button(label=option, data=f, file_name=option, key='last_excel')
    
    # Download csv
    csv_name = option.replace(".xlsx", ".csv")
    csv_path = os.path.join(stock_path, csv_name)
    if os.path.exists(csv_path):
        with open(csv_path, 'rb') as f:
            col2.download_button(label=f"LLM_{csv_name}", data=f, file_name=csv_name, key='last_csv')
    else:
        col2.info(f"CSV for LLM not generated")

    # Show excel
    st.markdown("## Show last excel")
    df = excel.load_excel_file(last_file)
    # Replace NaN with 0
    df = df.fillna(0)
    get_total = lambda count, amz_unshipped, amz_pending, ebay_unshipped, ebay_pending, flendu: count - amz_unshipped - amz_pending - ebay_unshipped - ebay_pending - flendu
    df['Total'] = df.apply(lambda row: get_total(row['count'], row['amz unshipped'], row['amz pending'], row["ebay unshipped"], row["ebay pending"], row['flend']), axis=1)
    st.dataframe(df)


def get_last_excel() -> str | None:
    stock_path = st.secrets.paths.stock_excel
    stock_excels = [os.path.join(stock_path, f) for f in os.listdir(stock_path) if os.path.isfile(os.path.join(stock_path, f))]
    stock_excels = [f for f in stock_excels if f.endswith(".xlsx")]
    stock_excels.sort(key=os.path.getmtime, reverse=True)
    stock_names = [os.path.basename(f) for f in stock_excels]
    return st.selectbox("Select a stock excel", stock_names, disabled=st.session_state.disabled)


def run_get_stock():
    stock_path = st.secrets.paths.stock_excel

    # Run button
    st.markdown("---")
    st.markdown("# Get stock")
    col1, col2 = st.columns([1, 2])

    # VNC
    with col2:
        vnc.vnc("https://ciclozero_vnc.butlerhat.com/")
        st.caption("VNC password: vscode")
    
    with col1:
        update_after: bool = False
        st.info("If 'yes' is selected, the stock will be updated after get stock")

        # Get Stock
        st.markdown("### Get stock and update stock")
        stock_path = st.secrets.paths.stock_excel

        with st.form("Run Robot with args"):
            # Select if after get stock, update stock
            select_update_after = st.selectbox("Update stock after get stock?", ["Yes", "No"])
            if select_update_after == "Yes":
                st.info("Select pages to update in the next section")
            # Add date to excel name
            excel_name = st.text_input("STOCK EXEL_NAME", f"CiclAiStock_{datetime.datetime.now().strftime('%H-%M_%d-%m-%Y')}.xlsx")
            csv_name = excel_name.replace(".xlsx", ".csv")
            excel_path = os.path.join(stock_path, excel_name)
            csv_path = os.path.join(stock_path, csv_name)
            
            if st.form_submit_button("Run", type="primary", on_click=disable, disabled=st.session_state.disabled):
                # Run robot
                args = [
                    f"RESULT_EXCEL_PATH:{excel_path}",
                    f"RESULT_CSV_PATH:{csv_path}"
                ]
                sum_ret_code = 0
                for i, id_stock in enumerate(STOCK_IDS, start=1):
                    ret_code = asyncio.run(robot_handler.run_robot(
                        id_stock, 
                        args, 
                        "CiclAiStock.robot", 
                        pabot=True, 
                        include_tags=[str(i)],
                        msg_info=f"Running {i}/4",
                        msg_fail=f"Failed {i}/4",
                        msg_success=f"Success {i}/4",

                    ))
                    sum_ret_code += int(ret_code) if ret_code is not None else 0

                if select_update_after == "Yes":
                    if sum_ret_code != 0:
                        st.error("Robot failed. So stock will not be updated")
                    else:
                        update_after = True
                        st.info("Stock will be updated...")  

        # Download excel
        if os.path.exists(os.path.join(stock_path, excel_name)):
            st.markdown(f'### Download <span style="color:{excel_name}">CiclAI</span>', unsafe_allow_html=True)
            with open(os.path.join(stock_path, excel_name), 'rb') as f:
                st.download_button(label=excel_name, data=f, file_name=excel_name, key='stock_excel', disabled=update_after)
        else:
            st.info(f"Excel not generated")
        
        # Download csv
        if os.path.exists(os.path.join(stock_path, csv_name)):
            st.markdown(f'### Download <span style="color:{csv_name}">CiclAI for LLM</span>', unsafe_allow_html=True)
            with open(os.path.join(stock_path, csv_name), 'rb') as f:
                st.download_button(label=csv_name, data=f, file_name=csv_name, key='stock_csv', disabled=update_after)
    
    for id_stock in STOCK_IDS:
        display_last_run_info(id_stock)

    # Update stock
    st.markdown("---")
    st.markdown("# Update stock")
    
    with st.form("Update stock"):
        update_pages = st.multiselect("Select pages to update", PAGES.keys(), PAGES.keys())

        file_path = None
        uploaded_file = st.file_uploader("Upload stock excel", type=["xlsx"])
        if uploaded_file is not None:
            file_path =  os.path.join(stock_path, uploaded_file.name)
            excel.file_to_excel(uploaded_file, file_path)
        
        if uploaded_file is None:
            option = get_last_excel()
            if option is None:
                st.info("No excel found")
            else:
                file_path = os.path.join(stock_path, option)

        if update_after:
            file_path = excel_path
            print(f"Updating stock with file {file_path.split(os.sep)[-1]}")
        
        if st.form_submit_button("Update stock", type="primary", on_click=disable, disabled=st.session_state.disabled) or update_after and file_path is not None:
            st.info(f"Updating stock with file {file_path.split(os.sep)[-1] if file_path is not None else 'None'}")
            
            ids_args = {}
            robot_files = []
            for page in update_pages:
                robot_files.append(PAGES[page])
                ids_args[page] = [
                    f"STOCK_EXCEL_PATH:{file_path}",
                    f"COOKIES_DIR:{st.secrets.paths.cookies_dir}",
                ]
            asyncio.run(robot_handler.run_robots(ids_args, robot_files, timeout=2))
    
    # Display last run time and message
    for page in update_pages:
        display_last_run_info(page)


def display_last_run_info(id_workflow: str):
    if "disabled" not in st.session_state:
        st.session_state.disabled = False
    
    robot_path = st.secrets.paths.robot
    result_path = os.path.join(robot_path, "results", id_workflow)
    if not os.path.exists(result_path):
        st.error(f"Workflow {id_workflow} not found")
        return

    # Get start time last run
    output_xml_path = os.path.join(result_path, "output.xml")
    if not os.path.exists(output_xml_path):
        st.error("No results file (output.xml) found")
        return
    
    start_time_status: tuple[str, str, RobotStatus] = robot_results.get_start_time(output_xml_path)
    main_color = st.secrets.theme.primaryColor
    run_time = f"<span style='color:{main_color}'>{start_time_status[0]}, duration {start_time_status[1]}</span>"
    if start_time_status[2] == RobotStatus.PASS:
        # If true, print a green success message with markdown
        status_msg = f"<span style='color:green'>Success</span>"
    elif start_time_status[2] == RobotStatus.SKIP:
        # If false, print a yellow skipped message with markdown
        status_msg = f"<span style='color:yellow'>Skipped</span>"
    elif start_time_status[2] == RobotStatus.FAIL:
        # If false, print a red error message with markdown
        status_msg = f"<span style='color:red'>Failed</span>"
    else:
        status_msg = f"<span style='color:orange'>In progress</span>"
        run_time = f"<span style='color:{main_color}'>(Wait for the end of the run)</span>"
    
    # duration = f"<span style='color:{main_color}'>{start_time_status[1]}</span>"
    st.markdown(f"### {status_msg}: Last {id_workflow} run {run_time}", unsafe_allow_html=True)

    # Get message last run
    msg_path = os.path.join(result_path, "return_msg.txt")
    if not os.path.exists(msg_path):
        st.info(f"Not message file (return_msg.txt)")
    else:
        with open(msg_path, 'r') as f:
            msg_ = f.read()
            with st.expander("Show message", expanded=False):
                if 'warn' or 'skipped' in msg_.lower():
                    st.code(msg_, language='text')
                elif 'success' in msg_.lower():
                    st.code(msg_, language='text')
                else:
                    st.error(msg_)

    col1, col2 = st.columns([3, 1])
    with col1:
        with st.expander("Show results", expanded=False):
            log_file_out = os.path.join(result_path, f'logfile_out_{id_workflow}.txt')
            if not os.path.exists(log_file_out):
                st.info(f"Not log file (logfile_out_{id_workflow}.txt)")
            else:
                with open(log_file_out, 'r') as f:
                    st.code(f.read(), language='text')

    with col2:
        # Download log.html and images in browser/ folder
        log_html_path = os.path.join(result_path, "log.html")
        
        if not os.path.exists(log_html_path):
            st.info(f"Not log file (log.html)")
        else:
            # Zip log.html and images
            with st.spinner("Zipping log.html and images..."):
                zip_path = os.path.join(result_path, "log.zip")
                # Don't display information in terminal
                os.system(f"cd {result_path} && zip -r log.zip log.html browser > /dev/null 2>&1")
                
                with open(zip_path, 'rb') as f:
                    st.download_button(label="Download log.zip", data=f, file_name="log.zip", disabled=st.session_state.disabled, key=f"download_zip_{id_workflow}")

