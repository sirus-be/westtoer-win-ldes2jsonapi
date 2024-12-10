(in-package :mu-cl-resources)
(setf *allow-xsd-in-uuids* t)

;;
;; NOTE
;; docker-compose stop; docker-compose rm; docker-compose up
;; after altering this file.

;; Describe your resources here

;; The general structure could be described like this:
;;
;; (define-resource <name-used-in-this-file> ()
;;   :class <class-of-resource-in-triplestore>
;;   :properties `((<json-property-name-one> <type-one> ,<triplestore-relation-one>)
;;                 (<json-property-name-two> <type-two> ,<triplestore-relation-two>>))
;;   :has-many `((<name-of-an-object> :via ,<triplestore-relation-to-objects>
;;                                    :as "<json-relation-property>")
;;               (<name-of-an-object> :via ,<triplestore-relation-from-objects>
;;                                    :inverse t ; follow relation in other direction
;;                                    :as "<json-relation-property>"))
;;   :has-one `((<name-of-an-object :via ,<triplestore-relation-to-object>
;;                                  :as "<json-relation-property>")
;;              (<name-of-an-object :via ,<triplestore-relation-from-object>
;;                                  :as "<json-relation-property>"))
;;   :resource-base (s-url "<string-to-which-uuid-will-be-appended-for-uri-of-new-items-in-triplestore>")
;;   :on-path "<url-path-on-which-this-resource-is-available>")


;; correct
(define-resource tourist-attraction ()
  :class (s-prefix "schema:TouristAttraction")
  :properties `((:naam :language-string-set ,(s-prefix "schema:name"))
                (:omschrijving :language-string-set ,(s-prefix "schema:description"))
                (:generated-at-time :datetime ,(s-prefix "prov:generatedAtTime"))
                (:lokale-identificator :rdfs-string ,(s-prefix "generiek:lokaleIdentificator"))
                (:naamruimte :rdfs-string ,(s-prefix "generiek:naamruimte"))
                (:versie-identificator :string ,(s-prefix "generiek:versieIdentificator"))
                (:personen :integer ,(s-prefix "logies:aantalSlaapplaatsen"))
                (:aantal-eenheden :integer ,(s-prefix "logies:aantalVerhuureenheden"))
                (:toeristisch-relevant :boolean ,(s-prefix "westtoer:isRelevantVoorWesttoer"))
                (:tijdelijk-gesloten :boolean ,(s-prefix "westtoer:tijdelijkGesloten"))
                (:uitsluiten-van-jaarlijkse-bevraging :boolean ,(s-prefix "westtoer:uitsluitenVanJaarlijkseBevraging"))
                (:uitsluiten-van-publicatie :boolean ,(s-prefix "westtoer:uitsluitenVanPublicatie")))
  :has-one `(
            (identificator :via ,(s-prefix "adms:identifier")
                           :as "identificator")
             (address :via ,(s-prefix "locn:address")
                      :as "adres")
             (geometry :via ,(s-prefix "locn:geometry")
                       :as "geometrie")
             (contact-point :via ,(s-prefix "schema:contactPoint")
                            :as "contactpunt")
             (tourist-region :via ,(s-prefix "logies:behoortTotToeristischeRegio")
                             :as "tourismeRegio")
             (star-rating :via ,(s-prefix "schema:starRating")
                          :as "beoordeling")
            ;;  (product-status :via ,(s-prefix "westtoer:Product.status")
            ;;                  :as "productStatus")
             (amount :via ,(s-prefix "schema:amount")
                     :as "prijs"))
  :has-many `((media :via ,(s-prefix "logies:heeftMedia")
                     :as "media")
              (amenity-feature :via ,(s-prefix "schema:amenityFeature")
                                :as "faciliteiten"))
  :resource-base (s-url "https://westtoer.be/id/product/")
  :on-path "attracties")

  (define-resource geometry ()
  :class (s-prefix "generiek:Geometrie")
  :properties `((:latitude :xsd-secure-double ,(s-prefix "wgs84_pos:lat"))
                (:longitude :xsd-secure-double ,(s-prefix "wgs84_pos:long")))
  :resource-base (s-url "https://westtoer.be/id/geometry/")
  :on-path "geometries")

;; need to fix
  (define-resource identificator ()
  :class (s-prefix "adms:Identifier")
  :properties `((:aangemaakt-door :rdf-resource ,(s-prefix "terms:creator"))
                (:win-id :string ,(s-prefix  "westtoer:identifier"))
                (:schema-agentschap :string ,(s-prefix  "adms:schemaAgency")))
  :resource-base (s-url "https://westtoer.be/id/identificator/")
  :on-path "identificatoren")
  
  (define-resource address ()
  :class (s-prefix "locn:Address")
  :properties `((:provincie :language-string-set ,(s-prefix "locn:adminUnitL2"))
                (:post-code :string ,(s-prefix "locn:postCode"))
                (:straat :language-string ,(s-prefix "locn:thoroughfare"))
                (:huisnummer :string ,(s-prefix "adres:Adresvoorstelling.huisnummer"))
                (:gemeente :language-string ,(s-prefix "adres:gemeentenaam"))
                (:land :language-string ,(s-prefix "adres:land"))
                (:adres-regel-1 :string ,(s-prefix "westtoer:adresregel1"))
                (:nis-code :integer ,(s-prefix "westtoer:gemeenteniscode")))
  ;; :has-one `((assigned-by-municipality :via ,(s-prefix "westtoer:isToegekendDoorGemeente")
  ;;                                      :as "assignedByMunicipality")
  ;;             (assigned-by-submunicipality :via ,(s-prefix "westtoer:isToegekendDoorDeelgemeente")
  ;;                                      :as "assignedBySubmunicipality")
  ;;            (assigned-by-province :via ,(s-prefix "westtoer:isToegekendDoorProvincie")
  ;;                                  :as "assignedByProvince"))

  :resource-base (s-url "https://westtoer.be/id/address/")
  :on-path "adressen")

  (define-resource geometry ()
  :class (s-prefix "generiek:Geometrie")
  :properties `((:latitude :xsd-secure-double ,(s-prefix "wgs84_pos:lat"))
                (:longitude :xsd-secure-double ,(s-prefix "wgs84_pos:long")))
  :resource-base (s-url "https://westtoer.be/id/geometry/")
  :on-path "geometries")

  (define-resource contact-point ()
  :class (s-prefix "schema:ContactPoint")
  :properties `((:website :uri ,(s-prefix "foaf:page"))
                (:type :string ,(s-prefix "schema:contactType"))
                (:fax :string ,(s-prefix "schema:faxNumber"))
                (:email :string ,(s-prefix "schema:email"))
                (:telefoonnummer :string ,(s-prefix "schema:telephone")))
  :resource-base (s-url "https://westtoer.be/id/contact-point/")
  :on-path "contactpunten")

  (define-resource tourist-region ()
  :class (s-prefix "logies:ToeristischeRegio")
  :properties `((:pref-label :language-string-set ,(s-prefix "core:prefLabel"))
                (:version-of :url ,(s-prefix "terms:isVersionOf")))
  :resource-base (s-url "https://westtoer.be/id/tourist-region/")
  :on-path "tourisme-regios")

  (define-resource star-rating ()
  :class (s-prefix "schema:Rating")
  :properties `((:type :url ,(s-prefix "terms:type"))
                (:auteur :url ,(s-prefix "schema:author"))
                (:omschrijving :language-string-set ,(s-prefix "schema:description"))
                (:beste-score :string ,(s-prefix "schema:bestRating"))
                (:slechtste-score :string ,(s-prefix "schema:worstRating"))
                (:beoordeling-score :string ,(s-prefix "schema:ratingValue")))
  :resource-base (s-url "https://westtoer.be/id/star-rating/")
  :on-path "beoordelingen")

  (define-resource amount ()
  :class (s-prefix "schema:MonetaryAmount")
  :properties `((:prijs :number ,(s-prefix "schema:value"))
                (:eenheid :string ,(s-prefix "schema:currency")))
  :resource-base (s-url "https://westtoer.be/id/amount/")
  :on-path "prijzen")

  (define-resource media ()
  :class (s-prefix "logies:MediaObject")
  :properties `((:lokale-identificator :rdfs-string ,(s-prefix "generiek:lokaleIdentificator"))
                (:naamruimte :rdfs-string ,(s-prefix "generiek:naamruimte"))
                (:afbeelding :url ,(s-prefix "schema:contentUrl"))
                (:publicatie-datum :datetime ,(s-prefix "schema:datePublished"))
                (:omschrijving :language-string-set ,(s-prefix "schema:description"))
                (:is-spotlight :boolean ,(s-prefix "westtoer:isSpotlight"))
                (:sort-order :rdfs-integer ,(s-prefix "westtoer:sortOrder")))
  :resource-base (s-url "https://westtoer.be/id/media/")
  :on-path "media")

  (define-resource amenity-feature ()
  :class (s-prefix "logies:Faciliteit")
  :properties `((:specialisatie-van :url ,(s-prefix "logies:isSpecialisatieVan"))
                (:naam :language-string-set ,(s-prefix "schema:name")))
  :resource-base (s-url "https://westtoer.be/id/amenity-feature/")
  :on-path "faciliteiten")


;; unable to implemented
;;   (define-resource product-status ()
;;   :properties `((:version-of :url ,(s-prefix "terms:isVersionOf")))
;;   :resource-base (s-url "https://westtoer.be/id/product-status/")
;;   :on-path "product-statuses")

;;   (define-resource assigned-by-submunicipality ()
;;   :properties `((:version-of :url ,(s-prefix "terms:isVersionOf"))
;;                 (:pref-label :language-string-set ,(s-prefix "core:prefLabel")))
;;   :resource-base (s-url "https://westtoer.be/id/assigned-by-submunicipality/")
;;   :on-path "assigned-by-submunicipalities")

;; (define-resource assigned-by-municipality ()
;;   :properties `((:version-of :url ,(s-prefix "terms:isVersionOf"))
;;                 (:pref-label :language-string-set ,(s-prefix "core:prefLabel")))
;;   :resource-base (s-url "https://westtoer.be/id/assigned-by-municipality/")
;;   :on-path "assigned-by-municipalities")

;; (define-resource assigned-by-province ()
;;   :properties `((:version-of :url ,(s-prefix "terms:isVersionOf"))
;;                 (:pref-label :language-string-set ,(s-prefix "core:prefLabel")))
;;   :resource-base (s-url "https://westtoer.be/id/assigned-by-province/")
;;   :on-path "assigned-by-provinces")