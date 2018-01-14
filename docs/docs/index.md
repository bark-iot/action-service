# Actions Service

For full Bark documentation visit [http://localhost/docs](http://localhost/docs).

## Authorization

To perform any requests you need to send user token via `Authorization` header. Example:
`Authorization: Bearer <token>`.

## Show Action

GET `/houses/:house_id/devices/:device_id/actions/:id`

*PATH parameters*

Name         | Validation
------------ | ------------- 
id           | required
house_id     | required
device_id    | required

*Response [200]*

```json
{
  "id": 1,
  "device_id": 1,
  "title": "MyAction",
  "key": "my_action",
  "input": "[{\"key\":\"temp\",\"type\":\"int\"}]",
  "created_at": "2017-11-11 11:04:44 UTC",
  "updated_at": "2017-1-11 11:04:44 UTC"
}
```

`input` is json encoded field listing data keys and types sent with action.

*Error Response [401]*

Wrong user token

*Error Response [404]*

Action not found.

## Validate action 

Validates action belongs to house and returns it.

GET `/houses/:house_id/actions/:id`

*PATH parameters*

Name         | Validation
------------ | -------------
id           | required 
house_id     | required

*Response [200]*

```json
{
  "id": 1,
  "device_id": 1,
  "title": "MyAction",
  "key": "my_action",
  "input": "[{\"key\":\"temp\",\"type\":\"int\"}]",
  "created_at": "2017-11-11 11:04:44 UTC",
  "updated_at": "2017-1-11 11:04:44 UTC"
}
```

`input` is json encoded field listing data keys and types sent with action.

*Error Response [401]*

Wrong user token

*Error Response [404]*

Action for this house not found

## Create Action

POST `/houses/:house_id/devices/:device_id/actions`

*PATH parameters*

Name         | Validation
------------ | ------------- 
house_id     | required
device_id    | required


*POST parameters*

Name          | Validation
------------  | -------------
input         | optional 
title         | required
key           | required

*Response [200]*

```json
{
  "id": 1,
  "device_id": 1,
  "title": "MyAction",
  "key": "my_action",
  "input": "[{\"key\":\"temp\",\"type\":\"int\"}]",
  "created_at": "2017-11-11 11:04:44 UTC",
  "updated_at": "2017-1-11 11:04:44 UTC"
}
```

`input` is json encoded field listing data keys and types sent with action.

*Error Response [422]*

```json
[
  ["title", ["must be filled"]],
  ["key", ["must be filled"]],
  ["key", ["already taken"]]
]
```

*Error Response [401]*

Wrong user token

## Update Action

PUT `/houses/:house_id/devices/:device_id/actions/:id`

*PATH parameters*

Name         | Validation
------------ | ------------- 
house_id     | required
device_id    | required
id           | required


*POST parameters*

Name          | Validation
------------  | -------------
input         | optional 
title         | required

*Response [200]*

```json
{
  "id": 1,
  "device_id": 1,
  "title": "MyAction",
  "key": "my_action",
  "input": "[{\"key\":\"temp\",\"type\":\"int\"}]",
  "created_at": "2017-11-11 11:04:44 UTC",
  "updated_at": "2017-1-11 11:04:44 UTC"
}
```

*Error Response [422]*

```json
[
  ["title", ["must be filled"]]
]
```

*Error Response [401]*

Wrong user token

## List Actions

GET `/houses/:house_id/devices/:device_id/actions`

*PATH parameters*

Name         | Validation
------------ | ------------- 
house_id     | required
device_id    | required

*Response [200]*

```json
[
    {
      "id": 1,
      "device_id": 1,
      "title": "MyAction",
      "key": "my_action",
      "input": "[{\"key\":\"temp\",\"type\":\"int\"}]",
      "created_at": "2017-11-11 11:04:44 UTC",
      "updated_at": "2017-1-11 11:04:44 UTC"
    }
]
```

*Error Response [401]*

No token provided

## Delete Action

DELETE `/houses/:house_id/devices/:device_id/actions/:id`


*PATH parameters*

Name         | Validation
------------ | ------------- 
house_id     | required
device_id    | required
id           | required

*Response [200]*

Deleted.

*Error Response [401]*

No token provided