import os
import re
import argparse

def delete_result_screenshot(directory, screenshots_to_keep=50, filename_format="robotframework-browser-screenshot-{number}.png"):
    # Walk through directory recursively
    for root, _, files in os.walk(directory):
        # Sort files by number with format robotframework-browser-screenshot-{number}.png
        def is_valid_filename(filename: str):
            pattern = r"^" + filename_format.replace("{number}", r"(\d+)") + r"$"
            match = re.match(pattern, filename)
            return match is not None
        
        # Filter from files only the ones that match the given format
        files = list(filter(is_valid_filename, files))

        files.sort(key=lambda x: int(x.split("-")[-1].split(".")[0]))
        # Get the number of files to delete
        files_to_delete = len(files) - screenshots_to_keep
        # Delete the files
        for file in files[:files_to_delete]:
            os.remove(os.path.join(root, file))
            print(f"Deleted {os.path.join(root, file)}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Delete old CiclAiStock files.")
    parser.add_argument("-d", "--directory", required=True, help="Directory to search for files.")
    parser.add_argument("-l", "--limit", type=int, required=False, default=50, help="Number of days as the limit.")
    args = parser.parse_args()

    try:
        delete_result_screenshot(
            args.directory,
            args.limit,
            filename_format="robotframework-browser-screenshot-{number}.png"
        )
        delete_result_screenshot(
            args.directory, 
            args.limit, 
            filename_format="fail-screenshot-{number}.png"
        )
    except Exception as e:
        print(e)


# Run: python jobs/delete_files.py -d /home/username/CiclAiStock -l 30