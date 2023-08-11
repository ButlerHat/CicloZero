from datetime import datetime
from xml.etree import ElementTree


def get_start_time(output_xml_path: str) -> tuple[str, str, bool]:
    """
    Get start time from output.xml and the status
    """
    tree = ElementTree.parse(output_xml_path)
    root = tree.getroot()

    # Find the 'status' element with attribute 'status' set to 'PASS'
    status_element = root.find('.//suite/status')

    # Extract the starttime attribute value
    start_time_str = status_element.get('starttime') if status_element is not None else None

    # Exctract the endtime attribute value
    end_time_str = status_element.get('endtime') if status_element is not None else None
    
    # Extract status attribute value
    status = status_element.get('status') if status_element is not None else 'FAIL'
    status = True if status == 'PASS' else False

    if start_time_str is None or end_time_str is None:
        return ("Error getting start time", "", status)

    # Convert the start_time_str to a datetime object
    date_format = "%Y%m%d %H:%M:%S.%f"
    start_time_obj = datetime.strptime(start_time_str, date_format)
    end_time_obj = datetime.strptime(end_time_str, date_format)

    # Format the date part to the desired format
    formatted_date = start_time_obj.strftime("%d/%m/%Y %H:%M")

    # Get duration: end_time - start_time
    duration = end_time_obj - start_time_obj

    # Format the duration to the desired format
    formatted_duration = str(duration).split('.')[0]
    
    return (formatted_date, formatted_duration, status)

