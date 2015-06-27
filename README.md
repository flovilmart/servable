Servable
====

Swift 2.0 Protocol Oriented Server infrastructure

#Goals

Provide a simple server infrastructure that will allow high code reusability through a set of simple protocols inspired by express.js

#Design

The Servable library is implemented around a simple protocol `Servable`
This protocol is the base for all other protocols and it's goal is to provide processing steps through it's simple method 

`handle(request:response:next)`

Everything along the stack is a servable as the server, router or final endpoint allowing for strong decoupling of logic.

As servable is a protocol, you can add it to your existings classes, controller without changing the current logic. Thus providing high maintainability.


The Request and Response objects are loosly modeled after express.js.

The ServableStack is designed as a tree. 

                        + Route - Router ...
                        |
              +- Router + Route - Servable
              |
              +- Server - Router - Servable
              |
	Server -> +- Server - Servable
	          |
			  +- Servable
			  
Upon calling `handleConnection(connection:)` the server will process it's tree in order starting from the first element in it's `Servables` as each servable is processed the tree is getting processed in order recursively.

One can abort the the traversal by not calling next(). 
Note that flushing the response with response.flush() will not abort the traversal.

#Modularity

Due to it's modular and protocol based implementation, the design allows swapping the server implementation, or router implementation without changing the core logic of the Servable endpoints.

That will help moving forward with the ability to create mutliple servers at once that would use the same processing tree.

Because the connection is responsible for generating the Request and Response objects and Response is only defined as a protocol, it makes it really easy to create custom response types like JSON response, RAW, base64, templates etc.. based upon the request params.

Through protocol extension it's also really easy to add additional capabilities to the Response protocol as another alternative to custom Conneciton object.

# Next Steps

- Implement base HTTP/1.1 server
- Implement base HTTP/2.0 server
- Test Coverage
 

# Protocols

### `protocol Servable`

Simple protocol that takes a Request and Response object with a next callback

### `protocol Servables`

Wrapper around [Servable] to process in order

### `protocol ServableStack:Servable`

Base protocol for Router and Server

Implements through protocol extension Servable for nesting

Implements `use(servable:Servable)`


### `protocol Router`

extends ServableStack with HTTP common methods

### `protocol Server`

extends ServableStack with `listen(options:)` and `handleConnection(connection:next:)`

### `protocol Connection`

base connection object with read, write capabilities and request, response generation

### `protocol Response`

base for Response

## Usage

