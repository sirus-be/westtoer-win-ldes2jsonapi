# SPARQL to JSONAPI

This repository provides a [JSON:API](http://jsonapi.org)-compatible interface to the LDES of Westtoer using [mu-cl-resources](https://github.com/mu-semtech/mu-cl-resources) as a base. Most configuration occurs in the domain file (`config/resources/domain.lisp`). This file defines the connection between the JSON world and the RDF world. When adjusting the model, ensure you have a clear understanding of how both worlds interact.


## Tutorials

### Getting started with the API

A quick start guide for using the JSON:API, which includes examples, is available [here](/getting_started.md).

### Starting the Service

All components use Docker Compose. To start the stack, run:

```bash
docker-compose up -d
```

Assuming the proxy is published on port 80, sending a request to `http://localhost/attracties` should return a JSON response with tourist attractions.

`mu-cl-resources` is driven by the `domain.lisp` file, which describes the connection between the JSON:API and the semantic model. This file contains resource definitions for each resource type.

Currently, the following resource types and endpoints are defined:

- **attracties**
- **adressen**
- **geometries**
- **contactpunten**
- **kwaliteitslabels**
- **capaciteiten**
- **registraties**
- **openingsuren**
- **tourisme-regios**
- **beoordelingen**
- **media**
- **faciliteiten**
- **prijzen**
- **identificatoren**

For more details on the definitions, supported attributes, and how everything is connected, refer to the [`config/domain.lisp`](config/resources/domain.lisp) file.

### Introduction to Configuration through `domain.lisp`

As mentioned earlier, `mu-cl-resources` is configured via the `domain.lisp` file. Additionally, the [`repository.lisp`](config/resources/repository.lisp) file can be used to define new prefixes to shorten your domain description. 

#### Introduction config/resources/domain.lisp

The domain.lisp contains resource definitions for each resource type in the application.  These resource definitions provide a three-way connection:

  - It names things to make connections within the domain.lisp file
  - It describes the properties as seen through the json api
  - It describes the semantic model used in order to implement the json api

Each resource definition is a combination of these three views.  Let us assume an example using [foaf](http://xmlns.com/foaf/0.1/).  In our example, we will model a Person, having one or more online accounts.  This model can be vizualised using [WebVOWL](http://visualdataweb.de/webvowl/#).

Intermezzo: mu-cl-resources is mainly configured in lisp.  Lisp uses parens () for grouping content.  If a paren is followed by a word, that word tends to indicate the content of the group.  If there is no word, it tends to be a list.  Other characters, like the backtick (`) or the comma (,) are best copied from examples.

    (define-resource person ()
      :class (s-url "http://xmlns.com/foaf/0.1/Person")
      :properties `((:name :string ,(s-url "http://xmlns.com/foaf/0.1/name")))
      :resource-base (s-url "http://my-application.com/people/")
      :on-path "people")

A simple definition of a person uses the foaf vocabulary to write the person and the person name.

  - *Line 1* contains `define-resource person`, which indicates that we'll create a new endpoint which we will name `person` in this file.  It is most customary to use a singular name for this name.
  - *Line 2* specifies that the RDF class to which the person belongs in the triplestore is [foaf:Person](http://xmlns.com/foaf/0.1/Person).
  - *Line 3* specifies a singular property of the person.  The JSONAPI will assume content of type `string` is stored in the json key `data.attributes.name` (because of `:name`).  This value is connected to our resource in the triplestore by the predicate [foaf:name](http://xmlns.com/foaf/0.1/name).  Note that this word may contain dashes, but not capitals (capitals are ignored).
  - *Line 4* indicates the URI to use in the triplestore when we create new resources of this type.  The supplied url is postfixed with a UUID.
  - *Line 5* specifies the endpoint on which we can list/create/update our resource.  In our case, requests to `/people` are mapped to this resource.

Assuming the foaf `prefix` is defined, we can make this example slightly easier to read.  Note the use of `s-prefix`.

    (define-resource person ()
      :class (s-prefix "foaf:Person")
      :properties `((:name :string ,(s-prefix "foaf:name")))
      :resource-base (s-url "http://my-application.com/people/")
      :on-path "people")

This code sample implements the same functionality as the example above, yet it is easier on the eyes.

You may have noticed the double opening parens on line 3, after the `:properties` keyword.  We can insert multiple properties if desired.  Ensuring we have the right amount of opening and closing parens, we can update our example to also contain the age of the person, expressed as a number.

    (define-resource person ()
      :class (s-prefix "foaf:Person")
      :properties `((:name :string ,(s-prefix "foaf:name"))
                    (:age :number ,(s-prefix "foaf:age")))
      :resource-base (s-url "http://my-application.com/people/")
      :on-path "people")

With this minor change, our person supports the name and age attributes.

Most resources link to other resources.  Let's first define a second resouce, an [OnlineAccount](http://xmlns.com/foaf/0.1/OnlineAccount).

    (define-resource account ()
      :class (s-prefix "foaf:OnlineAccount")
      :properties `((:name :string ,(s-prefix "foaf:accountName")))
      :resource-base (s-url "http://my-application.com/accounts/")
      :on-path "accounts")

The definition of this `account` resource is very similar to that of the `person` resource.  How do we link a person to an account?  Assuming the person has many accounts, we link by using the `:has-many` keyword.

    (define-resource person ()
      :class (s-prefix "foaf:Person")
      :properties `((:name :string ,(s-prefix "foaf:name"))
                    (:age :number ,(s-prefix "foaf:age")))
      :has-many `((account :via ,(s-prefix "foaf:account")
                           :as "accounts"))
      :resource-base (s-url "http://my-application.com/people/")
      :on-path "people")

The statement on lines 5 and 6 specifies that a `person` may link to many resources of type `account`.  In the triplestore, the link can be found by following the [foaf:account](http://xmlns.com/foaf/0.1/account) property, originating from the person's URI.  This relationship is exposed to the JSON API by using the relationship name "accounts".  Hence a GET to `/people/42/accounts` would yield the accounts of the person with UUID 42.

How about getting the person which links to this account.  There is only a single person connected to an account.  Hence we can use the `has-one` keyword to symbolize this.  In the semantic model of the triplestore, the relationship uses the [foaf:account](http://xmlns.com/foaf/0.1/account) property going from the person to the account.  Finding the person for an account therefore means we have to follow the same relationship in the other direction.  We can add the option `:inverse t` to any relationship to make the semantic model follow the inverse arrow.  Here, the key in the json body will be `owner` rather than person.

    (define-resource account ()
      :class (s-prefix "foaf:OnlineAccount")
      :properties `((:name :string ,(s-prefix "foaf:accountName")))
      :has-one `((person :via ,(s-prefix "foaf:account")
                         :inverse t
                         :as "owner"))
      :resource-base (s-url "http://my-application.com/accounts/")
      :on-path "accounts")

The complete setup of our user and account looks as follows:

    (define-resource person ()
      :class (s-prefix "foaf:Person")
      :properties `((:name :string ,(s-prefix "foaf:name"))
                    (:age :number ,(s-prefix "foaf:age")))
      :has-many `((account :via ,(s-prefix "foaf:account")
                           :as "accounts"))
      :resource-base (s-url "http://my-application.com/people/")
      :on-path "people")

    (define-resource account ()
      :class (s-prefix "foaf:OnlineAccount")
      :properties `((:name :string ,(s-prefix "foaf:accountName")))
      :has-one `((person :via ,(s-prefix "foaf:account")
                         :inverse t
                         :as "owner"))
      :resource-base (s-url "http://my-application.com/accounts/")
      :on-path "accounts")

#### Introduction config/resources/repositories.lisp

The previous example used the foaf prefix in order to denote classes and properties.  The `repositories.lisp` allows you to specify your own prefixes to use in your definitions.  A good source for commonly used abbreviations is [prefix.cc](https://prefix.cc).

    (add-prefix "foaf" "http://xmlns.com/foaf/0.1/")


#### Resulting API
We intend to support the full spec of [JSONAPI](http://jsonapi.org). Most of what you read there will work, errors being a notable exception.  Here, we list some common calls which you could execute using the resources specified above.

  - `# GET /attracties`
  - `# GET /attracties/0b29a57a-d324-4302-9c92-61958e4cf250/media`
  - `# GET /attracties?filter[naam]=Mu.ZEE`
  - `# GET /attracties?include=media`
  - `# GET /attracties?include=adres&filter[adres][post-code]=8400`
  - `# GET /attracties?sort=generated-at-time`

  - `# POST /attracties/0b29a57a-d324-4302-9c92-61958e4cf250`
  - `# PATCH /attracties/0b29a57a-d324-4302-9c92-61958e4cf250`
  - `# PATCH /attracties/0b29a57a-d324-4302-9c92-61958e4cf250/relationships/media`
  - `# DELETE /attracties/0b29a57a-d324-4302-9c92-61958e4cf250/relationships/faciliteiten`
  - `# DELETE /attracties/0b29a57a-d324-4302-9c92-61958e4cf250`

More information on each of these calls can be found throughout this document.


## Reference
### Defining resources in Lisp
As the integration with the frontend data-store is handled automatically, most of your time with mu-cl-resources will be spent configuring resources.  This overview provides a non-exhaustive list of the most common features of mu-cl-resources.

Each defined resource is specified by the `define-resource` construction.  An example could look like this:

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
      :resource-base (s-url "https://data.westtoer.be/id/product/")
      :on-path "attracties")


We will use this example to explain how various features in mu-cl-resources work.

#### Overview of keys

Each call to `define-resource` starts out with the name of the resource (used when referring to the resource internally), a set of empty parens (for future use), and a set of key-value pairs.  This section gives a brief overview of the valid keys, and what their use is.

  - *`:class`* Sets the RDF Class to which instances should belong.  Use `s-url` when setting the full URL.
  - *`:properties`* Describes the properties (currently named attributes in the json response) of the resource.
  - *`:has-one`* Describes relationships of which at most one is expected to exist.
  - *`:has-many`* Describes relationships of which zero or more are expected to exist.
  - *`:features`* Optional features to be used in this resource.  Our example indicates the URI should be returned as an attribute.
  - *`:resource-base`* An `s-url` containing the prefix for the URI used when creating new resources.
  - *`:on-path`* The path on which the resource is supplied, this corresponds to the `type` property in the JSON body.  JSONAPI advises to use the plural form here.

#### Simple properties

The properties section in the mu-cl-resources configuration corresponds to the attributes in the JSON payload.  This section describes how to set properties.

The properties section in our example looks like:

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

All properties are contained in a backtick (`) quoted list (note that this is *not* a regular quote (').  Each property description is itself contained in a list.  The list contains three ordered elements by default:

  1. *key name* First option is the key name (ie: `:naam`).  It is downcased and used as the JSON key of the attribute.
  2. *type* Second option is the type of the attribute.  This ensures we correctly translate the attribute from JSON to SPARQL and vice-versa.  Use `,(s-url "...")` for full URLs or `,(s-prefix "...")` for shorthand names.
  3. *rdf property* Third option is the RDF property of the attribute.  This is the URL used on the arrow of the RDF model in the triplestore.
  4. *options* Any other keys following the three elements above are options to describe something extra about the resources.  The format of these may change over time.

A wide set of types is supported.  Extensions are necessary in order to implement new types:

  - *string* A regular string
  - *number* A number. Can be [decimals](https://www.w3.org/TR/xmlschema-2/#decimal) or [floats](https://www.w3.org/TR/xmlschema-2/#float). For read-only operations more types ([integers](https://www.w3.org/TR/xmlschema-2/#integer)) are supported.
  - *integer* An [integer](https://www.w3.org/TR/xmlschema-2/#integer), being a non-bounded whole number
  - *float* A [float](https://www.w3.org/TR/xmlschema-2/#float), being a floating point number
  - *boolean* A boolean, true or false
  - *date* A date as understood by your triplestore
  - *datetime* A date and time combination, as understood by your triplestore
  - *time* A time without a date, as understood by your triplestore
  - *url* A URL to another resource
  - *uri-set* An array of URIs
  - *string-set* An array of strings
  - *language-string* A string which has a language connected to it (may contain multiple languages)
  - *language-string-set* An array of strings which have a language connected to it (may contain multiple languages per answer)
  - *g-year* Experimental: A specific representation of a year
  - *geometry* Experimental: A geometry-string in a format your triplestore understands
  
  Extended with the following types for Westtoer:
  - *uri-string* to support strings of type "http://www.w3.org/2000/01/rdf-schema#string"
  - *xsd-secure-double* to support doubles of type "https://www.w3.org/2001/XMLSchema#double"
  - *uri* to support URIs of type "http://www.w3.org/2001/XMLSchema#anyURI"


#### Relationships

Relationships are split into single value `:has-one` and multiple value `:has-many` relationships.  In both cases, having a value is optional.

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
                  (amount :via ,(s-prefix "schema:amount")
                          :as "prijs"))
        :has-many `((media :via ,(s-prefix "logies:heeftMedia")
                          :as "media")
                    (amenity-feature :via ,(s-prefix "schema:amenityFeature")
                                      :as "faciliteiten"))

Both `:has-one` and `:has-many` allow to specify more than one relationship.  The outermost parens group all relationships.  We use the backtick (`) rather than quote (') in order to denote the list of properties.

The format of a single value consists of the internal name of the resource to be linked to, followed by keyword properties describing the relationship.

  - *`:via`* Contains the URI of the RDF property by which the related objects can be found.
  - *`:as`* Contains the attribute in the JSON API.
  - *`:inverse`* Optional, when set to `t` it inverses the direction of the relationship supplied in `:via`.

### Querying the API

mu-cl-resources provides extensive support for searching and filtering through results.  A notable exception is fuzzy text search as that is not a built-in for standard SPARQL.

The [JSONAPI spec](http://jsonapi.org/format/#fetching-filtering) leaves all details on searching, except for the used url parameter, open to the implementors.  Our specification leverages the breath of the Linked Data model to enable powerful searches.

We will mostly base ourselves on the example which was previous supplied.

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
                (amount :via ,(s-prefix "schema:amount")
                        :as "prijs"))
      :has-many `((media :via ,(s-prefix "logies:heeftMedia")
                        :as "media")
                  (amenity-feature :via ,(s-prefix "schema:amenityFeature")
                                    :as "faciliteiten"))
      :resource-base (s-url "https://data.westtoer.be/id/product/")
      :on-path "attracties")

#### Basic filtering

Basic searching is done by using the `?filter` query parameter.  We can search for "Mu.ZEE" in any key of our `tourist-attraction` by sending

    GET /attracties?filter=Mu.ZEE

If we want to search only for names matching "Mu.ZEE", we can limit the search to that keywoard.

    GET /attracties?filter[naam]=Mu.ZEE

All of these searches are case-insensitive, and they search for any field which contain the contents (Het Mu.ZEE museum) would therefore be returned too.  We can make an exact match with a special search.

    GET /attracties?filter[:exact:naam]=Mu.ZEE

All filter modifiers start with a colon (:) followed by the name of the filter, followed by a configuration parameter.  This specific filter will search for a name with exactly "Mu.ZEE" in its contents.  No more, no less.

#### Filtering relationships

Filters can also be scoped to relationships.  JSONAPI guarantees that attributes and relationships will never share a name.  Hence we can use the same syntax as we used to identify an attribute in order to identify a relationship.

    GET /attracties?filter[adres]= 8400

Searches for attracties which have "8400" in one of their fields.  It is also possible to search for specific properties, or to apply special filters to this.  Assuming we want to find all accounts for people whose *post-code* contains 8400, we'd search for the following:

    GET /attracties?filter[adres][post-code]=8400

We can add more filters as we please.  We can search for all tourist-attraction within Oostende that have "museum" in their name.

    GET /attracties?filter[naam]=museum&filter[adres][post-code]=8400



#### Sorting

Sorting is specified in [JSONAPI](http://jsonapi.org/format/#fetching-sorting) somewhat more extensively.  What is specified there works, but is augmented to sorting by relationships.

Let's sort our attracties by their name

    GET /attracties?sort=naam

Let's sort by publishing date, descending and then by name

    GET /attracties?sort=-generated-at-time,naam

Sorting by relationships allows us to sort attracties by the adres

    GET /attracties?sort=adres.provincie

Assuming your result set consists of strings, you can sort ignoring case by using the `:no-case:` modifier.  Application in result sets containing a multitude of properties is undefined and implementation may change.

    GET /attracties?sort=-:no-case:naam


#### Special filters

Aside from regular text searches, a set of custom filters have been added.  These filters are the last component of a search, and are easy to identify as they start with a colon (:).  Following is a brief list of filters which exist.  This list may be extended over time.

- *:uri:* Search for the URL of a relationship.

    GET /attracties?filter[adres][:uri:]=http://my-application.com/attracties/42

- *:exact:* Searches for the exact string as a value

    GET /attracties?filter[adres][:exact:gemeente]=Brugge

- *:gt:* Ensures the property has a larger value than the supplied value

    GET /attracties?filter[:gt:generated-at-time]=2024-10-10

- *:gte:* Ensures the property has a value larger than or equal to the supplied value
- *:lt:* Ensures the property has a smaller value than then supplied value
- *:lte:* Ensures the property has a smaller value than then supplied value or is equal to the supplied value

- *:has-no:* Ensures the supplied relationship does not exist.  An example could list all attracties without an address.  The supplied value is not used.  Syntax may be subject to change.

    GET /attracties?filter[:has-no:adres]=true

- *:has:* The inverse of `:has-no:` forces the relationship to exist.  Syntax may be subject to change.


### Including Results

The [JSON:API specification](http://jsonapi.org/format/#fetching-includes) includes an optional feature for **including related resources** in a response. This feature allows you to request related resources in a single call, reducing the need for multiple server requests.

To include related resources in the response, use the `include` query parameter. For example:

- To fetch all tourist attractions along with their adressen:

    ```http
    GET /attracties?include=adres
    ```

- To fetch all tourist attractions along with their adressen, geometries, and media:

    ```http
    GET /attracties?include=adres,geometrie,media
    ```

#### Combining Includes with Filters

You can combine includes with filters for more specific queries. By default, the previous example fetches all tourist attractions, even those without an address. To fetch only tourist attractions that have an address (and include those adressen in the response), you can use the following:

```http
GET /attracties?include=adres&filter[:has:adres]=true
```

This approach enables a powerful and flexible API, as it combines related resources with filtering options. However, keep in mind that including additional results may require more database queries, potentially impacting performance. 


#### Pagination

Pagination is also included in [the JSONAPI spec](http://jsonapi.org/format/#fetching-pagination).  All resources have it enabled by default.  We support the `page[number]` and `page[size]` variant.

The default page size can be configured by setting the `*default-page-size*` to the desired amount of pages.  It defaults to 20.  Single resources can opt out of pagination.  Single requests can overwrite the size of the pagination.  In practice, we discover that there's nearly always an upper bound you want to set for the pagination to ensure things don't break in the frontend.  Included resources (using the `include` query parameter) are never paginated.

If you want to override the default page size in your `domain.lisp`, add the following code:

    (defparameter *default-page-size* 50)

You can also choose to set the `MU_DEFAULT_PAGE_SIZE` environment variable before mu-cl-resources boots.

If you want to opt out of pagination for a specific resource, add the `no-pagination-defaults` feature.

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


If you want to override the page size for a specific request, you can do so by suppling the `page[size]` query parameter:

    GET /media?page[size]=100

If you want to request a different page and a different page size, supply both `page[size]` and `page[number]`:

    GET /media?page[size]=42&page[number]=3

If you want mu-cl-resources to yield the total amount of results in the `meta` portion of the response, set `*include-count-in-paginated-responses*` to `t` in your `domain.lisp`.

    (defparameter *include-count-in-paginated-responses* t)


#### Sparse fieldsets

Sparse fieldsets is also [a feature of JSONAPI](http://jsonapi.org/format/#fetching-sparse-fieldsets).  If your model has many attributes, but you do not intend to render them on the frontend, you can opt out of fetching them.  Use the `fields` query parameter to fetch only the necessary results.

The `fields` parameter needs to be scoped to the type of the objects for which you want to limit the returned properties.  If we'd want to return only the name for a  tourist-attractions listing, we'd use the following:

    GET /attracties?fields[attracties]=naam

This becomes more intersting as we include more resources.  Say that I include the adres, but only the municipality and post-code.

    GET /attracties?include=adres&fields[attracties]=naam&fields[adres]=gemeente,post-code



### Caching

Efficient caching is a complex story.  mu-cl-resources ships with support for two levels of caching: an internal cache which can keep track of object properties and counts, and an external cache which can cache complete queries.

Both of these caches are subject to change in their implementation, but the end-user API should stay the same.

#### Internal cache

In order to opt in to the internal model caching, set `*cache-model-properties*` to `t`.  Note that this currently assumes mu-cl-resources is the only service altering the resources.

    (defparameter *cache-model-properties* t)

Separate from this, you can choose to also cache the count queries.  On very large datasets, counting the amount of results may become expensive.  Set the `*cache-count-queries*` parameter to `t` for this.

    (defparameter *cache-count-queries* t)

Note: mu-cl-resources does not clear its internal caches when external services update the semantic model without wiring.  See below for wiring the delta-notifier.

#### External cache

Caching requests is more complex for a JSONAPI than for a web page.  A single update may invalidate a wide range of pages, but it should not invalidate too many pages.  As such, we've written a separate cache for JSONAPI-like bodies.  Find it at [mu-semtech/mu-cache](https://github.com/mu-semtech/mu-cache).

In order to enable the external cache, you have to set the `*supply-cache-headers-p*` parameter to `t` in your `domain.lisp`.

    (defparameter *supply-cache-headers-p* t)

Note: mu-cl-resources speaks the protocol of this cache, but does not update the cache when external resources update the semantic model without see below for wiring the delta-notifier.

#### Cache clearing with delta-notifier

mu-cl-resources has multiple levels of caching and can update these when it updates the model in the database.  when external services update the semantic model, mu-cl-resources needs to be informed about these changes so it can correctly clear the caches it maintains.

In order for cache clearing to work, delta's need to be received.  This requires setting up mu-authorization and delta-notifier to receive the delta's.  mu-authorization needs to be configured so it sends raw delta messages to the delta-notifier.  The delta-notifier needs to be configured so it forwards the correct format to mu-cl-resources.  mu-cl-resources needs to be wired to the mu-cache so it can clear those caches when changes arrive.

## Linked resources

**[sirus-mu-resources](https://github.com/stefaanvercoutere/mu-cl-resources)** Fork of [mu-cl-resources](https://github.com/mu-semtech/mu-cl-resources) with additional datatypes (double, uri, string) for compatibility with the Westtoer-LDES. Docker image [sirus-mu-resources](https://hub.docker.com/r/svercoutere/sirus-mu-resources).

**[flask-proxy](/proxy/)** Additional functionallity and blocking of unauthorized call methods (PUT, PATCH, DELETE, POST).
Docker image [sirus-westtoer-proxy](https://hub.docker.com/r/svercoutere/sirus-westtoer-proxy).
