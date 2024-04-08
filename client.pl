:- use_module(library(http/http_client)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).




% gets a value from a key.
getKV(Key, Result) :- catch(
    access(get, Key, Reply),
    error(_, _),
    (
        Reply = [],
        format('Key not found.', [])
    )
),  (
    \+ (Reply == [])
    ->  atom_json_dict(Text, Reply, []),
        atom_json_dict(Text, Dict, []),
        Result = Dict.value
    ;   Result = []
).

% posts a key-value pair to the server.
postKV(Key, Value, Result) :- catch(
    access(post, Key, Value, Reply),
    error(_, _),
    (
        Reply = [],
        format('Key either already exists, or the post is invalid.', [])
    )
),  (
    \+ (Reply == [])
    ->  atom_json_dict(Text, Reply, []),
        atom_json_dict(Text, Dict, []),
        print(Dict.status),
        Result = []
    ;   Result = []
).

% deletes a key-value pair from the server.
deleteKV(Key, Result) :- catch(
    access(delete, Key, Reply),
    error(_, _),
    (
        Reply = [],
        format('Key not found: ~s', [Key])
    )
),  (
    \+ (Reply == [])
    ->  atom_json_dict(Text, Reply, []),
        atom_json_dict(Text, Dict, []),
        print(Dict.status),
        Result = []
    ;   Result = []
).

tagQueryKV(Tag, Result) :- catch(
    access(tagquery, Tag, Reply),
    error(_, _),
    (
        Reply = [],
        format('Tag not found: ~s', [Tag])
    )
),  (
    \+ (Reply == [])
    ->  atom_json_dict(Text, Reply, []),
        atom_json_dict(Text, Dict, []),
        Result = Dict.keys
    ;   Result = []
).

tagKV(Key, Tag, Result) :- catch(
    access(tag, Key, Tag, Reply),
    error(Error, _),
    (
        Reply = [],
        print(Error)
    )
),  (
    \+ (Reply == [])
    ->  atom_json_dict(Text, Reply, []),
        atom_json_dict(Text, Dict, []),
        print(Dict.status),
        Result = []
    ;   Result = []
).

untagKV(Key, Tag, Result) :- catch(
    access(tag, Key, Tag, Reply),
    error(Error, _),
    (
        Reply = [],
        print(Error)
    )
),  (
    \+ (Reply == [])
    ->  atom_json_dict(Text, Reply, []),
        atom_json_dict(Text, Dict, []),
        print(Dict.status),
        Result = []
    ;   Result = []
).





access(get, Key, Reply) :- portURL(8000, URL), 
                            get_url(Key, URL, HREF),
                            http_get(HREF, Reply, []).

access(delete, Key, Reply) :- portURL(8000, URL), 
                            delete_url(Key, URL, HREF), 
                            http_delete(HREF, Reply, []).

access(tagquery, Tag, Reply) :- portURL(8000, URL), 
                            tquery_url(Tag, URL, HREF),
                            http_get(HREF, Reply, []).

access(post, Key, Value, Reply) :- portURL(8000, URL), 
                                post_url(URL, HREF),
                                http_post(HREF, json(json{key: Key, value: Value}), Reply, []).

access(tag, Key, Tag, Reply) :- portURL(8000, URL),
                                tag_url(URL, HREF),
                                http_put(HREF, json(json{key: Key, tag: Tag}), Reply, []).

access(untag, Key, Tag, Reply) :- portURL(8000, URL),
                                untag_url(URL, HREF),
                                http_put(HREF, json(json{key: Key, tag: Tag}), Reply, []).


portURL(Port, HREF) :- format(atom(HREF), 'http://localhost:~d~s',[Port,'/']).

get_url(Key, URL, HREF) :- format(atom(HREF), '~sget?key=~s', [URL, Key]).
post_url(URL, HREF) :- format(atom(HREF), '~spost', [URL]).
delete_url(Key, URL, HREF) :- format(atom(HREF), '~sdelete?key=~s', [URL, Key]).
tag_url(URL, HREF) :- format(atom(HREF), '~stag', [URL]).
untag_url(URL, HREF) :- format(atom(HREF), '~suntag', [URL]).
tquery_url(Tag, URL, HREF) :- format(atom(HREF), '~stagquery?tag=~s', [URL, Tag]).