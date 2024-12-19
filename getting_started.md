# Let's get started
Sample JSON:API requests

This page provides some practical examples to query the data. Dive into the examples to understand the mechanics of fetching data through JSON:API requests. It's a straightforward, hands-on approach to acquainting yourself with the functionalities of our APIs.


## Endpoints

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

## Basic harvesting

This section explains how you can retrieve all data per city through pagination, and how you can stay up to date.

### Replication

Use following URL to retrieve the first 20 (default) Westtoer products, located in the city of Brugge, with everything included:

    GET /attracties?filter[adres][post-code]=8000&include=identificator,adres,geometrie,contactpunt,tourismeRegio,beoordeling,registratie,prijs,media,kwaliteitslabels,faciliteiten

NOTE: we are still in progress of mapping all fields (layout, product status...)

Then, follow the "Next" page link mentioned in the response towards the next 20 products. For example:

    GET /attracties?filter[adres][post-code]=8000&page[number]=1&include=identificator,adres,geometrie,contactpunt,tourismeRegio,beoordeling,registratie,prijs,media,kwaliteitslabels,faciliteiten

Repeat this process until there is no "Next" link available.

### Synchronization

Once you have copied all the data in previous step, you can now only fetch the latest changed products.
This can be done by adding a filter parameter on generated-at-time.

For example, to retrieve all updates greater than or equal to 2024-10-06: `filter[:gte:generated-at-time]=2024-10-06`

GET /attracties?filter[:gte:generated-at-time]=2024-10-06&filter[adres][post-code]=8000&include=identificator,adres,geometrie,contactpunt,tourismeRegio,beoordeling,registratie,prijs,media,kwaliteitslabels,faciliteiten

You can also filter on a timestamp: `filter[:gte:generated-at-time]=2024-10-10T11:50:27Z`

## Basic filtering

Basic searching is done by using the `?filter` query parameter.  We can search for "Mu.ZEE" in any key of our `tourist-attraction` by sending

    GET /attracties?filter=Mu.ZEE

If we want to search only for names matching "Mu.ZEE", we can limit the search to that keywoard.

    GET /attracties?filter[naam]=Mu.ZEE

All of these searches are case-insensitive, and they search for any field which contain the contents (Het Mu.ZEE museum) would therefore be returned too.  We can make an exact match with a special search.

    GET /attracties?filter[:exact:naam]=Mu.ZEE

All filter modifiers start with a colon (:) followed by the name of the filter, followed by a configuration parameter.  This specific filter will search for a name with exactly "Mu.ZEE" in its contents.  No more, no less.

## Filtering relationships

Filters can also be scoped to relationships.  JSONAPI guarantees that attributes and relationships will never share a name.  Hence we can use the same syntax as we used to identify an attribute in order to identify a relationship.

    GET /attracties?filter[adres]= 8400

Searches for attracties which have "8400" in one of their fields.  It is also possible to search for specific properties, or to apply special filters to this.  Assuming we want to find all accounts for people whose *post-code* contains 8400, we'd search for the following:

    GET /attracties?filter[adres][post-code]=8400

We can add more filters as we please.  We can search for all tourist-attraction within Oostende that have "museum" in their name.

    GET /attracties?filter[naam]=museum&filter[adres][post-code]=8400



## Sorting

Sorting is specified in [JSONAPI](http://jsonapi.org/format/#fetching-sorting) somewhat more extensively.  What is specified there works, but is augmented to sorting by relationships.

Let's sort our attracties by their name

    GET /attracties?sort=naam

Let's sort by publishing date, descending and then by name

    GET /attracties?sort=-generated-at-time,naam

Sorting by relationships allows us to sort attracties by the adres

    GET /attracties?sort=adres.provincie

Assuming your result set consists of strings, you can sort ignoring case by using the `:no-case:` modifier.  Application in result sets containing a multitude of properties is undefined and implementation may change.

    GET /attracties?sort=-:no-case:naam


## Special filters

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

- *:or:* Filters are normally combined using AND, this allows a set of filters to be defined as OR instead.

    GET /attracties?filter[:or:][naam]=Mu.ZEE&[:or:][naam]=Museum


## Including Results

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

## Combining Includes with Filters

You can combine includes with filters for more specific queries. By default, the previous example fetches all tourist attractions, even those without an address. To fetch only tourist attractions that have an address (and include those adressen in the response), you can use the following:

```http
GET /attracties?include=adres&filter[:has:adres]=true
```

This approach enables a powerful and flexible API, as it combines related resources with filtering options. However, keep in mind that including additional results may require more database queries, potentially impacting performance. 


## Sparse fieldsets

Sparse fieldsets is also [a feature of JSONAPI](http://jsonapi.org/format/#fetching-sparse-fieldsets).  If your model has many attributes, but you do not intend to render them on the frontend, you can opt out of fetching them.  Use the `fields` query parameter to fetch only the necessary results.

The `fields` parameter needs to be scoped to the type of the objects for which you want to limit the returned properties.  If we'd want to return only the name for a  tourist-attractions listing, we'd use the following:

    GET /attracties?fields[attracties]=naam

This becomes more intersting as we include more resources.  Say that I include the adres, but only the municipality and post-code.

    GET /attracties?include=adres&fields[attracties]=naam&fields[adres]=gemeente,post-code



## More examples

### Example 1: List of all tourist attractions

curl -X GET -H "Accept: application/vnd.api+json" \
  "/attracties?sort=naam&page[size]=100"


### Example 2: List of all tourist attractions in Brugge with address and location

curl -X GET -H "Accept: application/vnd.api+json" \
  "GET /attracties?filter[adres][post-code]=8000&include=adres,geometrie"


### Example 3: List of all tourist attractions allowing pets  

curl -X GET -H "Accept: application/vnd.api+json" \
  "GET /attracties?filter[faciliteiten][naam]=Huisdieren%20toegelaten&include=faciliteiten"
