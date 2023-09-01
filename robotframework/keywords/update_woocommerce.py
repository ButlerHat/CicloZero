"""
Update woocommerce CSV file with stock information from excel file
"""
from robot.libraries.BuiltIn import BuiltIn 
import pandas as pd
from count_excel import SELLERS


def get_products_dataframe(products_csv: str) -> pd.DataFrame:
    """
    Get the dataframe of skus from the csv file
    """
    # Read the CSV file
    woocommerce_df = pd.read_csv(products_csv)
    # Remove unnamed columns
    woocommerce_df = woocommerce_df.loc[:, ~woocommerce_df.columns.str.contains('^Unnamed')]
    # Remove rows where Parent ID is NaN
    woocommerce_df = woocommerce_df.dropna(subset=['Parent ID'])
    
    return woocommerce_df


def update_woocommerce_csv(products_csv, stock_excel, output_csv):
    woocommerce_df = get_products_dataframe(products_csv)

    # Update the stock and stock status columns
    woocommerce_df["Stock"] = 0
    woocommerce_df["Stock status"] = "outofstock"

    # Read excel
    stock_df = pd.read_excel(stock_excel)

    # Get the sellers to susbtract from the stock
    actual_sellers = [seller for seller in SELLERS if seller in stock_df.columns]
    for seller in actual_sellers:
        stock_df[seller] = stock_df[seller].fillna(0)
    
    stock_dict = {}
    # Extract SKU from 'prod' column and create a dictionary with handling NaN values
    for index, row in stock_df.iterrows():
        prod = row['prod']
        if "[" in prod:
            sku = prod[prod.find("[") + 1:prod.find("]")]
        else:
            sku = prod

        count = row['count']
        for seller in actual_sellers:
            if seller in stock_df.columns:
                count -= row[seller]
        stock_dict[sku] = count if count > 0 else 0
        
    not_found = []
    for sku, total in stock_dict.items():
        if sku not in woocommerce_df['Sku'].values:
            BuiltIn().log(f"SKU {sku} not found in woocommerce products")
            not_found.append(sku)
        woocommerce_df.loc[woocommerce_df['Sku'] == sku, 'Stock'] = total
        woocommerce_df.loc[woocommerce_df['Sku'] == sku, 'Stock status'] = 'instock' if total > 0 else 'outofstock'

    # Save the updated dataframe to a new CSV file
    woocommerce_df.to_csv(output_csv, index=False)

    return not_found

    
if __name__ == "__main__":
    import os
    curr_dir = os.path.dirname(os.path.realpath(__file__))
    products_csv = os.sep.join([curr_dir, "woocommerce_files", "data_woocommerce_products.csv"])
    stock_excel = os.sep.join([curr_dir, "woocommerce_files", "stock.xlsx"]) 
    output_csv = os.sep.join([curr_dir, "woocommerce_files", "data_woocommerce_products_updated.csv"])
    update_woocommerce_csv(products_csv, stock_excel, output_csv)
