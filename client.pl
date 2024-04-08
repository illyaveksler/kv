:- use_module(library(http/http_client)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).

% main query utility. gets lists of keys from a query about tags.
tag_query_kv(Query, Result) :- tag_query_kv_parse(Query, Result), (\+(Result == []) -> true; format('Tag(s) not found.', [])).

% TAG QUERY PARSING (brackets are for pattern matching, the last two having brackets around the second term allows proper order of operations)

% handles intersections (+ used as 'and' operator because & was already a symbol)
tag_query_kv_parse(Tag1+Tag2, Result) :- tag_query_kv_parse(Tag1, Result1), tag_list_kv(Tag2, Result2), intersection(Result1, Result2, Result).
tag_query_kv_parse((Tag1)+Tag2, Result) :- tag_query_kv_parse(Tag1, Result1), tag_list_kv(Tag2, Result2), intersection(Result1, Result2, Result).
tag_query_kv_parse(Tag1+(Tag2), Result) :- tag_query_kv_parse(Tag1, Result1), tag_query_kv_parse(Tag2, Result2), intersection(Result1, Result2, Result).
tag_query_kv_parse((Tag1)+(Tag2), Result) :- tag_query_kv_parse(Tag1, Result1), tag_query_kv_parse(Tag2, Result2), intersection(Result1, Result2, Result).

% handles unions (| as 'or' operator)
tag_query_kv_parse(Tag1|Tag2, Result) :- tag_query_kv_parse(Tag1, Result1), tag_list_kv(Tag2, Result2), union(Result1, Result2, Result).
tag_query_kv_parse((Tag1)|Tag2, Result) :- tag_query_kv_parse(Tag1, Result1), tag_list_kv(Tag2, Result2), union(Result1, Result2, Result).
tag_query_kv_parse(Tag1|(Tag2), Result) :- tag_query_kv_parse(Tag1, Result1), tag_query_kv_parse(Tag2, Result2), union(Result1, Result2, Result).
tag_query_kv_parse((Tag1)|(Tag2), Result) :- tag_query_kv_parse(Tag1, Result1), tag_query_kv_parse(Tag2, Result2), union(Result1, Result2, Result).

% handles subtractions (- as operator)
tag_query_kv_parse(Tag1-Tag2, Result) :- tag_query_kv_parse(Tag1, Result1), tag_list_kv(Tag2, Result2), subtract(Result1, Result2, Result).
tag_query_kv_parse((Tag1)-Tag2, Result) :- tag_query_kv_parse(Tag1, Result1), tag_list_kv(Tag2, Result2), subtract(Result1, Result2, Result).
tag_query_kv_parse(Tag1-(Tag2), Result) :- tag_query_kv_parse(Tag1, Result1), tag_query_kv_parse(Tag2, Result2), subtract(Result1, Result2, Result).
tag_query_kv_parse((Tag1)-(Tag2), Result) :- tag_query_kv_parse(Tag1, Result1), tag_query_kv_parse(Tag2, Result2), subtract(Result1, Result2, Result).

% handles atomic tags
tag_query_kv_parse(Tag, Result) :- tag_list_kv(Tag, Result).



% gets a value from a key.
get_kv(Key, Result) :- catch(
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
post_kv(Key, Value) :- catch(
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
        format('~s', Dict.status)
).



% deletes a key-value pair from the server.
delete_kv(Key) :- catch(
    access(delete, Key, Reply),
    error(_, _),
    (
        Reply = [],
        format('Key not found: ~s', [])
    )
),  (
    \+ (Reply == [])
    ->  atom_json_dict(Text, Reply, []),
        atom_json_dict(Text, Dict, []),
        format('~s', Dict.status)
).



% gets a list of keys with a certain tag.
tag_list_kv(Tag, Result) :- catch(
    access(tagquery, Tag, Reply),
    error(_, _),
    (
        Reply = []
    )
),  (
    \+ (Reply == [])
    ->  atom_json_dict(Text, Reply, []),
        atom_json_dict(Text, Dict, []),
        Result = Dict.keys
    ;   Result = []
).



% tags a key-value pair with a certain tag.
tag_kv(Key, Tag) :- catch(
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
        format('~s', Dict.status)
).



% removes a certain tag from a tagged key-value pair.
untag_kv(Key, Tag, Result) :- catch(
    access(untag, Key, Tag, Reply),
    error(Error, _),
    (
        Reply = [],
        print(Error)
    )
),  (
    \+ (Reply == [])
    ->  atom_json_dict(Text, Reply, []),
        atom_json_dict(Text, Dict, []),
        format('~s', Dict.status)
).




% access predicates. originally used for direct access, now operating as backend.
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