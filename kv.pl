:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).

:- dynamic(kv_store/2).
:- dynamic(kv_tag/2).

% KV STORE: kv_store(Key, Value)
% a fact that holds a key and a value. Used in db asserts and retracts.

% KV TAG: kv_tag(Tag, KeysList)
% a fact that holds a tag and all of the keys it applies to. Used in db asserts and retracts.

% Define predicates for handling HTTP requests

% http_handler as basis for GET, POST, DELETE
% http_handler(Path, Closure, Options)
% GET, POST, DELETE:
%   Path is a REST call and thus relative
%   Closure holds value from handler
%   Options is a list with single element for REST method

% GET request to retrieve a value
:- http_handler('/get', get_value, [method(get)]).
get_value(Request) :-
    http_parameters(Request, [key(Key, [])]),
    (   kv_store(Key, Value)
    ->  reply_json(json{key:Key, value:Value})
    ;   reply_json(json{error:'Key not found'}, [status(404)])
    ).

% POST request to store a key-value pair
:- http_handler('/post', post_value, [method(post)]).
post_value(Request) :-
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

% TAG request to tag a key-value pair
:- http_handler('/tag', tag_key, [method(post)]).
tag_key(Request) :-
    http_read_json_dict(Request, Data),
    (   atom_string(Key, Data.key),
        kv_store(Key, _)
    ->  (
            atom_string(Tag, Data.tag)
        ->  (
                kv_tag(Tag, OldKeys),
                \+ member(Key, OldKeys)
            ->  append(OldKeys, [Key], NewKeys),
                assertz(kv_tag(Tag, NewKeys)),
                retract(kv_tag(Tag, OldKeys)),
                reply_json(json{status:'Key tagged successfully'})
            ;   (
                    \+ kv_tag(Tag, _)
                ->  assertz(Tag, [Key]),
                    reply_json(json{status:'Key tagged successfully'})
                ;   reply_json(json{error:'Key already has that tag'}, [status(400)])
                )
            )
        ;   reply_json(json{error:'Invalid request format'}, [status(400)])
        )
    ;   reply_json(json{error:'Key not found'}, [status(404)])
    ).

% UNTAG request to remove tag from a key-value pair
:- http_handler('/untag', untag_key, [method(post)]).
untag_key(Request) :-
    http_read_json_dict(Request, Data),
    (   atom_string(Key, Data.key),
        kv_store(Key, _)
    ->  (
            atom_string(Tag, Data.tag)
        ->  (
                kv_tag(Tag, OldKeys),
                member(Key, OldKeys),
                \+ same_length(OldKeys, [Key])
            ->  delete(OldKeys, Key, NewKeys),
                assertz(kv_tag(Tag, NewKeys)),
                retract(kv_tag(Tag, OldKeys)),
                reply_json(json{status:'Key untagged successfully'})
            ;   (
                    kv_tag(Tag, [Key])
                ->  retract(Tag, [Key]),
                    reply_json(json{status:'Key untagged successfully'})
                ;   reply_json(json{error:'Key does not have that tag'}, [status(400)])
                )
            )
        ;   reply_json(json{error:'Invalid request format'}, [status(400)])
        )
    ;   reply_json(json{error:'Key not found'}, [status(404)])
    ).

% Define the HTTP server handler
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

% Start the HTTP server on port 8000
:- initialization
    server(8000).

