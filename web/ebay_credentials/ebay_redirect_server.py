"""
Server with fastAPI to redirect to ebay

Install: pip install fastapi[all] uvicorn
"""
import os
import yaml
import toml
import requests
import base64
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse


# Create credentials file to store credentials when initializing the server
EBAY_CLIENT_ID = os.environ.get("EBAY_CLIENT_ID")
EBAY_CLIENT_SECRET = os.environ.get("EBAY_CLIENT_SECRET")
EBAY_REDIRECT_URI = os.environ.get("EBAY_REDIRECT_URI")
assert EBAY_CLIENT_ID, "EBAY_CLIENT_ID not found!"
assert EBAY_CLIENT_SECRET, "EBAY_CLIENT_SECRET not found!"
assert EBAY_REDIRECT_URI, "EBAY_REDIRECT_URI not found!"

credentials = {
    "keyset": {
        "client_id": EBAY_CLIENT_ID,
        "client_secret": EBAY_CLIENT_SECRET,
        "ru_name": EBAY_REDIRECT_URI,
    }
}

# Store in yaml file. Read .streamlit/secrents.toml
curr_dir = os.path.dirname(os.path.abspath(__file__))
st_secret_path = os.path.join(curr_dir, "..", ".streamlit", "secrets.toml")
data = toml.load(st_secret_path)
CREDENTIALS_FILE_PATH = data["paths"]["ebay_credentials"]
assert os.path.exists(os.path.dirname(CREDENTIALS_FILE_PATH)), "ebay_credentials folder not found!"

with open(CREDENTIALS_FILE_PATH, "w") as f:
    yaml.dump(credentials, f)


def get_access_token(authorization_code: str) -> tuple[bool, str]:
    with open(CREDENTIALS_FILE_PATH, "r") as f:
        credentials = yaml.safe_load(f)
    
    client_id = credentials["keyset"]["client_id"]
    client_secret = credentials["keyset"]["client_secret"]
    barear_token = f"{client_id}:{client_secret}"
    encoded_barear_token = base64.b64encode(barear_token.encode("utf-8")).decode("utf-8")

    headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': f'Basic {encoded_barear_token}'
    }
    
    redirect_uri = credentials["keyset"]["ru_name"]
    body = {
        'grant_type': 'authorization_code',
        'code': authorization_code, 
        'redirect_uri': redirect_uri
    }

    response = requests.post('https://api.sandbox.ebay.com/identity/v1/oauth2/token', headers=headers, data=body)
    if response.status_code == 200:
        response_json = response.json()
        credentials['current'] = {}
        credentials['current']["access_token"] = response_json["access_token"]
        credentials['current']["expires_in"] = response_json["expires_in"]
        credentials['current']["refresh_token"] = response_json["refresh_token"]
        credentials['current']["refresh_token_expires_in"] = response_json["refresh_token_expires_in"]
        with open(CREDENTIALS_FILE_PATH, "w") as f:
            yaml.dump(credentials, f)
        return True, ""
    
    return False, response.content.decode("utf-8")


def render_error(msg: str) -> str:
    curr_dir = os.path.dirname(os.path.abspath(__file__))
    error_html_path = os.path.join(curr_dir, "error.html")
    with open(error_html_path, "r") as f:
        error_html = f.read()
    
    error_html = error_html.replace("[ERROR_PLACEHOLDER]", msg)
    return error_html


# ===== SERVER =====

app = FastAPI()

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/redirect")
async def retrieve_auth_code(request: Request):
    # Get the authorization code from the query parameters
    authorization_code = request.query_params.get("code")
    if authorization_code:
        print(f"Authorization Code: {authorization_code}")

        # Read credentials file in a dict
        with open(CREDENTIALS_FILE_PATH, "r") as f:
            credentials = yaml.safe_load(f)
        
        # Add authorization code to credentials
        credentials["authorization_code"] = authorization_code

        # Store in yaml file
        with open(CREDENTIALS_FILE_PATH, "w") as f:
            yaml.dump(credentials, f)

        # Get access token
        is_vaild, msg = get_access_token(authorization_code)
        if not is_vaild:
            msg = f"Error getting access token: {msg}"
            print(msg)
            error_html = render_error(msg)
            return HTMLResponse(content=error_html, status_code=200)

        # Return authorization code and access token
        with open(CREDENTIALS_FILE_PATH, "r") as f:
            credentials = yaml.safe_load(f)

        # Return ./success.html 
        curr_dir = os.path.dirname(os.path.abspath(__file__))
        success_html_path = os.path.join(curr_dir, "success.html")
        with open(success_html_path, "r") as f:
            success_html = f.read()
        return HTMLResponse(content=success_html, status_code=200)
    
    # Return ./error.html
    error_html = render_error("Something went wrong. Authorization code not found!")
    
    return HTMLResponse(content=error_html, status_code=200)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)  # type: ignore

