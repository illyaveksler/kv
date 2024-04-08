:- use_module(library(http/http_client)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).





getKV(Key, Result) :- catch(
    access(get, Key, Result),
    error(_, _),
    (
        Result is [],
        format('Key not found.', [])
    )
).

postKV(Key, Result) :- catch(
    access(post, Key, Value, Result),
    error(_, _),
    (
        Result is [],
        format('Key either already exists, or the post is invalid.', [])
    )
).

deleteKV(Key, Result) :- catch(
    access(delete, Key, Result),
    error(_, _),
    (
        Result is [],
        format('Key not found: ~s', [Key])
    )
).

tagQueryKV(Tag, Result) :- catch(
    access(tagquery, Tag, Result),
    error(_, _),
    (
        Result is [],
        format('Tag not found: ~s', [Tag])
    )
).

tagKV(Key, Tag, Result) :- catch(
    access(tag, Key, Tag, Result),
    error(Error, _),
    (
        Result is []
    )
).

untagKV(Key, Tag, Result) :- catch(
    access(tag, Key, Tag, Result),
    error(Error, _),
    (
        Result is []
    )
).





access(get, Key, Reply) :- portURL(8000, URL), 
                            get_url(Key, URL, HREF),
                            http_get(HREF, Reply, []).

access(delete, Key, Reply) :- portURL(8000, URL), 
                            delete_url(Key, URL, HREF), 
                            http_delete(HREF, Reply, []).

access(post, Key, Value, Reply) :- portURL(8000, URL), 
                                post_url(URL, HREF),
                                http_post(HREF, json{key: Key, value: Value}, Reply, []).

access(tag, Key, Tag, Reply) :- portURL(8000, URL),
                                tag_url(Key, URL, HREF),
                                http_post(HREF, json{key: Key, tag: Tag}, Reply, []).

access(untag, Key, Tag, Reply) :- portURL(8000, URL),
                                untag_url(Key, URL, HREF),
                                http_post(HREF, json{key: Key, tag: Tag}, Reply, []).

access(tagquery, Tag, Reply) :- portURL(8000, URL), 
                            tquery_url(Tag, URL, HREF),
                            http_get(HREF, Reply, []).

portURL(Port, HREF) :- format(atom(HREF), 'http://localhost:~d~s',[Port,'/']).

get_url(Key, URL, HREF) :- format(atom(HREF), '~sget?key=~s', [URL, Key]).
post_url(URL, HREF) :- format(atom(HREF), '~spost', [URL]).
delete_url(Key, URL, HREF) :- format(atom(HREF), '~sdelete?key=~s', [URL, Key]).
tag_url(Key, URL, HREF) :- format(atom(HREF), '~stag?key=~s', [URL, Key]).
untag_url(Key, URL, HREF) :- format(atom(HREF), '~suntag?key=~s', [URL, Key]).
tquery_url(Tag, URL, HREF) :- format(atom(HREF), '~stagquery?tag=~s', [URL, Tag]).