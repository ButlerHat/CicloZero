# Launch in prod
Prod variables are in `secrets_prod.toml`. When deploy, delete or change name to original `secrets.toml` and set that name to production file.

Start streamlit with `--secrets secrets_prod.toml` is not enaught because the server uses also that `secrets.toml`

# Lauch redirect server
Appart of streamlit app, is necessary to launch `web/ebay_credentials/ebay_redirect_server.py` with `python` and the conda env `ebay_server_env` defined in `ebay_server.yaml`