import os
import datetime
import argparse

def delete_old_files(directory, limit_days):
    current_date = datetime.datetime.now()

    # Walk through directory recursively
    for root, _, files in os.walk(directory):
        for file in files:
            # Check if the file matches the given format
            if file.startswith("CiclAiStock_") and file.endswith(".xlsx"):
                # Extract date from filename
                try:
                    _, time, date_with_extension = file.split("_")
                    date = date_with_extension.split(".")[0]
                    day, month, year = map(int, date.split("-"))
                    extracted_date = datetime.datetime(year, month, day)
                except Exception as e:
                    print(f"Error while extracting date from {file}: {e}")
                    continue

                # Check if the file's date is older than the limit days
                if (current_date - extracted_date).days > limit_days:
                    # Delete the file
                    os.remove(os.path.join(root, file))
                    print(f"Deleted {os.path.join(root, file)}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Delete old CiclAiStock files.")
    parser.add_argument("-d", "--directory", required=True, help="Directory to search for files.")
    parser.add_argument("-l", "--limit", type=int, required=True, help="Number of days as the limit.")
    args = parser.parse_args()

    try:
        delete_old_files(args.directory, args.limit)
        # directory = "/workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero/prod_downloads/stock"
        # limit = 3
        # delete_old_files(directory=directory, limit_days=limit)
    except Exception as e:
        print(e)

# Run: python jobs/delete_files.py -d /home/username/CiclAiStock -l 30