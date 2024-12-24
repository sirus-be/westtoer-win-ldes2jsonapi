from flask import Flask, request, jsonify
import requests
import os
import logging
import threading
from uuid_helper import UUIDHelper

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Define the target API endpoint from environment variable
# Define the target API endpoint from environment variable
TARGET_API_URL = os.getenv("TARGET_API_URL", "http://resource")  # Default to "http://resource" if not set
SPARQL_API_URL = os.getenv("SPARQL_API_URL", "http://database:8890")  # Default to "http://database:8890" if not set
logger.info(f"Target API URL is set to {TARGET_API_URL}")
logger.info(f"SPARQL API URL is set to {SPARQL_API_URL}")
@app.route('/')
def default_route():
    """
    Default route to indicate the proxy is running.
    """
    logger.info("Default route accessed")
    return jsonify({"message": "Proxy is running"}), 200

@app.route('/<path:path>', methods=['GET'])
def proxy_get_request(path):
    """
    Pipe all GET requests to the target API endpoint.
    """
    # Construct the full URL to the target API
    normalized_path = path.rstrip('/')

    logger.info(f"Received GET request for path {path}")
    logger.info(f"Normalized path is {normalized_path}")
    
    if normalized_path == "sparql":
        target_url = f"{SPARQL_API_URL}/{path}"
    else:
        target_url = f"{TARGET_API_URL}/{path}"

    # Forward the query parameters
    params = request.args

    # Log the full URL with parameters
    full_url = requests.Request('GET', target_url, params=params).prepare().url
    logger.info(f"Proxying GET request to {full_url}")

    try:
        # Make the GET request to the target API
        response = requests.get(target_url, params=params)
        logger.info(f"Received response with status code {response.status_code}")

        if normalized_path == "sparql":
            return response.content, response.status_code
        
        return jsonify(response.json()), response.status_code
    except requests.RequestException as e:
        logger.error(f"Error occurred: {e}")
        return jsonify({"error": str(e)}), 500

@app.before_request
def block_disallowed_methods():
    """
    Block all HTTP methods except GET.
    """
    if request.method != 'GET':
        logger.warning(f"Blocked {request.method} request to {request.path}")
        return jsonify({"error": "Method Not Allowed"}), 405

def start_uuid_helper():
    uuid_helper = UUIDHelper()
    uuid_helper.start_scheduler()

if __name__ == '__main__':
    logger.info("Starting proxy server...")

    # Start the UUIDHelper in a separate thread
    # uuid_helper_thread = threading.Thread(target=start_uuid_helper)
    # uuid_helper_thread.daemon = True
    # uuid_helper_thread.start()

    app.run(host='0.0.0.0', port=80, debug=True)