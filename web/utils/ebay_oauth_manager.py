"""
Ebay credentials manager.
"""
import base64
import yaml
import requests
import streamlit as st


SCOPES = [
        "https://api.ebay.com/oauth/api_scope",
        "https://api.ebay.com/oauth/api_scope/buy.order.readonly",
        "https://api.ebay.com/oauth/api_scope/buy.guest.order",
        "https://api.ebay.com/oauth/api_scope/sell.marketing.readonly",
        "https://api.ebay.com/oauth/api_scope/sell.marketing",
        "https://api.ebay.com/oauth/api_scope/sell.inventory.readonly",
        "https://api.ebay.com/oauth/api_scope/sell.inventory",
        "https://api.ebay.com/oauth/api_scope/sell.account.readonly",
        "https://api.ebay.com/oauth/api_scope/sell.account",
        "https://api.ebay.com/oauth/api_scope/sell.fulfillment.readonly",
        "https://api.ebay.com/oauth/api_scope/sell.fulfillment",
        "https://api.ebay.com/oauth/api_scope/sell.analytics.readonly",
        "https://api.ebay.com/oauth/api_scope/sell.marketplace.insights.readonly",
        "https://api.ebay.com/oauth/api_scope/commerce.catalog.readonly",
        "https://api.ebay.com/oauth/api_scope/buy.shopping.cart",
        "https://api.ebay.com/oauth/api_scope/buy.offer.auction",
        "https://api.ebay.com/oauth/api_scope/commerce.identity.readonly",
        "https://api.ebay.com/oauth/api_scope/commerce.identity.email.readonly",
        "https://api.ebay.com/oauth/api_scope/commerce.identity.phone.readonly",
        "https://api.ebay.com/oauth/api_scope/commerce.identity.address.readonly",
        "https://api.ebay.com/oauth/api_scope/commerce.identity.name.readonly",
        "https://api.ebay.com/oauth/api_scope/commerce.identity.status.readonly",
        "https://api.ebay.com/oauth/api_scope/sell.finances",
        "https://api.ebay.com/oauth/api_scope/sell.item.draft",
        "https://api.ebay.com/oauth/api_scope/sell.payment.dispute",
        "https://api.ebay.com/oauth/api_scope/sell.item",
        "https://api.ebay.com/oauth/api_scope/sell.reputation",
        "https://api.ebay.com/oauth/api_scope/sell.reputation.readonly",
        "https://api.ebay.com/oauth/api_scope/commerce.notification.subscription",
        "https://api.ebay.com/oauth/api_scope/commerce.notification.subscription.readonly"
    ]  # a URL-encoded string of space-separated scopes

# Prod scopes scope=https://api.ebay.com/oauth/api_scope https://api.ebay.com/oauth/api_scope/sell.marketing.readonly https://api.ebay.com/oauth/api_scope/sell.marketing https://api.ebay.com/oauth/api_scope/sell.inventory.readonly https://api.ebay.com/oauth/api_scope/sell.inventory https://api.ebay.com/oauth/api_scope/sell.account.readonly https://api.ebay.com/oauth/api_scope/sell.account https://api.ebay.com/oauth/api_scope/sell.fulfillment.readonly https://api.ebay.com/oauth/api_scope/sell.fulfillment https://api.ebay.com/oauth/api_scope/sell.analytics.readonly https://api.ebay.com/oauth/api_scope/sell.finances https://api.ebay.com/oauth/api_scope/sell.payment.dispute https://api.ebay.com/oauth/api_scope/commerce.identity.readonly https://api.ebay.com/oauth/api_scope/commerce.notification.subscription https://api.ebay.com/oauth/api_scope/commerce.notification.subscription.readonly
PROD_SCOPES = [
    "https://api.ebay.com/oauth/api_scope",
    "https://api.ebay.com/oauth/api_scope/sell.marketing.readonly",
    "https://api.ebay.com/oauth/api_scope/sell.marketing",
    "https://api.ebay.com/oauth/api_scope/sell.inventory.readonly",
    "https://api.ebay.com/oauth/api_scope/sell.inventory",
    "https://api.ebay.com/oauth/api_scope/sell.account.readonly",
    "https://api.ebay.com/oauth/api_scope/sell.account",
    "https://api.ebay.com/oauth/api_scope/sell.fulfillment.readonly",
    "https://api.ebay.com/oauth/api_scope/sell.fulfillment",
    "https://api.ebay.com/oauth/api_scope/sell.analytics.readonly",
    "https://api.ebay.com/oauth/api_scope/sell.finances",
    "https://api.ebay.com/oauth/api_scope/sell.payment.dispute",
    "https://api.ebay.com/oauth/api_scope/commerce.identity.readonly",
    "https://api.ebay.com/oauth/api_scope/commerce.notification.subscription",
    "https://api.ebay.com/oauth/api_scope/commerce.notification.subscription.readonly"
]



def get_authorization_url():
    """
    Get authorization code from ebay.
    """
    credentials_path = st.secrets.paths.ebay_credentials
    with open(credentials_path, "r") as f:
        credentials = yaml.safe_load(f)

    url = st.secrets.ebay.url_authorization_token
    client_id = credentials["keyset"]["client_id"]
    redirect_uri = credentials["keyset"]["ru_name"]
    return f"{url}?client_id={client_id}&redirect_uri={redirect_uri}&response_type=code&scope={'%20'.join(PROD_SCOPES)}"


def get_user(access_token: str):
    headers = {
        'Authorization': f'Bearer {access_token}'
    }
    url = st.secrets.ebay.url_identity_user
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()["username"]
    return ""



def check_auth_ebay() -> tuple[bool, str]:
    """
    Check if the current access token is valid. If not, refresh it. If after refreshing is still invalid, return False.
    """
    credential_path = st.secrets.paths.ebay_credentials
    with open(credential_path, "r") as f:
        credentials = yaml.safe_load(f)

    if "current" not in credentials:
        return False, ""
    
    # Current token
    access_token = credentials["current"]["access_token"]
    refresh_token = credentials["current"]["refresh_token"]

    headers = {
        'Authorization': f'Bearer {access_token}'
    }

    username = get_user(access_token)
    if username:
        return True, username
    
    # Refresh token
    client_id = credentials["keyset"]["client_id"]
    client_secret = credentials["keyset"]["client_secret"]
    barear_token = f"{client_id}:{client_secret}"
    encoded_barear_token = base64.b64encode(barear_token.encode("utf-8")).decode("utf-8")

    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': f'Basic {encoded_barear_token}'
    }

    body = {
        "grant_type": 'refresh_token',
        "refresh_token": refresh_token,
        "scope": ' '.join(SCOPES)
    }

    url = st.secrets.ebay.url_access_token
    response = requests.post(url, headers=headers, data=body)
    if response.status_code == 200:
        response_json = response.json()

        username = get_user(response_json["access_token"])
        if not username:
            return False, ""

        credentials['current']["access_token"] = response_json["access_token"]
        credentials['current']["expires_in"] = response_json["expires_in"]
        
        with open(credential_path, "w") as f:
            yaml.dump(credentials, f)
        return True, username
    
    # Invalid curren tokena and refresh token
    return False, ""
    

        
