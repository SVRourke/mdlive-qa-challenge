# MDLIVE QA Challenge

### Pagination

Pagination is a technique frequently seen in HTTP API's to make working with large data
sets more manageable. A huge number of different styles and implementations can be
observed across the web, but all of them share common characteristics.

```
    params: {
        "range": {
            "by": "id",
            "start": 10,
            "end": 50,
            "max": 5,
            "order": "asc"
        }
    }
```

The server would respond with the requested range of elements.

### Note that:

##### "by"

- required
- constrained to "id" OR "name"

##### "start"

- non-req
- defaults to the first record available

##### "end"

- non-req
- non-req even if start is used
- if omitted, defaults to "max"
- ignored if greater than max

##### "max"

- non-req
- defaults to 50

##### "order" _GUESSING_

- non-req
- defaults to asc

### examples of valid ranges:
```
    params: { "range": { "by": "id" } }
    params: { "range": { "by": "id", "start": 1 } }
    params: { "range": { "by": "id", "start": 1, "end": 5 } }
    params: { "range": { "by": "id", "start": 5 } }
    params: { "range": { "by": "id", "start": 1, "max": 5 } }
    params: { "range": { "by": "id", "start": 1, "order": "desc" } }
    params: { "range": { "by": "id", "start": 5, "end": 10, "max": 10, "order": "asc" } }
    params: { "range": { "by": "name", "start": "my-app-001", "end": "my-app-050", "max": 10, "order": "asc" } }
```

# Exercise

Let’s build a simple HTTP API endpoint that will perform pagination. 

# Tests
1. The endpoint should return a JSON array of “apps” that look like the following: [{ "id": 1, "name": "my-app-001",}]
2. When no "range" parameters are provided, the endpoint should respond with an array according to default parameters (that is, select appropriate defaults for the
    field which should be ordered on, the maximum page size, and the sort order).
3. When the endpoint is requested with a "range", it should modify its response to appropriately include only the items bounded by that range request:
```
params: { "range": { "by": "id", "start": 1, "max": 2 } }

[
    {
        "id": 1,
        "name": “my-app-001”,
    },
    {
        "id": 2,
        "name": "my-app-002",
    },
]
```

# Requirements
- JSON api
- Paginates according to the range format described in the first section.

- Paginates on either the id or name fields of our “app” object.
- You can use any programming language, but no libraries can be used to implement the pagination.

- Provide some seed data to populate and test the app.

# Deliverables

- An app with a single endpoint "/apps" that returns the array of apps paginated following the specification and requirements listed above.
- A README file containing a short description of the solution implemented, what was completed, etc. This is an opportunity to explain your approach and the reasoning behind your solution.
- The app should be delivered in a git repository publicly accessible on the web.
- The app must be deployed to Heroku and available for testing.
- Bonus points: Automatic tests covering the endpoint "/apps".

Please note that submissions with no README won't be considered.






# Deliverables

- A README file containing a short description of the solution implemented, what was completed, etc. This is an opportunity to explain your approach and the reasoning behind your solution.

- The app should be delivered in a git repository publicly accessible on the web.
- The app must be deployed to Heroku and available for testing.

Please note that submissions with no README won't be considered.

