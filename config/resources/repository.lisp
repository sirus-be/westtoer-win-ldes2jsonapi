(in-package :mu-cl-resources)

;;;;
;; NOTE
;; docker-compose stop; docker-compose rm; docker-compose up
;; after altering this file.


;;;;
;; Describe the prefixes which you'll use in the domain file here.
;; This is a short-form which allows you to write, for example,
;; (s-url "http://purl.org/dc/terms/title")
;; as (s-prefix "dct:title")

;; (add-prefix "dct" "http://purl.org/dc/terms/")


;;;;;
;; The following is the commented out version of those used in the
;; commented out domain.lisp.

;; (add-prefix "dcat" "http://www.w3.org/ns/dcat#")
;; (add-prefix "dct" "http://purl.org/dc/terms/")
;; (add-prefix "skos" "http://www.w3.org/2004/02/skos/core#")


;;;;;
;; You can use the muext: prefix when you're still searching for
;; the right predicates during development.  This should *not* be
;; used to publish any data under.  It's merely a prefix of which
;; the mu.semte.ch organisation indicates that it will not be used
;; by them and that it shouldn't be used for permanent URI

(add-prefix "adms" "http://www.w3.org/ns/adms#")
(add-prefix "concepts" "https://westtoer.be/id/concepts/")
(add-prefix "core" "http://www.w3.org/2004/02/skos/core#")
(add-prefix "generiek" "https://data.vlaanderen.be/ns/generiek#")
(add-prefix "ldes" "https://w3id.org/ldes#")
(add-prefix "locn" "http://www.w3.org/ns/locn#")
(add-prefix "logies" "https://data.vlaanderen.be/ns/logies#")
(add-prefix "macroproduct" "https://westtoer.be/id/macroproduct/")
(add-prefix "org" "http://www.w3.org/ns/org#")
(add-prefix "organisatie" "http://data.vlaanderen.be/id/organisatie/")
(add-prefix "product" "https://westtoer.be/id/product/")
(add-prefix "prov" "http://www.w3.org/ns/prov#")
(add-prefix "rdf" "http://www.w3.org/1999/02/22-rdf-syntax-ns#")
(add-prefix "rdfs" "http://www.w3.org/2000/01/rdf-schema#")
(add-prefix "terms" "http://purl.org/dc/terms/")
(add-prefix "toeristischeregio" "https://westtoer.be/id/toeristischeregio/")
(add-prefix "tree" "https://w3id.org/tree#")
(add-prefix "wgs84_pos" "http://www.w3.org/2003/01/geo/wgs84_pos#")
(add-prefix "schema" "https://schema.org/")
(add-prefix "xml" "http://www.w3.org/2001/XMLSchema#")
(add-prefix "westtoer" "https://westtoer.be/ns#")
(add-prefix "adres" "https://data.vlaanderen.be/ns/adres#")
(add-prefix "foaf" "http://xmlns.com/foaf/0.1/")
(add-prefix "datatourisme" "https://www.datatourisme.fr/ontology/core#")
