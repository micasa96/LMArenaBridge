import json
import os

path = 'config.json'
defaults_to_apply = {
    'camoufox_proxy_headless': True,
    'camoufox_fetch_headless': True,
}

if not os.path.exists(path):
    cfg = {
        'admin_password': 'changeme',
        'api_keys': [],
        'arena_tokens': [],
        'rate_limit': 60,
        'debug': False,
    }
else:
    try:
        with open(path, 'r') as f:
            cfg = json.load(f)
    except Exception:
        cfg = {}

cfg.update(defaults_to_apply)

with open(path, 'w') as f:
    json.dump(cfg, f, indent=2)

print("config.json updated with headless=True")