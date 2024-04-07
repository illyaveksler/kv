:- use_module(library(http/http_client)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).

access(get, Key, Reply) :- portURL(8000, URL), 
                            get_url(Key, URL, HREF),
                            http_get(HREF, Reply, []).

access(post, Key, Value, Reply) :- portURL(8000, URL), 
                                post_url(URL, HREF),
                                http_post(HREF, json{key: Key, value: Value}, Reply, []).

access(delete, Key, Reply) :- portURL(8000, URL), 
                            delete_url(Key, URL, HREF), 
                            http_delete(HREF, Reply, []).

access(tag, Key, Tag, Reply) :- portURL(8000, URL),
                                tag_url(Key, URL, HREF),
                                http_post(HREF, json{key: Key, tag: Tag}, Reply, []).

access(untag, Key, Tag, Reply) :- portURL(8000, URL),
                                untag_url(Key, URL, HREF),
                                http_post(HREF, json{key: Key, tag: Tag}, Reply, []).

portURL(Port, HREF) :- format(atom(HREF), 'http://localhost:~d~s',[Port,'/']).

get_url(Key, URL, HREF) :- format(atom(HREF), '~sget?key=~s', [URL, Key]).
post_url(URL, HREF) :- format(atom(HREF), '~spost', [URL]).
delete_url(Key, URL, HREF) :- format(atom(HREF), '~sdelete?key=~s', [URL, Key]).
tag_url(Key, URL, HREF) :- format(atom(HREF), '~stag?key=~s', [URL, Key]).
tag_url(Key, URL, HREF) :- format(atom(HREF), '~suntag?key=~s', [URL, Key]).