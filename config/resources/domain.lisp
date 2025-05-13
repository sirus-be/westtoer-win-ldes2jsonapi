(in-package :mu-cl-resources)
(setf *allow-xsd-in-uuids* t)

;; Internal caching
(setf *cache-model-properties* t)
(setf *cache-count-queries* t)
(setf *cache-model-properties-p* t)

;; External Caching//use when combined with mu-cache
;;(setf *supply-cache-headers-p* t)


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


(define-resource tourist-attraction ()
  :class (s-prefix "schema:TouristAttraction")
  :properties `((:naam :language-string-set ,(s-prefix "schema:name"))
                (:omschrijving :language-string-set ,(s-prefix "schema:description"))
                (:generated-at-time :datetime ,(s-prefix "prov:generatedAtTime"))
                (:verwerkt-voor-afnemers :datetime ,(s-prefix "westtoer:verwerktVoorAfnemers"))
                (:lokale-identificator :rdfs-string ,(s-prefix "generiek:lokaleIdentificator"))
                (:naamruimte :rdfs-string ,(s-prefix "generiek:naamruimte"))
                (:versie-identificator :string ,(s-prefix "generiek:versieIdentificator"))
                (:status :rdf-resource ,(s-prefix "westtoer:Product.status"))
                (:personen :integer ,(s-prefix "logies:aantalSlaapplaatsen"))
                (:aantal-eenheden :integer ,(s-prefix "logies:aantalVerhuureenheden"))
                (:toeristisch-relevant :boolean ,(s-prefix "westtoer:isRelevantVoorWesttoer"))
                (:tijdelijk-gesloten :boolean ,(s-prefix "westtoer:tijdelijkGesloten"))
                (:uitsluiten-van-jaarlijkse-bevraging :boolean ,(s-prefix "westtoer:uitsluitenVanJaarlijkseBevraging"))
                (:uitsluiten-van-publicatie :boolean ,(s-prefix "westtoer:uitsluitenVanPublicatie"))
                (:stopgezet :boolean ,(s-prefix "westtoer:isStopgezet"))
                (:overgenomen :boolean ,(s-prefix "westtoer:isOvergenomen"))
                (:gratis-toegankelijk :boolean ,(s-prefix "schema:isAccessibleForFree"))
                (:actief1juli :boolean ,(s-prefix "westtoer:actief1juli"))
                (:vorige-validatiedatum :datetime ,(s-prefix "westtoer:vorigeValidatiedatum"))
                (:100-procent-west-vlaams :boolean, (s-prefix "westtoer:is100ProcentWestVlaams")))
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
             (registration :via ,(s-prefix "logies:heeftRegistratie")
                           :as "registratie")
             (amount :via ,(s-prefix "schema:amount")
                     :as "prijs")
             (capacity :via ,(s-prefix "logies:capaciteit")
                      :as "capaciteit")
             (preferred-label :via ,(s-prefix "westtoer:Product.status")
                               :as "productstatus")
             (preferred-label :via ,(s-prefix "schema:additionalType")
                          :as "extratype")      
             (preferred-label :via ,(s-prefix "westtoer:behoortTotMacroproduct")
                          :as "behoort-tot-macroproduct"))

  :has-many `((media :via ,(s-prefix "logies:heeftMedia")
                     :as "media")
              (kwaliteitslabel :via ,(s-prefix "logies:heeftKwaliteitsLabel")
                                :as "kwaliteitslabels")
              (amenity-feature :via ,(s-prefix "schema:amenityFeature")
                                :as "faciliteiten")
             (star-rating :via ,(s-prefix "schema:starRating")
                          :as "beoordelingen")
              (preferred-label :via ,(s-prefix "westtoer:heeftKenmerk")
                          :as "kenmerken")
              (multipurpose-room :via ,(s-prefix "westtoer:heeftRuimte")
                                :as "ruimtes")
              (see-also :via ,(s-prefix "rdfs:seeAlso")
                      :as "zie-ook"))
  :resource-base (s-url "https://data.westtoer.be/id/product/")
  :on-path "attracties")


(define-resource identificator ()
  :class (s-prefix "adms:Identifier")
  :properties `((:aangemaakt-door :rdf-resource ,(s-prefix "terms:creator"))
                (:win-id :string ,(s-prefix  "westtoer:identifier"))
                (:schema-agentschap :string ,(s-prefix  "adms:schemaAgency")))
  :resource-base (s-url "https://data.westtoer.be/id/identificator/")
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
                  (:nis-code :integer ,(s-prefix "westtoer:gemeenteniscode"))
                  (:toegekend-door-gemeente-uri :rdf-resource ,(s-prefix "westtoer:isToegekendDoorGemeente"))
                  (:toegekend-door-deelgemeente-uri :rdf-resource ,(s-prefix "westtoer:isToegekendDoorDeelgemeente"))
                  (:toegekend-door-provincie-uri :rdf-resource ,(s-prefix "westtoer:isToegekendDoorProvincie"))
                  )
    :has-one `((preferred-label :via ,(s-prefix "westtoer:isToegekendDoorGemeente")
                                          :as "toegekend-door-gemeente")
                (preferred-label  :via ,(s-prefix "westtoer:isToegekendDoorDeelgemeente")
                                          :as "toegekend-door-deelgemeente")
                (preferred-label  :via ,(s-prefix "westtoer:isToegekendDoorProvincie")
                                      :as "toegekend-door-provincie"))

    :resource-base (s-url "https://data.westtoer.be/id/address/")
    :on-path "adressen")


(define-resource geometry ()
  :class (s-prefix "generiek:Geometrie")
  :properties `((:latitude :xsd-secure-double ,(s-prefix "wgs84_pos:lat"))
                (:longitude :xsd-secure-double ,(s-prefix "wgs84_pos:long")))
  :resource-base (s-url "https://data.westtoer.be/id/geometry/")
  :on-path "geometries")


(define-resource tourist-region ()
  :class (s-prefix "core:Concept")
  :properties `((:pref-label :language-string-set ,(s-prefix "core:prefLabel"))
                (:version-of :url ,(s-prefix "terms:isVersionOf")))
                
  :resource-base (s-url "https://data.westtoer.be/id/tourist-region/")
  :on-path "tourisme-regios")


(define-resource contact-point ()
  :class (s-prefix "schema:ContactPoint")
  :properties `((:website :uri ,(s-prefix "foaf:page"))
                ;;(:type :string ,(s-prefix "schema:contactType"))
                (:fax :string ,(s-prefix "schema:faxNumber"))
                (:email :string ,(s-prefix "schema:email"))
                (:telefoonnummer :string ,(s-prefix "schema:telephone")))
  :has-one `((preferred-label :via ,(s-prefix "schema:contactType")
                          :as "type"))
  :has-many `((opening-hours :via ,(s-prefix "schema:hoursAvailable")
                           :as "openingsuren"))
  :resource-base (s-url "https://data.westtoer.be/id/contact-point/")
  :on-path "contactpunten")


(define-resource opening-hours ()
  :class (s-prefix "schema:OpeningHoursSpecification")
  :properties `((:sluit :string ,(s-prefix "schema:closes"))
                (:open :string ,(s-prefix "schema:opens"))
                (:geldig-van :datetime ,(s-prefix "schema:validFrom"))
                (:geldig-tot :datetime ,(s-prefix "schema:validThrough")))

  :has-many `((preferred-label :via ,(s-prefix "schema:dayOfWeek")
                           :as "dagen"))

  :resource-base (s-url "https://data.westtoer.be/id/opening-hours/")
  :on-path "openingsuren")


(define-resource media ()
  :class (s-prefix "logies:MediaObject")
  :properties `((:lokale-identificator :rdfs-string ,(s-prefix "generiek:lokaleIdentificator"))
                (:naamruimte :rdfs-string ,(s-prefix "generiek:naamruimte"))
                (:afbeelding :url ,(s-prefix "schema:contentUrl"))
                (:publicatie-datum :datetime ,(s-prefix "schema:datePublished"))
                (:omschrijving :language-string-set ,(s-prefix "schema:description"))
                (:is-spotlight :boolean ,(s-prefix "westtoer:isSpotlight"))
                (:sort-order :rdfs-integer ,(s-prefix "westtoer:sortOrder")))
  :resource-base (s-url "https://data.westtoer.be/id/media/")
  :on-path "media")

(define-resource amenity-feature ()
  :class (s-prefix "logies:Faciliteit")
  :properties `((:is-verwijderd :boolean ,(s-prefix "westtoer:isDeleted"))
                (:naam :language-string-set ,(s-prefix "schema:name")))
  :has-one `((preferred-label :via ,(s-prefix "logies:isSpecialisatieVan")
                          :as "specialisatie-van"))
  :resource-base (s-url "https://data.westtoer.be/id/amenity-feature/")
  :on-path "faciliteiten")


(define-resource kwaliteitslabel ()
  :class (s-prefix "logies:Kwaliteitslabel")
  :properties `(
                ;;(:label :language-string-set ,(s-prefix "core:prefLabel"))
                (:toegekend-op :datetime ,(s-prefix "terms:issued"))
                (:toegekend-door :rdf-resource ,(s-prefix "schema:author"))
                ;;(:type :rdf-resource ,(s-prefix "terms:type"))
                 )

  :has-one `((preferred-label :via ,(s-prefix "terms:type")
                          :as "label"))
  :resource-base (s-url "https://data.westtoer.be/id/kwaliteitslabel/")
  :on-path "kwaliteitslabels")


(define-resource registration ()
  :class (s-prefix "logies:Registratie")
  :properties `((:geassocieerd-aan :rdf-resource ,(s-prefix "prov:wasAssociatedWith")))
  :resource-base (s-url "https://data.westtoer.be/id/registration/")
  :on-path "registraties")

(define-resource star-rating ()
  :class (s-prefix "schema:Rating")
  :properties `((:type :url ,(s-prefix "terms:type"))
                (:auteur :url ,(s-prefix "schema:author"))
                (:omschrijving :language-string-set ,(s-prefix "schema:description"))
                (:beste-score :string ,(s-prefix "schema:bestRating"))
                (:slechtste-score :string ,(s-prefix "schema:worstRating"))
                (:beoordeling-score :string ,(s-prefix "schema:ratingValue")))
  :resource-base (s-url "https://data.westtoer.be/id/star-rating/")
  :on-path "beoordelingen")

  (define-resource amount ()
  :class (s-prefix "schema:MonetaryAmount")
  :properties `((:prijs :number ,(s-prefix "schema:value"))
                (:eenheid :string ,(s-prefix "schema:currency")))
  :resource-base (s-url "https://data.westtoer.be/id/amount/")
  :on-path "prijzen")


(define-resource capacity ()
  :class (s-prefix "schema:QuantitativeValue")
  :properties `((:aantal :string ,(s-prefix "schema:unitText"))
                (:eenheid :number ,(s-prefix "schema:value")))
  :resource-base (s-url "https://data.westtoer.be/id/capacity/")
  :on-path "capaciteiten")




;; room and room-layout
(define-resource multipurpose-room ()
  :class (s-prefix "datatourisme:MultiPurposeRoomOrCommunityRoom")
  :properties `((:aantal-subzalen :integer ,(s-prefix "westtoer:aantalSubzalen")))
  :has-one `((quantitative-value :via ,(s-prefix "schema:floorSize")
                           :as "oppervlakte")
              (quantitative-value :via ,(s-prefix "schema:height")
                      :as "hoogte"))
  :has-many `((layout :via ,(s-prefix "datatourisme:hasLayout")
                      :as "indelingen"))
  :resource-base (s-url "https://data.westtoer.be/id/multipurpose-room/")
  :on-path "ruimtes")

(define-resource quantitative-value ()
  :class (s-prefix "schema:QuantitativeValue")
  :properties `((:unit-code :rdf-resource ,(s-prefix "schema:unitCode"))
                (:eenheid :string ,(s-prefix "schema:unitText"))
                (:aantal :number ,(s-prefix "schema:value")))
  :resource-base (s-url "https://data.westtoer.be/id/quantitative-value/")
  :on-path "ruimte-afmetingen")

(define-resource layout ()
  :class (s-prefix "datatourisme:RoomLayout")
  :properties `((:type :rdf-resource ,(s-prefix "terms:type"))
                (:indeling-beschikbaar :boolean ,(s-prefix "westtoer:indelingBeschikbaar")))
  :has-one `((capaciteit :via ,(s-prefix "logies:capaciteit")
                         :as "capaciteit"))
  :resource-base (s-url "https://data.westtoer.be/id/layout/")
  :on-path "layouts")


;; labels
(define-resource see-also ()
  :class (s-prefix "rdfs:Resource")
  :properties `((:url :url ,(s-prefix "schema:url")))
  :has-one `((preferred-label :via ,(s-prefix "schema:additionalType")
                          :as "extratype"))
  :resource-base (s-url "https://data.westtoer.be/id/see-also/")
  :on-path "zie-ook")


(define-resource preferred-label ()
  :class (s-prefix "core:Concept")
  :properties `((:version-of :rdf-resource ,(s-prefix "terms:isVersionOf"))
                (:label :language-string-set ,(s-prefix "core:prefLabel"))
                (:verwant-aan :rdf-resource ,(s-prefix "core:narrower"))
                (:is-verwijderd :boolean ,(s-prefix "westtoer:isDeleted")))
  :resource-base (s-url "https://data.westtoer.be/id/label/")
  :on-path "labels")
