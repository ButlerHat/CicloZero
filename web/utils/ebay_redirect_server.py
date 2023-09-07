"""
Server with fastAPI to redirect to ebay

Install: pip install fastapi[all] uvicorn
"""
from fastapi import FastAPI, Request


app = FastAPI()

@app.get("/redirect")
async def retrieve_auth_code(request: Request):
    # Get the authorization code from the query parameters
    authorization_code = request.query_params.get("code")
    if authorization_code:
        print(f"Authorization Code: {authorization_code}")
        return {"Authorization Code": authorization_code}
    
    return {"Error": "Authorization code not found!"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)  # type: ignore

