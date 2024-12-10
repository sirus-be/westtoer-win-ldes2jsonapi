import logging
from SPARQLWrapper import SPARQLWrapper, JSON
import requests
import uuid
import os
import schedule
import time

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class UUIDHelper:
    def __init__(self, sparql_endpoint=None):
        self.sparql_endpoint = sparql_endpoint or os.getenv("SPARQL_ENDPOINT", "http://database:8890/sparql")
        self.graph_uri = "http://mu.semte.ch/application"

    def fetch_objects_without_uuid(self, object_type):
        sparql = SPARQLWrapper(self.sparql_endpoint)
        query = f"""
        PREFIX schema: <https://schema.org/>
        PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
        PREFIX locn: <http://www.w3.org/ns/locn#>
        PREFIX logies: <https://data.vlaanderen.be/ns/logies#>
        PREFIX prov: <http://www.w3.org/ns/prov#>
        PREFIX generiek: <https://data.vlaanderen.be/ns/generiek#>
        PREFIX terms: <http://purl.org/dc/terms/>

        SELECT ?object
        WHERE {{
          ?object a {object_type} .
          FILTER NOT EXISTS {{ ?object mu:uuid ?uuid }}
        }}
        """
        sparql.setQuery(query)
        sparql.setReturnFormat(JSON)
        try:
            results = sparql.query().convert()
            return [result["object"]["value"] for result in results["results"]["bindings"]]
        except Exception as e:
            logging.error(f"Error fetching objects without UUID for {object_type}: {e}")
            return []

    def generate_uuid(self):
        return str(uuid.uuid1())

    def insert_uuid_for_uri(self, uri):
        headers = {'Content-Type': 'application/sparql-update'}
        uuid_value = self.generate_uuid()
        query = f"""
        PREFIX schema: <https://schema.org/>
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
        PREFIX terms: <http://purl.org/dc/terms/>

        INSERT DATA {{
            GRAPH <{self.graph_uri}> {{
                <{uri}> mu:uuid "{uuid_value}" .
            }}
        }}
        """
        try:
            response = requests.post(self.sparql_endpoint, data=query, headers=headers)
            response.raise_for_status()
        except requests.exceptions.RequestException as e:
            logging.error(f"Failed to insert UUID for {uri}: {e}")

    def insert_uuids_for_uris(self, uris):
        for uri in uris:
            self.insert_uuid_for_uri(uri)

    def process_objects(self):
        objects = [
            "schema:TouristAttraction",
            "locn:Address",
            "generiek:Geometrie",
            "schema:ContactPoint",
            "schema:Rating",
            "schema:MonetaryAmount",
            "logies:ToeristischeRegio",
            "logies:MediaObject",
            "logies:Faciliteit",
        ]

        for object_type in objects:
            logging.info(f"Processing {object_type}")
            uris = self.fetch_objects_without_uuid(object_type)
            logging.info(f"Found {len(uris)} objects without UUID")
            self.insert_uuids_for_uris(uris)

    def start_scheduler(self):
        schedule.every(1).minute.do(self.safe_process_objects)

        while True:
            schedule.run_pending()
            time.sleep(1)

    def safe_process_objects(self):
        try:
            self.process_objects()
        except Exception as e:
            logging.error(f"Error processing objects: {e}")