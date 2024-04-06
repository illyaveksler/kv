:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).

:- dynamic(kv_store/2).

% Define predicates for handling HTTP requests

% GET request to retrieve a value
:- http_handler('/get', get_value, [method(get)]).
get_value(Request) :-
    http_parameters(Request, [key(Key, [])]),
    (   kv_store(Key, Value)
    ->  reply_json(json{key:Key, value:Value})
    ;   reply_json(json{error:'Key not found'}, [status(404)])
    ).

% POST request to store a key-value pair
:- http_handler('/put', put_value, [method(post)]).
put_value(Request) :-
    http_read_json_dict(Request, Data),
    (   atom_string(Key, Data.key),
        atom_string(Value, Data.value),
        \+ kv_store(Key, _)
    ->  assertz(kv_store(Key, Value)),
        reply_json(json{status:'Key-value pair stored successfully'})
    ;   reply_json(json{error:'Key already exists or invalid request format'}, [status(400)])
    ).

% DELETE request to remove a key-value pair
:- http_handler('/delete', delete_value, [method(delete)]).
delete_value(Request) :-
    http_parameters(Request, [key(Key, [])]),
    (   retract(kv_store(Key, _))
    ->  reply_json(json{status:'Key-value pair deleted successfully'})
    ;   reply_json(json{error:'Key not found'}, [status(404)])
    ).

% Define the HTTP server handler
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

% Start the HTTP server on port 8000
:- initialization
    server(8000).

