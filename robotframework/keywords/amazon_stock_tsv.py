import csv
import pandas as pd
# Import ordered dictionary
from collections import OrderedDict
from update_woocommerce import get_products_dataframe


def write_tsv_file_all_skus(output_path: str, products_file_path: str, sku_quantity: OrderedDict[str, int]) -> str:
    """
    Write the tsv file. Return warinig message if there are skus not found in the tsv file
    """
    # Defining the column headers
    headers = [
        "sku",
        "price",
        "minimum-seller-allowed-price",
        "maximum-seller-allowed-price",
        "quantity",
        "fulfillment-channel",
        "handling-time",
        "minimum_order_quantity_minimum"
    ]

    # Get all the skus
    skus = get_all_skus(products_file_path)

    # Writing the TSV file
    with open(output_path, 'w', newline='') as file:
        writer = csv.writer(file, delimiter='\t')
        writer.writerow(headers)
        for sku in skus:
            quantity = sku_quantity[sku] if sku in sku_quantity else 0
            writer.writerow([sku, "", "", "", quantity, "", "", ""])
            if sku in sku_quantity:
                # Remove from the dictionary
                sku_quantity.pop(sku)
    
    # Check if there are skus left
    if len(sku_quantity) > 0:
        skus_not_found = [sku for sku in sku_quantity.keys()]  # Convert to list
        return f"Warning: There are {len(sku_quantity)} skus not found in the woocommerce products file: {skus_not_found}"
    else:
        return ""


def get_all_skus(products_file_path: str) -> list[str]:
    """
    Get all the skus from the tsv file
    """
    # Read product file
    products_df: pd.DataFrame = get_products_dataframe(products_file_path)
    # Get all the skus
    return products_df['Sku'].values.tolist()


# Test the function
if __name__ == "__main__":
    products_path = "/workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero/robotframework/keywords/woocommerce_files/data_woocommerce_products.csv"
    # Test the function
    write_tsv_file_all_skus("test.tsv", products_path, OrderedDict({"iPXS-GD-64-C -R": 20, "iPXS-GD-64-B -R": 20}))